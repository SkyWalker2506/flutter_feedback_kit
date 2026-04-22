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

  /// Removes the entry at [index] from the queue.
  ///
  /// Used by [QueuedBackend.flushQueue] to remove only the entries that have
  /// been successfully delivered, keeping the rest for the next attempt.
  ///
  /// Default implementation: loads all entries, removes the one at [index],
  /// clears the queue, and re-enqueues the remainder. Override for efficiency.
  Future<void> removeAt(int index) async {
    final all = await pending();
    if (index < 0 || index >= all.length) return;
    final kept = [...all.sublist(0, index), ...all.sublist(index + 1)];
    await clear();
    for (final e in kept) {
      await enqueue(e);
    }
  }

  /// Removes all entries from the queue.
  ///
  /// Call this after all entries have been delivered successfully.
  Future<void> clear();
}
