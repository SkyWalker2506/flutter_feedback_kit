import 'dart:convert';
import 'dart:io';

import '../../domain/entities/feedback_entry.dart';
import '../../domain/repositories/feedback_backend.dart';

/// A [FeedbackBackend] that writes feedback to the local filesystem.
///
/// Each submission creates a timestamped directory containing:
/// - `feedback.txt` — human-readable summary (category, message, metadata)
/// - `screenshot_1.png`, `screenshot_2.png`, ... — attached screenshots
///
/// Designed for development workflows where an AI assistant or developer
/// reads feedback directly from the device filesystem.
///
/// ```dart
/// final backend = DevFileBackend(directory: '/sdcard/Download/dev_feedback');
/// ```
class DevFileBackend implements FeedbackBackend {
  DevFileBackend({required this.directory});

  /// Root directory where feedback folders are created.
  final String directory;

  @override
  Future<void> submit(FeedbackEntry entry) async {
    final ts = entry.createdAt
        .toIso8601String()
        .replaceAll(':', '-')
        .split('.')
        .first;
    final dir = Directory('$directory/$ts');
    await dir.create(recursive: true);

    // Write human-readable feedback text
    final buf = StringBuffer()
      ..writeln('=== FEEDBACK ===')
      ..writeln('Date: ${entry.createdAt.toIso8601String()}')
      ..writeln('Category: ${entry.category}')
      ..writeln('Platform: ${entry.platform}')
      ..writeln('App Version: ${entry.appVersion}')
      ..writeln();

    if (entry.rating != null) buf.writeln('Rating: ${entry.rating}/5');
    if (entry.npsScore != null) buf.writeln('NPS: ${entry.npsScore}/10');

    buf
      ..writeln()
      ..writeln('--- MESSAGE ---')
      ..writeln(entry.message)
      ..writeln();

    if (entry.metadata != null) {
      final m = entry.metadata!;
      buf
        ..writeln('--- DEVICE ---')
        ..writeln('OS: ${m.osName} ${m.osVersion}')
        ..writeln('Device: ${m.deviceModel}')
        ..writeln('App: ${m.appName} build ${m.buildNumber}')
        ..writeln();
    }

    if (entry.sessionContext != null) {
      final sc = entry.sessionContext!;
      buf.writeln('--- SESSION ---');
      if (sc.userId != null) buf.writeln('User: ${sc.userId}');
      if (sc.currentRoute != null) buf.writeln('Route: ${sc.currentRoute}');
      if (sc.extra.isNotEmpty) {
        for (final kv in sc.extra.entries) {
          buf.writeln('${kv.key}: ${kv.value}');
        }
      }
      buf.writeln();
    }

    buf.writeln('Screenshots: ${entry.screenshots.length}');

    await File('${dir.path}/feedback.txt').writeAsString(buf.toString());

    // Write screenshots as PNG files
    for (var i = 0; i < entry.screenshots.length; i++) {
      final bytes = base64Decode(entry.screenshots[i]);
      await File('${dir.path}/screenshot_${i + 1}.png').writeAsBytes(bytes);
    }
  }

  @override
  void dispose() {}
}
