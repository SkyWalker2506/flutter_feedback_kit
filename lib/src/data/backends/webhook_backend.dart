import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/entities/feedback_entry.dart';
import '../../domain/repositories/feedback_backend.dart';

/// A [FeedbackBackend] that POSTs feedback as JSON to an HTTPS webhook URL.
///
/// Compatible with Slack incoming webhooks, Discord webhooks, n8n, Zapier,
/// Make, and any custom HTTP endpoint.
///
/// ```dart
/// final backend = WebhookBackend(
///   url: 'https://hooks.slack.com/services/...',
///   payloadBuilder: (entry) => {
///     'text': '*${entry.category.label}* — ${entry.message}',
///   },
/// );
/// ```
class WebhookBackend implements FeedbackBackend {
  /// Creates a [WebhookBackend].
  ///
  /// The [url] **must** use the `https` scheme. Passing an `http` URL throws
  /// an [ArgumentError] immediately to prevent accidental plaintext leaks.
  WebhookBackend({
    required this.url,
    this.headers = const {},
    this.payloadBuilder,
    this.timeout = const Duration(seconds: 15),
    http.Client? httpClient,
  }) : _client = httpClient ?? http.Client() {
    if (Uri.parse(url).scheme != 'https') {
      throw ArgumentError.value(
          url, 'url', 'WebhookBackend requires an HTTPS URL');
    }
  }

  /// The HTTPS endpoint that receives the feedback payload.
  final String url;

  /// Additional HTTP headers merged with `Content-Type: application/json`.
  final Map<String, String> headers;

  /// Optional factory that builds a custom JSON payload from [FeedbackEntry].
  ///
  /// When `null`, a default payload containing all entry fields is used.
  final Map<String, dynamic> Function(FeedbackEntry)? payloadBuilder;

  /// Request timeout. Default: 15 seconds.
  final Duration timeout;

  final http.Client _client;

  @override
  Future<void> submit(FeedbackEntry entry) async {
    final payload = payloadBuilder?.call(entry) ?? _defaultPayload(entry);

    final response = await _client
        .post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json', ...headers},
          body: jsonEncode(payload),
        )
        .timeout(timeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw WebhookException(
        'Webhook failed with status ${response.statusCode}',
      );
    }
  }

  /// Closes the underlying HTTP client.
  @override
  void dispose() => _client.close();

  Map<String, dynamic> _defaultPayload(FeedbackEntry entry) => {
        'category': entry.category.label,
        'message': entry.message,
        'platform': entry.platform,
        'appVersion': entry.appVersion,
        'createdAt': entry.createdAt.toIso8601String(),
        'screenshots': entry.screenshots,
      };
}

/// Thrown by [WebhookBackend.submit] when the server returns a non-2xx status.
class WebhookException implements Exception {
  /// Creates a [WebhookException] with the given [message].
  const WebhookException(this.message);

  /// Human-readable description of the failure.
  ///
  /// The HTTP response body is intentionally excluded to avoid leaking
  /// sensitive server information.
  final String message;

  @override
  String toString() => 'WebhookException: $message';
}
