import 'dart:convert';

import 'package:flutter_feedback_kit/flutter_feedback_kit.dart';
import 'package:http/http.dart' as http;

/// [FeedbackBackend] that creates issues in the [Linear](https://linear.app)
/// issue tracker via the Linear GraphQL API.
///
/// **Setup:**
/// 1. Add `flutter_feedback_kit_linear` to your `pubspec.yaml`.
/// 2. Create a Linear API key at **Settings → API → Personal API keys**.
/// 3. Find your Team ID and (optionally) Project ID from the Linear app or API.
///
/// ```dart
/// FeedbackButton(
///   backend: LinearFeedbackBackend(
///     apiKey: 'lin_api_xxxx',
///     teamId: 'team-uuid',
///   ),
///   appVersion: '1.0.0',
/// )
/// ```
class LinearFeedbackBackend implements FeedbackBackend {
  /// Creates a [LinearFeedbackBackend].
  ///
  /// [apiKey] — Linear personal API key (required).
  /// [teamId] — Linear team ID where issues will be created (required).
  /// [projectId] — Optional Linear project ID to assign issues to.
  /// [client] — Optional [http.Client] override for testing.
  LinearFeedbackBackend({
    required this.apiKey,
    required this.teamId,
    this.projectId,
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// Linear personal API key (e.g. `'lin_api_xxxx...'`).
  final String apiKey;

  /// Linear team ID. Issues are created in this team.
  final String teamId;

  /// Optional Linear project ID. When set, issues are associated with
  /// the given project.
  final String? projectId;

  static const _graphqlEndpoint = 'https://api.linear.app/graphql';

  final http.Client _client;

  @override
  Future<void> submit(FeedbackEntry entry) async {
    final title = _buildTitle(entry);
    final description = _buildDescription(entry);

    final variables = <String, dynamic>{
      'title': title,
      'description': description,
      'teamId': teamId,
      if (projectId != null) 'projectId': projectId,
    };

    const mutation = r'''
      mutation CreateIssue(
        $title: String!,
        $description: String,
        $teamId: String!,
        $projectId: String,
      ) {
        issueCreate(input: {
          title: $title,
          description: $description,
          teamId: $teamId,
          projectId: $projectId,
        }) {
          success
          issue {
            id
            identifier
            url
          }
        }
      }
    ''';

    final response = await _client.post(
      Uri.parse(_graphqlEndpoint),
      headers: {
        'Authorization': apiKey,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'query': mutation,
        'variables': variables,
      }),
    );

    if (response.statusCode != 200) {
      throw LinearBackendException(
        'Linear API returned HTTP ${response.statusCode}: ${response.body}',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (body.containsKey('errors')) {
      final errors = body['errors'] as List<dynamic>;
      final messages = errors
          .map((e) => (e as Map<String, dynamic>)['message'] as String? ?? '')
          .join('; ');
      throw LinearBackendException('Linear GraphQL error: $messages');
    }

    final issueCreate =
        (body['data'] as Map<String, dynamic>?)?['issueCreate']
            as Map<String, dynamic>?;
    final success = issueCreate?['success'] as bool? ?? false;

    if (!success) {
      throw LinearBackendException(
        'Linear issueCreate returned success=false. Response: ${response.body}',
      );
    }
  }

  @override
  void dispose() => _client.close();

  /// Builds a short issue title from [entry].
  ///
  /// Format: `[Feedback] {Category}: {message truncated to 50 chars}`
  String _buildTitle(FeedbackEntry entry) {
    final category = _capitalise(entry.category);
    final truncated = entry.message.length > 50
        ? '${entry.message.substring(0, 47)}...'
        : entry.message;
    return '[Feedback] $category: $truncated';
  }

  /// Builds a Markdown description for the Linear issue from [entry].
  String _buildDescription(FeedbackEntry entry) {
    final buf = StringBuffer();

    buf.writeln('## Feedback');
    buf.writeln();
    buf.writeln(entry.message);
    buf.writeln();

    buf.writeln('## Details');
    buf.writeln();
    buf.writeln('| Field | Value |');
    buf.writeln('|-------|-------|');
    buf.writeln('| Category | ${entry.category} |');
    buf.writeln('| Platform | ${entry.platform} |');
    buf.writeln('| App version | ${entry.appVersion} |');
    buf.writeln('| Submitted at | ${entry.createdAt.toIso8601String()} |');

    if (entry.rating != null) {
      buf.writeln('| Rating | ${entry.rating}/5 |');
    }
    if (entry.npsScore != null) {
      buf.writeln('| NPS score | ${entry.npsScore}/10 |');
    }

    final meta = entry.metadata;
    if (meta != null) {
      buf.writeln();
      buf.writeln('## Device info');
      buf.writeln();
      buf.writeln('| Field | Value |');
      buf.writeln('|-------|-------|');
      if (meta.deviceModel != null) {
        buf.writeln('| Device | ${meta.deviceModel} |');
      }
      if (meta.osName != null) {
        buf.writeln('| OS | ${meta.osName} ${meta.osVersion ?? ''} |'.trim());
      }
      if (meta.appName != null) {
        buf.writeln('| App name | ${meta.appName} |');
      }
      if (meta.buildNumber != null) {
        buf.writeln('| Build number | ${meta.buildNumber} |');
      }
      if (meta.extra.isNotEmpty) {
        buf.writeln();
        buf.writeln('**Extra metadata:**');
        buf.writeln();
        for (final kv in meta.extra.entries) {
          buf.writeln('- **${kv.key}**: ${kv.value}');
        }
      }
    }

    final ctx = entry.sessionContext;
    if (ctx != null) {
      buf.writeln();
      buf.writeln('## Session context');
      buf.writeln();
      final json = ctx.toJson();
      for (final kv in json.entries) {
        buf.writeln('- **${kv.key}**: ${kv.value}');
      }
    }

    return buf.toString();
  }

  String _capitalise(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}

/// Exception thrown by [LinearFeedbackBackend] when an API call fails.
class LinearBackendException implements Exception {
  /// Creates a [LinearBackendException] with the given [message].
  const LinearBackendException(this.message);

  /// Human-readable error description.
  final String message;

  @override
  String toString() => 'LinearBackendException: $message';
}
