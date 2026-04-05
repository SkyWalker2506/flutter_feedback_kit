import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../domain/entities/feedback_entry.dart';
import '../../domain/repositories/feedback_backend.dart';
import 'local_feedback_backend_io.dart'
    if (dart.library.html) 'local_feedback_backend_web.dart' as impl;

/// A debug-only [FeedbackBackend] that saves feedback as JSON + PNG files
/// to the given [directoryPath]. Intended for emulator/simulator/desktop
/// testing only.
///
/// **Not supported on web.** On web platforms, [submit] throws an
/// [UnsupportedError]. Use [WebhookBackend] instead.
///
/// Usage:
/// ```dart
/// LocalFeedbackBackend(
///   directoryPath: '/path/to/feedback',
/// )
/// ```
class LocalFeedbackBackend implements FeedbackBackend {
  LocalFeedbackBackend({required this.directoryPath});

  /// Path to the root directory where feedback files are written.
  final String directoryPath;

  /// Whether this backend is supported on the current platform.
  static bool get isSupported => !kIsWeb;

  @override
  Future<void> submit(FeedbackEntry entry) async {
    if (kIsWeb) {
      throw UnsupportedError(
        'LocalFeedbackBackend is not supported on web. '
        'Use WebhookBackend or another network-based backend instead.',
      );
    }

    assert(kDebugMode, 'LocalFeedbackBackend must only be used in debug mode');

    // e.g. 2026-03-31T14-30-00-000_bug
    final ts = entry.createdAt
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');
    final id = '${ts}_${entry.category}';

    final screenshotFileNames = <String>[];
    for (var i = 0; i < entry.screenshots.length; i++) {
      screenshotFileNames.add('${id}_ss${i + 1}.png');
    }

    // Save JSON (filenames, not base64 blobs)
    final json = <String, dynamic>{
      'category': entry.category,
      'message': entry.message,
      'platform': entry.platform,
      'appVersion': entry.appVersion,
      'createdAt': entry.createdAt.toIso8601String(),
      'screenshots': screenshotFileNames,
    };

    await impl.writeLocalFeedback(
      directoryPath: directoryPath,
      id: id,
      jsonContent: const JsonEncoder.withIndent('  ').convert(json),
      screenshotBytes: entry.screenshots.map(base64Decode).toList(),
    );

    debugPrint(
      '[FeedbackKit] $id.json | '
      '${entry.category} | '
      '${entry.screenshots.length} screenshot(s)',
    );
  }

  @override
  void dispose() {}
}
