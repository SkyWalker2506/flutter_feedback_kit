import 'dart:convert';

import 'package:flutter_feedback_kit/flutter_feedback_kit.dart';
import 'package:http/http.dart' as http;

/// [FeedbackBackend] that delivers feedback entries as emails via the
/// [SendGrid v3 Mail Send API](https://docs.sendgrid.com/api-reference/mail-send/mail-send).
///
/// Each submission constructs a plain-text and HTML email containing the
/// feedback details and sends it to the configured recipient address.
///
/// **Setup:**
/// 1. Add `flutter_feedback_kit_email` to your `pubspec.yaml`.
/// 2. Create a SendGrid API key at **sendgrid.com → Settings → API Keys**.
///    Grant **Mail Send** permission only.
/// 3. **Never hard-code the API key** in the application binary. Load it
///    from a server-side function or remote config to avoid credential exposure.
///
/// ```dart
/// FeedbackButton(
///   backend: EmailFeedbackBackend(
///     apiKey: remoteConfig.sendgridKey, // loaded at runtime
///     fromEmail: 'noreply@myapp.com',
///     fromName: 'MyApp Feedback',
///     toEmail: 'support@myapp.com',
///   ),
///   appVersion: '1.0.0',
/// )
/// ```
class EmailFeedbackBackend implements FeedbackBackend {
  /// Creates an [EmailFeedbackBackend].
  ///
  /// - [apiKey]: SendGrid API key with **Mail Send** permission.
  /// - [fromEmail]: Verified sender email address.
  /// - [toEmail]: Recipient email address for feedback notifications.
  /// - [fromName]: Display name for the sender. Default: `'App Feedback'`.
  /// - [subjectBuilder]: Custom subject line factory. When `null`, a default
  ///   of `[Feedback] <category> — <app version>` is used.
  /// - [bodyBuilder]: Custom plain-text body factory. When `null`, a default
  ///   body with all entry fields is generated.
  /// - [htmlBodyBuilder]: Custom HTML body factory. When `null`, an HTML
  ///   version of the default body is generated.
  /// - [client]: Optional [http.Client] override for testing.
  EmailFeedbackBackend({
    required this.apiKey,
    required this.fromEmail,
    required this.toEmail,
    this.fromName = 'App Feedback',
    this.subjectBuilder,
    this.bodyBuilder,
    this.htmlBodyBuilder,
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// SendGrid API key with **Mail Send** permission.
  final String apiKey;

  /// Verified sender email address registered in SendGrid.
  final String fromEmail;

  /// Display name for the from address. Default: `'App Feedback'`.
  final String fromName;

  /// Destination email address that receives the feedback notifications.
  final String toEmail;

  /// Optional factory that builds the email subject from a [FeedbackEntry].
  final String Function(FeedbackEntry)? subjectBuilder;

  /// Optional factory that builds the plain-text email body.
  final String Function(FeedbackEntry)? bodyBuilder;

  /// Optional factory that builds the HTML email body.
  final String Function(FeedbackEntry)? htmlBodyBuilder;

  final http.Client _client;

  static const _sendGridEndpoint =
      'https://api.sendgrid.com/v3/mail/send';

  @override
  Future<void> submit(FeedbackEntry entry) async {
    final subject = subjectBuilder?.call(entry) ?? _defaultSubject(entry);
    final text = bodyBuilder?.call(entry) ?? _defaultTextBody(entry);
    final html = htmlBodyBuilder?.call(entry) ?? _defaultHtmlBody(entry);

    final payload = {
      'personalizations': [
        {
          'to': [
            {'email': toEmail}
          ],
          'subject': subject,
        }
      ],
      'from': {'email': fromEmail, 'name': fromName},
      'content': [
        {'type': 'text/plain', 'value': text},
        {'type': 'text/html', 'value': html},
      ],
    };

    final response = await _client.post(
      Uri.parse(_sendGridEndpoint),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    // SendGrid returns 202 Accepted on success
    if (response.statusCode != 202) {
      throw EmailFeedbackException(
        'SendGrid API returned ${response.statusCode}',
      );
    }
  }

  @override
  void dispose() => _client.close();

  // ─── Default formatters ───────────────────────────────────────────────────

  String _defaultSubject(FeedbackEntry entry) =>
      '[Feedback] ${entry.category} — v${entry.appVersion}';

  String _defaultTextBody(FeedbackEntry entry) {
    final buf = StringBuffer();
    buf.writeln('FEEDBACK REPORT');
    buf.writeln('===============');
    buf.writeln('Category:    ${entry.category}');
    buf.writeln('Platform:    ${entry.platform}');
    buf.writeln('App version: ${entry.appVersion}');
    buf.writeln('Created at:  ${entry.createdAt.toIso8601String()}');
    if (entry.rating != null) buf.writeln('Rating:      ${entry.rating}/5');
    if (entry.npsScore != null) buf.writeln('NPS:         ${entry.npsScore}/10');
    buf.writeln();
    buf.writeln('MESSAGE');
    buf.writeln('-------');
    buf.writeln(entry.message);

    final meta = entry.metadata;
    if (meta != null) {
      buf.writeln();
      buf.writeln('DEVICE');
      buf.writeln('------');
      if (meta.osName != null) buf.writeln('OS: ${meta.osName} ${meta.osVersion ?? ''}');
      if (meta.deviceModel != null) buf.writeln('Device: ${meta.deviceModel}');
      if (meta.appName != null) {
        buf.writeln('App: ${meta.appName} (build ${meta.buildNumber ?? '?'})');
      }
    }

    final ctx = entry.sessionContext;
    if (ctx != null) {
      buf.writeln();
      buf.writeln('SESSION');
      buf.writeln('-------');
      if (ctx.userId != null) buf.writeln('User: ${ctx.userId}');
      if (ctx.currentRoute != null) buf.writeln('Route: ${ctx.currentRoute}');
      for (final kv in ctx.extra.entries) {
        buf.writeln('${kv.key}: ${kv.value}');
      }
    }

    if (entry.screenshots.isNotEmpty) {
      buf.writeln();
      buf.writeln(
          '${entry.screenshots.length} screenshot(s) attached (base64, not included in email).');
    }

    return buf.toString();
  }

  String _defaultHtmlBody(FeedbackEntry entry) {
    final rows = StringBuffer();

    void row(String label, String value) {
      rows.writeln(
          '<tr><td style="padding:4px 8px;font-weight:bold">$label</td>'
          '<td style="padding:4px 8px">$value</td></tr>');
    }

    row('Category', entry.category);
    row('Platform', entry.platform);
    row('App version', entry.appVersion);
    row('Created at', entry.createdAt.toIso8601String());
    if (entry.rating != null) row('Rating', '${entry.rating}/5');
    if (entry.npsScore != null) row('NPS', '${entry.npsScore}/10');

    final meta = entry.metadata;
    if (meta != null) {
      if (meta.osName != null) {
        row('OS', '${meta.osName} ${meta.osVersion ?? ''}');
      }
      if (meta.deviceModel != null) row('Device', meta.deviceModel!);
      if (meta.appName != null) {
        row('App', '${meta.appName} (build ${meta.buildNumber ?? '?'})');
      }
    }

    final ctx = entry.sessionContext;
    if (ctx != null) {
      if (ctx.userId != null) row('User', ctx.userId!);
      if (ctx.currentRoute != null) row('Route', ctx.currentRoute!);
      for (final kv in ctx.extra.entries) {
        row(kv.key, kv.value.toString());
      }
    }

    final message = entry.message
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('\n', '<br>');

    return '''
<html>
<body style="font-family:sans-serif;color:#333;max-width:600px">
  <h2 style="color:#1a73e8">Feedback Report</h2>
  <table style="border-collapse:collapse;width:100%">
    $rows
  </table>
  <h3>Message</h3>
  <p style="background:#f5f5f5;padding:12px;border-radius:4px">$message</p>
  ${entry.screenshots.isNotEmpty ? '<p><em>${entry.screenshots.length} screenshot(s) not included in email body.</em></p>' : ''}
</body>
</html>''';
  }
}

/// Thrown by [EmailFeedbackBackend.submit] when SendGrid returns a non-202 status.
class EmailFeedbackException implements Exception {
  /// Creates an [EmailFeedbackException] with the given [message].
  const EmailFeedbackException(this.message);

  /// Human-readable description of the failure.
  final String message;

  @override
  String toString() => 'EmailFeedbackException: $message';
}
