import '../entities/feedback_entry.dart';

/// Persistent offline queue for feedback entries.
abstract class FeedbackQueue {
  /// Adds [entry] to the queue.
  Future<void> enqueue(FeedbackEntry entry);

  /// Returns all queued entries awaiting delivery.
  Future<List<FeedbackEntry>> pending();

  /// Removes all entries (call after successful flush).
  Future<void> clear();
}
