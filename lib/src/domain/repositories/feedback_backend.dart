import '../entities/feedback_entry.dart';

/// Contract for submitting [FeedbackEntry] objects to a remote service.
///
/// Implement this interface to connect flutter_feedback_kit to any backend —
/// Firebase, Supabase, a custom REST API, or a local sink for testing.
///
/// ```dart
/// class FirebaseBackend implements FeedbackBackend {
///   @override
///   Future<void> submit(FeedbackEntry entry) async {
///     await FirebaseFirestore.instance
///         .collection('feedback')
///         .add(entry.toJson());
///   }
/// }
/// ```
abstract class FeedbackBackend {
  /// Sends [entry] to the backend.
  ///
  /// Throw any [Exception] on failure. [QueuedBackend] intercepts backend
  /// exceptions and enqueues the entry for retry.
  Future<void> submit(FeedbackEntry entry);

  /// Releases resources held by this backend (e.g. an HTTP client).
  ///
  /// Override when cleanup is required. The default is a no-op.
  void dispose() {}
}
