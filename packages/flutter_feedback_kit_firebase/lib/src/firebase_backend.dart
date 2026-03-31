import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_feedback_kit/flutter_feedback_kit.dart';

/// [FeedbackBackend] that writes entries to Cloud Firestore and uploads
/// screenshots to Firebase Storage.
///
/// **Setup:**
/// 1. Add `flutter_feedback_kit_firebase` to your `pubspec.yaml`.
/// 2. Complete Firebase setup (`google-services.json` / `GoogleService-Info.plist`).
/// 3. Call `await Firebase.initializeApp()` before using this backend.
///
/// ```dart
/// FeedbackButton(
///   backend: FirebaseFeedbackBackend(
///     collection: 'feedback',
///     screenshotsBucket: 'feedback-screenshots',
///   ),
///   appVersion: '1.0.0',
/// )
/// ```
class FirebaseFeedbackBackend implements FeedbackBackend {
  /// Creates a [FirebaseFeedbackBackend].
  ///
  /// [collection] — Firestore collection path. Default: `'feedback'`.
  /// [screenshotsBucket] — Storage path prefix for uploaded screenshots.
  ///   When `null`, screenshots are stored inline as base64 strings.
  /// [uploadTimeoutSeconds] — Upload timeout per screenshot. Default: 30.
  FirebaseFeedbackBackend({
    this.collection = 'feedback',
    this.screenshotsBucket,
    this.uploadTimeoutSeconds = 30,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  /// Firestore collection where entries are written.
  final String collection;

  /// Firebase Storage path prefix for screenshot uploads.
  /// When `null`, screenshots are stored as base64 strings in Firestore.
  final String? screenshotsBucket;

  /// Upload timeout per screenshot in seconds. Default: 30.
  final int uploadTimeoutSeconds;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  @override
  Future<void> submit(FeedbackEntry entry) async {
    final payload = entry.toJson();

    if (entry.screenshots.isNotEmpty && screenshotsBucket != null) {
      final urls = await _uploadScreenshots(entry);
      payload['screenshotUrls'] = urls;
      payload.remove('screenshots'); // avoid storing large base64 in Firestore
    }

    payload['serverTimestamp'] = FieldValue.serverTimestamp();
    await _firestore.collection(collection).add(payload);
  }

  @override
  void dispose() {}

  Future<List<String>> _uploadScreenshots(FeedbackEntry entry) async {
    final urls = <String>[];
    final timestamp = entry.createdAt.millisecondsSinceEpoch;

    for (var i = 0; i < entry.screenshots.length; i++) {
      final raw = entry.screenshots[i];
      // Strip data URI prefix if present (e.g. "data:image/png;base64,...")
      final b64 = raw.contains(',') ? raw.split(',').last : raw;
      final bytes = Uint8List.fromList(base64Decode(b64));

      final path = '$screenshotsBucket/${timestamp}_$i.png';
      final ref = _storage.ref(path);

      await ref
          .putData(bytes, SettableMetadata(contentType: 'image/png'))
          .timeout(Duration(seconds: uploadTimeoutSeconds));

      final url = await ref
          .getDownloadURL()
          .timeout(const Duration(seconds: 5));
      urls.add(url);
    }
    return urls;
  }
}
