import 'package:flutter_feedback_kit/flutter_feedback_kit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockBackend extends Mock implements FeedbackBackend {}

class _MockQueue extends Mock implements FeedbackQueue {}

class _FakeConnectivity implements ConnectivityService {
  _FakeConnectivity({required bool online}) : _online = online;
  final bool _online;

  @override
  Future<bool> isOnline() async => _online;
}

void main() {
  late _MockBackend backend;
  late _MockQueue queue;

  final entry = FeedbackEntry(
    category: FeedbackCategory.bug,
    message: 'Test message',
    platform: 'android',
    appVersion: '1.0.0',
    createdAt: DateTime(2026, 1, 1),
  );

  setUpAll(() {
    registerFallbackValue(entry);
  });

  setUp(() {
    backend = _MockBackend();
    queue = _MockQueue();
  });

  QueuedBackend makeBackend({required bool online}) => QueuedBackend(
        backend: backend,
        queue: queue,
        connectivity: _FakeConnectivity(online: online),
      );

  group('QueuedBackend.submit', () {
    test('enqueues when offline', () async {
      when(() => queue.enqueue(any())).thenAnswer((_) async {});

      await makeBackend(online: false).submit(entry);

      verify(() => queue.enqueue(entry)).called(1);
      verifyNever(() => backend.submit(any()));
    });

    test('submits directly when online', () async {
      when(() => backend.submit(any())).thenAnswer((_) async {});

      await makeBackend(online: true).submit(entry);

      verify(() => backend.submit(entry)).called(1);
      verifyNever(() => queue.enqueue(any()));
    });

    test('enqueues when online but backend throws', () async {
      when(() => backend.submit(any())).thenThrow(Exception('network error'));
      when(() => queue.enqueue(any())).thenAnswer((_) async {});

      await makeBackend(online: true).submit(entry);

      verify(() => queue.enqueue(entry)).called(1);
    });
  });

  group('QueuedBackend.flushQueue', () {
    test('returns 0 when offline', () async {
      final sent = await makeBackend(online: false).flushQueue();
      expect(sent, 0);
      verifyNever(() => queue.pending());
    });

    test('returns 0 when queue is empty', () async {
      when(() => queue.pending()).thenAnswer((_) async => []);

      final sent = await makeBackend(online: true).flushQueue();
      expect(sent, 0);
    });

    test('sends all entries and removes each from queue on full success',
        () async {
      when(() => queue.pending()).thenAnswer((_) async => [entry, entry]);
      when(() => backend.submit(any())).thenAnswer((_) async {});
      when(() => queue.removeAt(any())).thenAnswer((_) async {});

      final sent = await makeBackend(online: true).flushQueue();

      expect(sent, 2);
      // removeAt(0) called once per delivered entry
      verify(() => queue.removeAt(0)).called(2);
    });

    test('stops at first failure and only removes successfully delivered entries',
        () async {
      var callCount = 0;
      when(() => queue.pending()).thenAnswer((_) async => [entry, entry]);
      when(() => backend.submit(any())).thenAnswer((_) async {
        if (++callCount > 1) throw Exception('fail');
      });
      when(() => queue.removeAt(any())).thenAnswer((_) async {});

      final sent = await makeBackend(online: true).flushQueue();

      expect(sent, 1);
      // Only the first entry was delivered and removed
      verify(() => queue.removeAt(0)).called(1);
      verifyNever(() => queue.clear());
    });
  });
}
