import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../domain/entities/feedback_entry.dart';
import '../../domain/repositories/feedback_backend.dart';
import 'dev_file_backend_io.dart'
    if (dart.library.html) 'dev_file_backend_web.dart' as impl;

/// A [FeedbackBackend] that writes feedback to the local filesystem.
///
/// Each submission creates a timestamped directory containing:
/// - `feedback.txt` — human-readable summary (category, message, metadata)
/// - `screenshot_1.png`, `screenshot_2.png`, ... — attached screenshots
///
/// Designed for development workflows where an AI assistant or developer
/// reads feedback directly from the device filesystem.
///
/// **Not supported on web.** On web platforms, [submit] throws an
/// [UnsupportedError]. Use [WebhookBackend] or another network-based
/// backend instead.
///
/// ```dart
/// final backend = DevFileBackend(directory: '/sdcard/Download/dev_feedback');
/// ```
class DevFileBackend implements FeedbackBackend {
  DevFileBackend({required this.directory});

  /// Root directory where feedback folders are created.
  final String directory;

  /// Whether this backend is supported on the current platform.
  static bool get isSupported => !kIsWeb;

  @override
  Future<void> submit(FeedbackEntry entry) async {
    if (kIsWeb) {
      throw UnsupportedError(
        'DevFileBackend is not supported on web. '
        'Use WebhookBackend or another network-based backend instead.',
      );
    }

    final ts = entry.createdAt
        .toIso8601String()
        .replaceAll(':', '-')
        .split('.')
        .first;

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

    await impl.writeDevFeedback(
      directory: directory,
      timestamp: ts,
      text: buf.toString(),
      screenshotBytes: entry.screenshots.map(base64Decode).toList(),
    );
  }

  @override
  void dispose() {}
}
