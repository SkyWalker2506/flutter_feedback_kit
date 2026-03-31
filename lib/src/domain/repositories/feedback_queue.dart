import '../entities/feedback_entry.dart';

/// Persistent offline queue for [FeedbackEntry] objects.
///
/// Implement this interface to provide a custom storage backend for the
/// offline queue. The built-in implementation is [SharedPrefsQueue].
abstract class FeedbackQueue {
  /// Appends [entry] to the end of the queue.
  Future<void> enqueue(FeedbackEntry entry);

  /// Returns all queued entries that have not yet been delivered.
  Future<List<FeedbackEntry>> pending();

  /// Removes all entries from the queue.
  ///
  /// Call this after a successful [QueuedBackend.flushQueue].
  Future<void> clear();
}
