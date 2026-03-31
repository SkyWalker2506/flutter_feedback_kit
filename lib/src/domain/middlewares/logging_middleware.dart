import 'dart:developer' as developer;

import '../entities/feedback_entry.dart';
import '../feedback_middleware.dart';

/// A pass-through middleware that logs feedback details before submission.
///
/// Logs the feedback category, message length, and creation timestamp using
/// [developer.log]. The entry is returned unchanged — this middleware never
/// cancels a submission.
///
/// ```dart
/// FeedbackWidget(
///   backend: myBackend,
///   middlewares: [LoggingMiddleware()],
///   appVersion: '1.0.0',
/// )
/// ```
class LoggingMiddleware implements FeedbackMiddleware {
  /// Creates a [LoggingMiddleware].
  ///
  /// Supply a custom [name] to distinguish log lines when multiple middleware
  /// instances are active. Defaults to `'flutter_feedback_kit'`.
  const LoggingMiddleware({this.name = 'flutter_feedback_kit'});

  /// The logger name used for [developer.log] output.
  final String name;

  @override
  Future<FeedbackEntry?> process(FeedbackEntry entry) async {
    developer.log(
      'Feedback intercepted — '
      'category: ${entry.category}, '
      'messageLength: ${entry.message.length}, '
      'timestamp: ${entry.createdAt.toIso8601String()}',
      name: name,
    );
    return entry;
  }
}
