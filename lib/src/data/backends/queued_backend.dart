import '../../domain/entities/feedback_entry.dart';
import '../../domain/repositories/feedback_backend.dart';
import '../../domain/repositories/feedback_queue.dart';
import '../../services/connectivity_service.dart';

/// Wraps any [FeedbackBackend] with offline-queue support.
///
/// - If the device is offline, [submit] silently enqueues the entry.
/// - If the backend throws, the entry is enqueued instead of propagating.
/// - Call [flushQueue] when connectivity is restored.
///
/// ```dart
/// final backend = QueuedBackend(
///   backend: WebhookBackend(url: 'https://...'),
///   queue: SharedPrefsQueue(),
/// );
/// ```
class QueuedBackend implements FeedbackBackend {
  QueuedBackend({
    required FeedbackBackend backend,
    required FeedbackQueue queue,
    ConnectivityService? connectivity,
  })  : _backend = backend,
        _queue = queue,
        _connectivity = connectivity ?? const ConnectivityService();

  final FeedbackBackend _backend;
  final FeedbackQueue _queue;
  final ConnectivityService _connectivity;

  @override
  Future<void> submit(FeedbackEntry entry) async {
    final online = await _connectivity.isOnline();
    if (!online) {
      await _queue.enqueue(entry);
      return;
    }
    try {
      await _backend.submit(entry);
    } catch (_) {
      await _queue.enqueue(entry);
    }
  }

  /// Attempts to send all queued entries via the underlying backend.
  /// Returns the number of successfully flushed entries.
  Future<int> flushQueue() async {
    final online = await _connectivity.isOnline();
    if (!online) return 0;

    final entries = await _queue.pending();
    if (entries.isEmpty) return 0;

    var sent = 0;
    for (final entry in entries) {
      try {
        await _backend.submit(entry);
        sent++;
      } catch (_) {
        break; // stop on first failure; try again next time
      }
    }

    if (sent == entries.length) {
      await _queue.clear();
    }
    return sent;
  }

  @override
  void dispose() => _backend.dispose();
}
