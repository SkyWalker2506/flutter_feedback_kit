import '../../domain/entities/feedback_entry.dart';
import '../../domain/repositories/feedback_backend.dart';
import '../../domain/repositories/feedback_queue.dart';
import '../../services/connectivity_service.dart';

/// Wraps any [FeedbackBackend] with transparent offline-queue support.
///
/// - When the device is **offline**, [submit] silently enqueues the entry.
/// - When the device is **online** but the backend throws, the entry is
///   enqueued instead of propagating the exception.
/// - Call [flushQueue] after connectivity is restored to drain the queue.
///
/// ```dart
/// final backend = QueuedBackend(
///   backend: WebhookBackend(url: 'https://example.com/feedback'),
///   queue: SharedPrefsQueue(),
///   onQueued: (entry) {
///     ScaffoldMessenger.of(context).showSnackBar(
///       const SnackBar(content: Text('Saved offline. Will send when connected.')),
///     );
///   },
/// );
/// ```
class QueuedBackend implements FeedbackBackend {
  /// Creates a [QueuedBackend].
  ///
  /// An optional [connectivity] override is accepted for testing.
  QueuedBackend({
    required FeedbackBackend backend,
    required FeedbackQueue queue,
    ConnectivityService? connectivity,
    this.onQueued,
  })  : _backend = backend,
        _queue = queue,
        _connectivity = connectivity ?? const ConnectivityService();

  final FeedbackBackend _backend;
  final FeedbackQueue _queue;
  final ConnectivityService _connectivity;

  /// Optional callback fired whenever an entry is added to the queue instead
  /// of being delivered immediately.
  final void Function(FeedbackEntry entry)? onQueued;

  bool _lastSubmitWasQueued = false;

  /// `true` if the most recent [submit] call enqueued rather than delivered.
  ///
  /// [FeedbackWidget] uses this flag to show a "saved offline" message
  /// when it detects that its backend is a [QueuedBackend].
  bool get lastSubmitWasQueued => _lastSubmitWasQueued;

  /// Submits [entry] to the underlying backend, or enqueues it if offline
  /// or if the backend throws.
  @override
  Future<void> submit(FeedbackEntry entry) async {
    _lastSubmitWasQueued = false;
    final online = await _connectivity.isOnline();
    if (!online) {
      await _queue.enqueue(entry);
      _lastSubmitWasQueued = true;
      onQueued?.call(entry);
      return;
    }
    try {
      await _backend.submit(entry);
    } catch (_) {
      await _queue.enqueue(entry);
      _lastSubmitWasQueued = true;
      onQueued?.call(entry);
    }
  }

  /// Attempts to deliver all queued entries via the underlying backend.
  ///
  /// Successfully delivered entries are removed from the queue immediately,
  /// so a partial flush (e.g. backend fails on entry 3 of 5) leaves only the
  /// undelivered entries in the queue for the next attempt.
  ///
  /// Stops at the first failure to avoid reordering entries.
  ///
  /// Returns the number of successfully delivered entries.
  Future<int> flushQueue() async {
    final online = await _connectivity.isOnline();
    if (!online) return 0;

    final entries = await _queue.pending();
    if (entries.isEmpty) return 0;

    var sent = 0;
    for (var i = 0; i < entries.length; i++) {
      try {
        await _backend.submit(entries[i]);
        // Remove this entry from the front of the queue.
        // After each removal the remaining entries shift left by one, so we
        // always remove at index 0 for the first entry, then index 0 again
        // for the next (the queue shrinks as we go).
        await _queue.removeAt(0);
        sent++;
      } catch (_) {
        break;
      }
    }

    return sent;
  }

  @override
  void dispose() => _backend.dispose();
}
