import 'dart:convert';

import 'package:flutter_feedback_kit/flutter_feedback_kit.dart';
import 'package:flutter_feedback_kit_email/flutter_feedback_kit_email.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class _MockClient extends Mock implements http.Client {}

void main() {
  late _MockClient client;

  final entry = FeedbackEntry(
    category: FeedbackCategory.suggestion,
    message: 'Add dark mode please',
    platform: 'ios',
    appVersion: '2.0.0',
    createdAt: DateTime(2026, 4, 22),
  );

  setUp(() {
    client = _MockClient();
    registerFallbackValue(Uri());
  });

  EmailFeedbackBackend makeBackend({
    String Function(FeedbackEntry)? subjectBuilder,
  }) =>
      EmailFeedbackBackend(
        apiKey: 'SG.test_key',
        fromEmail: 'noreply@test.com',
        toEmail: 'support@test.com',
        client: client,
        subjectBuilder: subjectBuilder,
      );

  test('submit POSTs to SendGrid v3 endpoint', () async {
    when(() => client.post(any(),
            headers: any(named: 'headers'),
            body: any(named: 'body')))
        .thenAnswer((_) async => http.Response('', 202));

    await makeBackend().submit(entry);

    final captured = verify(() => client.post(
          captureAny(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        )).captured;

    final uri = captured.first as Uri;
    expect(uri.toString(), 'https://api.sendgrid.com/v3/mail/send');
  });

  test('submit sends correct Authorization header', () async {
    when(() => client.post(any(),
            headers: any(named: 'headers'),
            body: any(named: 'body')))
        .thenAnswer((_) async => http.Response('', 202));

    await makeBackend().submit(entry);

    final captured = verify(() => client.post(
          any(),
          headers: captureAny(named: 'headers'),
          body: any(named: 'body'),
        )).captured;

    final headers = captured.first as Map<String, String>;
    expect(headers['Authorization'], 'Bearer SG.test_key');
  });

  test('default subject includes category and app version', () async {
    when(() => client.post(any(),
            headers: any(named: 'headers'),
            body: any(named: 'body')))
        .thenAnswer((_) async => http.Response('', 202));

    await makeBackend().submit(entry);

    final captured = verify(() => client.post(
          any(),
          headers: any(named: 'headers'),
          body: captureAny(named: 'body'),
        )).captured;

    final body =
        jsonDecode(captured.first as String) as Map<String, dynamic>;
    final personalisation =
        (body['personalizations'] as List).first as Map<String, dynamic>;
    expect(personalisation['subject'], contains('[Feedback]'));
    expect(personalisation['subject'], contains('suggestion'));
    expect(personalisation['subject'], contains('2.0.0'));
  });

  test('custom subjectBuilder overrides default', () async {
    when(() => client.post(any(),
            headers: any(named: 'headers'),
            body: any(named: 'body')))
        .thenAnswer((_) async => http.Response('', 202));

    await makeBackend(subjectBuilder: (_) => 'My Subject').submit(entry);

    final captured = verify(() => client.post(
          any(),
          headers: any(named: 'headers'),
          body: captureAny(named: 'body'),
        )).captured;

    final body =
        jsonDecode(captured.first as String) as Map<String, dynamic>;
    final personalisation =
        (body['personalizations'] as List).first as Map<String, dynamic>;
    expect(personalisation['subject'], 'My Subject');
  });

  test('submit throws EmailFeedbackException on non-202 response', () async {
    when(() => client.post(any(),
            headers: any(named: 'headers'),
            body: any(named: 'body')))
        .thenAnswer((_) async => http.Response('Unauthorized', 401));

    expect(
      () => makeBackend().submit(entry),
      throwsA(isA<EmailFeedbackException>()),
    );
  });

  test('body contains both text/plain and text/html content types', () async {
    when(() => client.post(any(),
            headers: any(named: 'headers'),
            body: any(named: 'body')))
        .thenAnswer((_) async => http.Response('', 202));

    await makeBackend().submit(entry);

    final captured = verify(() => client.post(
          any(),
          headers: any(named: 'headers'),
          body: captureAny(named: 'body'),
        )).captured;

    final body =
        jsonDecode(captured.first as String) as Map<String, dynamic>;
    final content = body['content'] as List;
    final types = content
        .cast<Map<String, dynamic>>()
        .map((c) => c['type'] as String)
        .toList();
    expect(types, contains('text/plain'));
    expect(types, contains('text/html'));
  });

  test('dispose closes the HTTP client', () {
    when(() => client.close()).thenReturn(null);
    makeBackend().dispose();
    verify(() => client.close()).called(1);
  });
}
