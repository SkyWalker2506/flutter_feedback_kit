import 'package:flutter_feedback_kit/flutter_feedback_kit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('WebhookBackend', () {
    final entry = FeedbackEntry(
      category: FeedbackCategory.bug,
      message: 'Test message',
      platform: 'android',
      appVersion: '1.0.0',
      createdAt: DateTime(2026, 3, 31),
    );

    test('submit sends POST with default payload', () async {
      http.Request? captured;

      final backend = WebhookBackend(
        url: 'https://example.com/webhook',
        httpClient: MockClient((request) async {
          captured = request;
          return http.Response('ok', 200);
        }),
      );

      await backend.submit(entry);

      expect(captured?.method, 'POST');
      expect(captured?.url.toString(), 'https://example.com/webhook');
      expect(captured?.headers['Content-Type'], contains('application/json'));
      expect(captured?.body, contains('"category":"bug"'));
    });

    test('submit uses custom payloadBuilder', () async {
      String? sentBody;

      final backend = WebhookBackend(
        url: 'https://example.com/webhook',
        payloadBuilder: (e) => {'text': e.message},
        httpClient: MockClient((request) async {
          sentBody = request.body;
          return http.Response('ok', 200);
        }),
      );

      await backend.submit(entry);
      expect(sentBody, '{"text":"Test message"}');
    });

    test('throws WebhookException on non-2xx response', () async {
      final backend = WebhookBackend(
        url: 'https://example.com/webhook',
        httpClient: MockClient((_) async => http.Response('sensitive body', 500)),
      );

      expect(
        () => backend.submit(entry),
        throwsA(
          predicate<WebhookException>(
            (e) => !e.message.contains('sensitive body'),
            'exception must not leak response body',
          ),
        ),
      );
    });

    test('throws ArgumentError for non-HTTPS URL', () {
      expect(
        () => WebhookBackend(url: 'http://example.com/webhook'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
