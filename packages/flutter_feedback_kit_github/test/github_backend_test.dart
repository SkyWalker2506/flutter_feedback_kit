import 'dart:convert';

import 'package:flutter_feedback_kit/flutter_feedback_kit.dart';
import 'package:flutter_feedback_kit_github/flutter_feedback_kit_github.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class _MockClient extends Mock implements http.Client {}

void main() {
  late _MockClient client;

  final entry = FeedbackEntry(
    category: FeedbackCategory.bug,
    message: 'App crashes on launch',
    platform: 'android',
    appVersion: '1.0.0',
    createdAt: DateTime(2026, 4, 22),
  );

  setUp(() {
    client = _MockClient();
    registerFallbackValue(Uri());
  });

  GitHubFeedbackBackend makeBackend({
    String Function(FeedbackEntry)? titleBuilder,
    String Function(FeedbackEntry)? bodyBuilder,
  }) =>
      GitHubFeedbackBackend(
        owner: 'test-owner',
        repo: 'test-repo',
        token: 'ghp_test_token',
        client: client,
        titleBuilder: titleBuilder,
        bodyBuilder: bodyBuilder,
      );

  test('submit posts to correct GitHub API URL', () async {
    when(() => client.post(any(),
            headers: any(named: 'headers'),
            body: any(named: 'body')))
        .thenAnswer(
      (_) async => http.Response('{"number":1}', 201),
    );

    await makeBackend().submit(entry);

    final captured = verify(() => client.post(
          captureAny(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        )).captured;

    final uri = captured.first as Uri;
    expect(uri.toString(),
        'https://api.github.com/repos/test-owner/test-repo/issues');
  });

  test('submit sends correct Authorization header', () async {
    when(() => client.post(any(),
            headers: any(named: 'headers'),
            body: any(named: 'body')))
        .thenAnswer((_) async => http.Response('{"number":1}', 201));

    await makeBackend().submit(entry);

    final captured = verify(() => client.post(
          any(),
          headers: captureAny(named: 'headers'),
          body: any(named: 'body'),
        )).captured;

    final headers = captured.first as Map<String, String>;
    expect(headers['Authorization'], 'Bearer ghp_test_token');
    expect(headers['Accept'], 'application/vnd.github+json');
  });

  test('submit uses default title format', () async {
    when(() => client.post(any(),
            headers: any(named: 'headers'),
            body: any(named: 'body')))
        .thenAnswer((_) async => http.Response('{"number":1}', 201));

    await makeBackend().submit(entry);

    final captured = verify(() => client.post(
          any(),
          headers: any(named: 'headers'),
          body: captureAny(named: 'body'),
        )).captured;

    final body = jsonDecode(captured.first as String) as Map<String, dynamic>;
    expect(body['title'], contains('[Feedback]'));
    expect(body['title'], contains('bug'));
  });

  test('submit uses custom titleBuilder when provided', () async {
    when(() => client.post(any(),
            headers: any(named: 'headers'),
            body: any(named: 'body')))
        .thenAnswer((_) async => http.Response('{"number":1}', 201));

    await makeBackend(titleBuilder: (_) => 'Custom Title').submit(entry);

    final captured = verify(() => client.post(
          any(),
          headers: any(named: 'headers'),
          body: captureAny(named: 'body'),
        )).captured;

    final body = jsonDecode(captured.first as String) as Map<String, dynamic>;
    expect(body['title'], 'Custom Title');
  });

  test('submit throws GitHubFeedbackException on non-201 response', () async {
    when(() => client.post(any(),
            headers: any(named: 'headers'),
            body: any(named: 'body')))
        .thenAnswer((_) async => http.Response('{"message":"Not Found"}', 404));

    expect(
      () => makeBackend().submit(entry),
      throwsA(isA<GitHubFeedbackException>()),
    );
  });

  test('default body includes category, platform, and message', () async {
    when(() => client.post(any(),
            headers: any(named: 'headers'),
            body: any(named: 'body')))
        .thenAnswer((_) async => http.Response('{"number":1}', 201));

    await makeBackend().submit(entry);

    final captured = verify(() => client.post(
          any(),
          headers: any(named: 'headers'),
          body: captureAny(named: 'body'),
        )).captured;

    final body = jsonDecode(captured.first as String) as Map<String, dynamic>;
    final issueBody = body['body'] as String;
    expect(issueBody, contains('bug'));
    expect(issueBody, contains('android'));
    expect(issueBody, contains('App crashes on launch'));
  });

  test('dispose closes the HTTP client', () {
    when(() => client.close()).thenReturn(null);
    makeBackend().dispose();
    verify(() => client.close()).called(1);
  });
}
