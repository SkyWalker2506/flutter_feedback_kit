import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../domain/entities/feedback_entry.dart';
import '../../domain/repositories/feedback_backend.dart';

/// A debug-only [FeedbackBackend] that saves feedback as JSON + PNG files
/// to the given [directory]. Intended for emulator/simulator testing only.
///
/// Usage:
/// ```dart
/// LocalFeedbackBackend(
///   directory: Directory('/path/to/feedback'),
/// )
/// ```
class LocalFeedbackBackend implements FeedbackBackend {
  LocalFeedbackBackend({required this.directory});

  final Directory directory;

  @override
  Future<void> submit(FeedbackEntry entry) async {
    assert(kDebugMode, 'LocalFeedbackBackend must only be used in debug mode');

    await directory.create(recursive: true);

    // e.g. 2026-03-31T14-30-00-000_bug
    final ts = entry.createdAt
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');
    final id = '${ts}_${entry.category.name}';

    // Save each screenshot as a PNG file
    final screenshotFileNames = <String>[];
    for (var i = 0; i < entry.screenshots.length; i++) {
      final name = '${id}_ss${i + 1}.png';
      await File('${directory.path}/$name')
          .writeAsBytes(base64Decode(entry.screenshots[i]));
      screenshotFileNames.add(name);
    }

    // Save JSON (filenames, not base64 blobs)
    final json = <String, dynamic>{
      'category': entry.category.name,
      'message': entry.message,
      'platform': entry.platform,
      'appVersion': entry.appVersion,
      'createdAt': entry.createdAt.toIso8601String(),
      'screenshots': screenshotFileNames,
    };
    await File('${directory.path}/$id.json')
        .writeAsString(const JsonEncoder.withIndent('  ').convert(json));

    debugPrint(
      '[FeedbackKit] 📋 $id.json | '
      '${entry.category.label} | '
      '${entry.screenshots.length} screenshot(s)',
    );
  }

  @override
  void dispose() {}
}
