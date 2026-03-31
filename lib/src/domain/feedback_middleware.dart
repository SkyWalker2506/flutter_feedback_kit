import 'entities/feedback_entry.dart';

/// A hook that can inspect, modify, or cancel a [FeedbackEntry] before it is
/// delivered to the backend.
///
/// Middleware instances are supplied to [FeedbackWidget.middlewares] and run
/// sequentially in list order. Each middleware receives the entry returned by
/// the previous one, allowing a pipeline of transformations.
///
/// Returning `null` cancels the submission — no subsequent middleware runs and
/// the backend is never called.
///
/// ```dart
/// class RedactMiddleware implements FeedbackMiddleware {
///   @override
///   Future<FeedbackEntry?> process(FeedbackEntry entry) async {
///     // Strip email addresses from the message before submission.
///     final redacted = entry.message.replaceAll(
///       RegExp(r'[\w.+-]+@[\w-]+\.[\w.]+'),
///       '[redacted]',
///     );
///     return entry.copyWith(message: redacted);
///   }
/// }
/// ```
abstract class FeedbackMiddleware {
  /// Process [entry] before it is submitted to the backend.
  ///
  /// - Return a (possibly modified) [FeedbackEntry] to continue the chain.
  /// - Return `null` to cancel the submission entirely.
  Future<FeedbackEntry?> process(FeedbackEntry entry);
}
