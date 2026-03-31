import 'dart:convert';

import 'package:flutter_feedback_kit/flutter_feedback_kit.dart';
import 'package:http/http.dart' as http;

/// [FeedbackBackend] that creates Jira Cloud issues from feedback entries.
///
/// Uses the Jira REST API v3 with Basic Authentication (email + API token).
///
/// **Setup:**
/// 1. Add `flutter_feedback_kit_jira` to your `pubspec.yaml`.
/// 2. Generate a Jira API token at https://id.atlassian.com/manage/api-tokens.
/// 3. **Never hard-code** the API token — load it from a remote config or
///    environment variable to avoid committing credentials.
///
/// ```dart
/// FeedbackButton(
///   backend: JiraFeedbackBackend(
///     domain: 'mycompany.atlassian.net',
///     email: 'ci-bot@mycompany.com',
///     apiToken: remoteConfig.jiraToken,
///     projectKey: 'APP',
///   ),
///   appVersion: '1.0.0',
/// )
/// ```
class JiraFeedbackBackend implements FeedbackBackend {
  /// Creates a [JiraFeedbackBackend].
  ///
  /// [domain] — Atlassian domain, e.g. `'mycompany.atlassian.net'`.
  /// [email] — Account email used for Basic Auth.
  /// [apiToken] — Jira API token (not account password).
  /// [projectKey] — Jira project key, e.g. `'APP'`.
  /// [issueType] — Issue type name. Default: `'Bug'`.
  /// [labelPrefix] — Optional prefix added to category labels on the issue.
  JiraFeedbackBackend({
    required this.domain,
    required this.email,
    required this.apiToken,
    required this.projectKey,
    this.issueType = 'Bug',
    this.labelPrefix = 'feedback',
    http.Client? httpClient,
  }) : _client = httpClient ?? http.Client();

  final String domain;
  final String email;
  final String apiToken;
  final String projectKey;

  /// Jira issue type name. Default: `'Bug'`.
  final String issueType;

  /// Label prefix added alongside the category. Default: `'feedback'`.
  final String labelPrefix;

  final http.Client _client;

  @override
  Future<void> submit(FeedbackEntry entry) async {
    final summaryText = entry.message.length > 80
        ? entry.message.substring(0, 77) + '...'
        : entry.message;
    final summary = '[${entry.category.label}] $summaryText';

    final description = _buildDescription(entry);

    final payload = {
      'fields': {
        'project': {'key': projectKey},
        'summary': summary,
        'description': description,
        'issuetype': {'name': issueType},
        'labels': [labelPrefix, entry.category.name],
      },
    };

    final credentials =
        base64.encode(utf8.encode('$email:$apiToken'));

    final response = await _client.post(
      Uri.https(domain, '/rest/api/3/issue'),
      headers: {
        'Authorization': 'Basic $credentials',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode != 201) {
      throw JiraBackendException(
        'Failed to create Jira issue: HTTP ${response.statusCode}',
      );
    }
  }

  Map<String, dynamic> _buildDescription(FeedbackEntry entry) => {
        'type': 'doc',
        'version': 1,
        'content': [
          _paragraph('Category: ${entry.category.label}'),
          _paragraph('Platform: ${entry.platform}  |  Version: ${entry.appVersion}'),
          if (entry.sessionContext?.userId != null)
            _paragraph('User: ${entry.sessionContext!.userId}'),
          if (entry.sessionContext?.currentRoute != null)
            _paragraph('Route: ${entry.sessionContext!.currentRoute}'),
          _paragraph(''),
          _paragraph(entry.message),
          if (entry.rating != null)
            _paragraph('Satisfaction rating: ${entry.rating}/5'),
          if (entry.npsScore != null)
            _paragraph('NPS score: ${entry.npsScore}/10'),
          if (entry.screenshots.isNotEmpty)
            _paragraph(
                'Screenshots: ${entry.screenshots.length} image(s) attached (base64)'),
        ],
      };

  Map<String, dynamic> _paragraph(String text) => {
        'type': 'paragraph',
        'content': [
          {'type': 'text', 'text': text},
        ],
      };

  @override
  void dispose() => _client.close();
}

/// Thrown by [JiraFeedbackBackend.submit] on non-201 responses.
class JiraBackendException implements Exception {
  const JiraBackendException(this.message);
  final String message;
  @override
  String toString() => 'JiraBackendException: $message';
}
