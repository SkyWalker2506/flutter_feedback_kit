import 'dart:convert';

import 'package:flutter_feedback_kit/flutter_feedback_kit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

// ─── Helpers ─────────────────────────────────────────────────────────────────

FeedbackEntry _makeEntry({
  String category = FeedbackCategory.other,
  String message = 'The app crashes when I open settings.',
}) =>
    FeedbackEntry(
      category: category,
      message: message,
      platform: 'android',
      appVersion: '1.0.0',
      createdAt: DateTime(2026, 1, 1),
    );

/// Builds a fake HTTP client that returns [statusCode] with [body].
http.Client _fakeClient({
  required int statusCode,
  required Map<String, dynamic> body,
}) {
  return MockClient((_) async => http.Response(
        jsonEncode(body),
        statusCode,
        headers: {'content-type': 'application/json'},
      ));
}

/// A successful Claude API response for [categoryName].
Map<String, dynamic> _claudeResponse(String categoryName) => {
      'content': [
        {'type': 'text', 'text': categoryName},
      ],
      'model': 'claude-haiku-4-5-20251001',
      'stop_reason': 'end_turn',
    };

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  group('AiCategorizationMiddleware', () {
    group('no-op conditions', () {
      test('returns entry unchanged when apiKey is null', () async {
        final mw = AiCategorizationMiddleware();
        final entry = _makeEntry();
        final result = await mw.process(entry);
        expect(result, entry);
      });

      test('returns entry unchanged when apiKey is empty string', () async {
        final mw = AiCategorizationMiddleware(apiKey: '');
        final entry = _makeEntry();
        final result = await mw.process(entry);
        expect(result, entry);
      });

      test('skips categorisation when category is already set (not "other")',
          () async {
        // Even with a valid API key, if the user already picked a real
        // category the middleware must leave it alone.
        final client = _fakeClient(
          statusCode: 200,
          body: _claudeResponse('suggestion'),
        );
        final mw = AiCategorizationMiddleware(
          apiKey: 'test-key',
          httpClient: client,
        );

        final entry = _makeEntry(category: FeedbackCategory.bug);
        final result = await mw.process(entry);

        // Category must remain 'bug', not be overwritten by Claude.
        expect(result?.category, FeedbackCategory.bug);
      });
    });

    group('successful categorisation', () {
      test('updates category when Claude returns a valid category name',
          () async {
        final client = _fakeClient(
          statusCode: 200,
          body: _claudeResponse('bug'),
        );
        final mw = AiCategorizationMiddleware(
          apiKey: 'test-key',
          httpClient: client,
        );

        final result = await mw.process(_makeEntry());
        expect(result?.category, FeedbackCategory.bug);
      });

      test('maps "featurerequest" (lowercase) to featureRequest constant',
          () async {
        final client = _fakeClient(
          statusCode: 200,
          body: _claudeResponse('featurerequest'),
        );
        final mw = AiCategorizationMiddleware(
          apiKey: 'test-key',
          httpClient: client,
        );

        final result = await mw.process(_makeEntry());
        expect(result?.category, FeedbackCategory.featureRequest);
      });

      test('maps "uiux" variant to FeedbackCategory.ui', () async {
        final client = _fakeClient(
          statusCode: 200,
          body: _claudeResponse('uiux'),
        );
        final mw = AiCategorizationMiddleware(
          apiKey: 'test-key',
          httpClient: client,
        );

        final result = await mw.process(_makeEntry());
        expect(result?.category, FeedbackCategory.ui);
      });

      test('does not modify other entry fields', () async {
        final client = _fakeClient(
          statusCode: 200,
          body: _claudeResponse('performance'),
        );
        final mw = AiCategorizationMiddleware(
          apiKey: 'test-key',
          httpClient: client,
        );

        final entry = _makeEntry(message: 'Very slow on startup');
        final result = await mw.process(entry);

        expect(result?.message, entry.message);
        expect(result?.platform, entry.platform);
        expect(result?.appVersion, entry.appVersion);
        expect(result?.createdAt, entry.createdAt);
      });
    });

    group('graceful degradation on API error', () {
      test('returns entry unchanged on HTTP 4xx error', () async {
        final client = _fakeClient(
          statusCode: 401,
          body: {'error': 'Unauthorized'},
        );
        final mw = AiCategorizationMiddleware(
          apiKey: 'bad-key',
          httpClient: client,
        );

        final entry = _makeEntry();
        final result = await mw.process(entry);
        expect(result, entry);
      });

      test('returns entry unchanged on HTTP 5xx error', () async {
        final client = _fakeClient(
          statusCode: 500,
          body: {'error': 'Internal Server Error'},
        );
        final mw = AiCategorizationMiddleware(
          apiKey: 'test-key',
          httpClient: client,
        );

        final entry = _makeEntry();
        final result = await mw.process(entry);
        expect(result, entry);
      });

      test('returns entry unchanged on network exception', () async {
        final client = MockClient((_) async => throw Exception('No network'));
        final mw = AiCategorizationMiddleware(
          apiKey: 'test-key',
          httpClient: client,
        );

        final entry = _makeEntry();
        final result = await mw.process(entry);
        expect(result, entry);
        // Submission must not be cancelled.
        expect(result, isNotNull);
      });

      test('returns entry unchanged when Claude returns an unknown category',
          () async {
        final client = _fakeClient(
          statusCode: 200,
          body: _claudeResponse('unknown_category_xyz'),
        );
        final mw = AiCategorizationMiddleware(
          apiKey: 'test-key',
          httpClient: client,
        );

        final entry = _makeEntry();
        final result = await mw.process(entry);
        // Cannot map the response — entry comes back as-is.
        expect(result, entry);
      });

      test('returns entry unchanged when content array is empty', () async {
        final client = _fakeClient(
          statusCode: 200,
          body: {'content': []},
        );
        final mw = AiCategorizationMiddleware(
          apiKey: 'test-key',
          httpClient: client,
        );

        final entry = _makeEntry();
        final result = await mw.process(entry);
        expect(result, entry);
      });

      test('never returns null (never cancels submission)', () async {
        final client = MockClient((_) async => throw Exception('timeout'));
        final mw = AiCategorizationMiddleware(
          apiKey: 'test-key',
          httpClient: client,
        );

        final result = await mw.process(_makeEntry());
        expect(result, isNotNull);
      });
    });
  });
}
