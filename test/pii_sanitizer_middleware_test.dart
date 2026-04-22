import 'package:flutter_feedback_kit/flutter_feedback_kit.dart';
import 'package:flutter_test/flutter_test.dart';

FeedbackEntry _entry(String message) => FeedbackEntry(
      category: FeedbackCategory.bug,
      message: message,
      platform: 'android',
      appVersion: '1.0.0',
      createdAt: DateTime(2026),
    );

void main() {
  const middleware = PiiSanitizerMiddleware();

  group('PiiSanitizerMiddleware email redaction', () {
    test('redacts a plain email address', () async {
      final result = await middleware.process(
          _entry('Contact me at user@example.com please'));
      expect(result!.message, contains('[redacted]'));
      expect(result.message, isNot(contains('user@example.com')));
    });

    test('redacts email with plus sign', () async {
      final result =
          await middleware.process(_entry('Email: user+tag@mail.org'));
      expect(result!.message, isNot(contains('user+tag@mail.org')));
    });

    test('leaves message unchanged when no PII detected', () async {
      const msg = 'The login button is broken';
      final result = await middleware.process(_entry(msg));
      expect(result!.message, msg);
    });
  });

  group('PiiSanitizerMiddleware phone redaction', () {
    test('redacts US phone number', () async {
      final result =
          await middleware.process(_entry('Call 555-867-5309 for help'));
      expect(result!.message, isNot(contains('555-867-5309')));
    });

    test('redacts international phone', () async {
      final result =
          await middleware.process(_entry('Phone: +44 7911 123456'));
      expect(result!.message, isNot(contains('+44 7911 123456')));
    });
  });

  group('PiiSanitizerMiddleware custom patterns', () {
    test('applies additional custom pattern', () async {
      final m = PiiSanitizerMiddleware(
        patterns: [RegExp(r'\bTOKEN-\w+\b')],
      );
      final result =
          await m.process(_entry('API key is TOKEN-abc123 do not share'));
      expect(result!.message, isNot(contains('TOKEN-abc123')));
      expect(result.message, contains('[redacted]'));
    });

    test('uses custom replaceWith string', () async {
      final m = PiiSanitizerMiddleware(replaceWith: '***');
      final result =
          await m.process(_entry('Email user@test.com here'));
      expect(result!.message, contains('***'));
    });
  });

  test('returns same entry instance when no changes needed', () async {
    final entry = _entry('No PII here');
    final result = await middleware.process(entry);
    expect(identical(result, entry), isTrue);
  });
}
