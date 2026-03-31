import 'dart:convert';

import 'package:flutter_feedback_kit/flutter_feedback_kit.dart';
import 'package:flutter_feedback_kit_linear/flutter_feedback_kit_linear.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

void main() {
  late MockHttpClient mockClient;

  final testEntry = FeedbackEntry(
    category: 'bug',
    message: 'The app crashes when I tap the button.',
    platform: 'android',
    appVersion: '1.0.0',
    createdAt: DateTime.utc(2026, 1, 15, 10, 30),
  );

  setUpAll(() {
    registerFallbackValue(FakeUri());
  });

  setUp(() {
    mockClient = MockHttpClient();
  });

  group('LinearFeedbackBackend.submit', () {
    test('creates issue successfully', () async {
      final backend = LinearFeedbackBackend(
        apiKey: 'lin_api_test',
        teamId: 'team-123',
        client: mockClient,
      );

      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode({
              'data': {
                'issueCreate': {
                  'success': true,
                  'issue': {
                    'id': 'issue-abc',
                    'identifier': 'ENG-42',
                    'url': 'https://linear.app/team/issue/ENG-42',
                  },
                },
              },
            }),
            200,
          ));

      await expectLater(backend.submit(testEntry), completes);
    });

    test('sends correct Authorization header and teamId', () async {
      final backend = LinearFeedbackBackend(
        apiKey: 'lin_api_secret',
        teamId: 'team-xyz',
        client: mockClient,
      );

      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((invocation) async {
        final headers =
            invocation.namedArguments[#headers] as Map<String, String>?;
        final bodyStr =
            invocation.namedArguments[#body] as String?;
        expect(headers?['Authorization'], equals('lin_api_secret'));
        expect(headers?['Content-Type'], equals('application/json'));

        if (bodyStr != null) {
          final parsed = jsonDecode(bodyStr) as Map<String, dynamic>;
          final variables =
              parsed['variables'] as Map<String, dynamic>;
          expect(variables['teamId'], equals('team-xyz'));
        }

        return http.Response(
          jsonEncode({
            'data': {
              'issueCreate': {'success': true, 'issue': null},
            },
          }),
          200,
        );
      });

      await backend.submit(testEntry);
      // If we reached here the headers/body assertions passed
    });

    test('includes projectId in variables when set', () async {
      final backend = LinearFeedbackBackend(
        apiKey: 'lin_api_test',
        teamId: 'team-123',
        projectId: 'project-999',
        client: mockClient,
      );

      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((invocation) async {
        final bodyStr =
            invocation.namedArguments[#body] as String?;
        if (bodyStr != null) {
          final parsed = jsonDecode(bodyStr) as Map<String, dynamic>;
          final variables =
              parsed['variables'] as Map<String, dynamic>;
          expect(variables['projectId'], equals('project-999'));
        }
        return http.Response(
          jsonEncode({
            'data': {
              'issueCreate': {'success': true, 'issue': null},
            },
          }),
          200,
        );
      });

      await backend.submit(testEntry);
    });

    test('title is truncated to 50 chars when message is long', () async {
      final longEntry = testEntry.copyWith(
        message: 'A' * 100,
      );

      final backend = LinearFeedbackBackend(
        apiKey: 'lin_api_test',
        teamId: 'team-123',
        client: mockClient,
      );

      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((invocation) async {
        final bodyStr =
            invocation.namedArguments[#body] as String?;
        if (bodyStr != null) {
          final parsed = jsonDecode(bodyStr) as Map<String, dynamic>;
          final variables =
              parsed['variables'] as Map<String, dynamic>;
          final title = variables['title'] as String;
          // "[Feedback] Bug: " = 17 chars, then 47 truncated + "..." = 50
          expect(title.endsWith('...'), isTrue);
          // Total title length: prefix + 50 = 17 + 50 = 67
          expect(title.length, lessThanOrEqualTo(70));
        }
        return http.Response(
          jsonEncode({
            'data': {
              'issueCreate': {'success': true, 'issue': null},
            },
          }),
          200,
        );
      });

      await backend.submit(longEntry);
    });

    test('throws LinearBackendException on HTTP error', () async {
      final backend = LinearFeedbackBackend(
        apiKey: 'lin_api_test',
        teamId: 'team-123',
        client: mockClient,
      );

      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response('Unauthorized', 401));

      await expectLater(
        backend.submit(testEntry),
        throwsA(isA<LinearBackendException>()),
      );
    });

    test('throws LinearBackendException on GraphQL errors field', () async {
      final backend = LinearFeedbackBackend(
        apiKey: 'lin_api_test',
        teamId: 'team-123',
        client: mockClient,
      );

      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode({
              'errors': [
                {'message': 'Authentication required'},
              ],
            }),
            200,
          ));

      await expectLater(
        backend.submit(testEntry),
        throwsA(
          isA<LinearBackendException>().having(
            (e) => e.message,
            'message',
            contains('Authentication required'),
          ),
        ),
      );
    });

    test('throws LinearBackendException when success=false', () async {
      final backend = LinearFeedbackBackend(
        apiKey: 'lin_api_test',
        teamId: 'team-123',
        client: mockClient,
      );

      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode({
              'data': {
                'issueCreate': {'success': false},
              },
            }),
            200,
          ));

      await expectLater(
        backend.submit(testEntry),
        throwsA(isA<LinearBackendException>()),
      );
    });
  });

  group('LinearFeedbackBackend.dispose', () {
    test('closes the HTTP client', () {
      final backend = LinearFeedbackBackend(
        apiKey: 'lin_api_test',
        teamId: 'team-123',
        client: mockClient,
      );

      when(() => mockClient.close()).thenReturn(null);
      backend.dispose();
      verify(() => mockClient.close()).called(1);
    });
  });

  group('LinearBackendException', () {
    test('toString includes message', () {
      const ex = LinearBackendException('something went wrong');
      expect(ex.toString(), contains('something went wrong'));
    });
  });
}
