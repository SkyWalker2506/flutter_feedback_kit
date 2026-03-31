import 'package:flutter_feedback_kit/flutter_feedback_kit.dart';
import 'package:flutter_test/flutter_test.dart';

// ─── Helpers ─────────────────────────────────────────────────────────────────

/// A middleware that appends a suffix to the feedback message.
class _AppendMiddleware implements FeedbackMiddleware {
  const _AppendMiddleware(this.suffix);
  final String suffix;

  @override
  Future<FeedbackEntry?> process(FeedbackEntry entry) async =>
      entry.copyWith(message: '${entry.message}$suffix');
}

/// A middleware that always cancels the submission by returning null.
class _CancelMiddleware implements FeedbackMiddleware {
  const _CancelMiddleware();

  @override
  Future<FeedbackEntry?> process(FeedbackEntry entry) async => null;
}

/// A middleware that records every entry it sees (for spy assertions).
class _SpyMiddleware implements FeedbackMiddleware {
  final List<FeedbackEntry> seen = [];

  @override
  Future<FeedbackEntry?> process(FeedbackEntry entry) async {
    seen.add(entry);
    return entry;
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

FeedbackEntry _makeEntry({String message = 'hello'}) => FeedbackEntry(
      category: FeedbackCategory.bug,
      message: message,
      platform: 'android',
      appVersion: '1.0.0',
      createdAt: DateTime(2026, 1, 1),
    );

/// Runs [middlewares] over [entry] sequentially, mimicking the logic in
/// [_FeedbackWidgetState._submit].
Future<FeedbackEntry?> _runChain(
  List<FeedbackMiddleware> middlewares,
  FeedbackEntry entry,
) async {
  FeedbackEntry? current = entry;
  for (final mw in middlewares) {
    current = await mw.process(current!);
    if (current == null) return null;
  }
  return current;
}

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  group('FeedbackMiddleware chain', () {
    test('empty chain returns entry unchanged', () async {
      final entry = _makeEntry();
      final result = await _runChain([], entry);
      expect(result, entry);
    });

    test('single middleware can modify entry', () async {
      final entry = _makeEntry(message: 'test');
      final result = await _runChain([const _AppendMiddleware('!')], entry);
      expect(result?.message, 'test!');
    });

    test('multiple middlewares compose sequentially', () async {
      final entry = _makeEntry(message: 'a');
      final result = await _runChain(
        [const _AppendMiddleware('b'), const _AppendMiddleware('c')],
        entry,
      );
      expect(result?.message, 'abc');
    });

    test('cancel middleware returns null and stops chain', () async {
      final spy = _SpyMiddleware();
      final result = await _runChain(
        [const _CancelMiddleware(), spy],
        _makeEntry(),
      );
      expect(result, isNull);
      // The spy after the canceller must never run.
      expect(spy.seen, isEmpty);
    });

    test('cancel after first step stops remaining middleware', () async {
      final spy = _SpyMiddleware();
      final result = await _runChain(
        [const _AppendMiddleware('x'), const _CancelMiddleware(), spy],
        _makeEntry(message: 'a'),
      );
      expect(result, isNull);
      expect(spy.seen, isEmpty);
    });

    test('entry passed to each step is the output of the previous step',
        () async {
      final spy = _SpyMiddleware();
      await _runChain(
        [const _AppendMiddleware('-first'), spy],
        _makeEntry(message: 'base'),
      );
      expect(spy.seen.single.message, 'base-first');
    });
  });

  group('LoggingMiddleware', () {
    test('returns entry unchanged', () async {
      const mw = LoggingMiddleware();
      final entry = _makeEntry(message: 'log me');
      final result = await mw.process(entry);
      expect(result, entry);
    });

    test('accepts a custom logger name without throwing', () async {
      const mw = LoggingMiddleware(name: 'custom_logger');
      final result = await mw.process(_makeEntry());
      expect(result, isNotNull);
    });
  });
}
