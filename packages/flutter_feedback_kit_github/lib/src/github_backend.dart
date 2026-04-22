import 'dart:convert';

import 'package:flutter_feedback_kit/flutter_feedback_kit.dart';
import 'package:http/http.dart' as http;

/// [FeedbackBackend] that creates GitHub Issues from feedback entries.
///
/// Uses the [GitHub REST API v3](https://docs.github.com/en/rest/issues/issues)
/// with a Personal Access Token (PAT) or a fine-grained token scoped to
/// `issues: write` on the target repository.
///
/// **Setup:**
/// 1. Add `flutter_feedback_kit_github` to your `pubspec.yaml`.
/// 2. Create a PAT at **GitHub → Settings → Developer settings → Personal access tokens**.
///    Grant `repo` (classic token) or `issues: write` (fine-grained token).
/// 3. **Never hard-code the token** — load it from remote config or a secure
///    server-side proxy to avoid credential exposure in the APK/IPA binary.
///
/// ```dart
/// FeedbackButton(
///   backend: GitHubFeedbackBackend(
///     owner: 'my-org',
///     repo: 'my-app',
///     token: remoteConfig.githubToken, // loaded at runtime
///   ),
///   appVersion: '1.0.0',
/// )
/// ```
///
/// **Security note:** shipping a GitHub token in a mobile app binary is
/// generally unsafe. Consider routing submissions through a server-side
/// function (e.g. Vercel Edge, Cloudflare Worker) that holds the token and
/// forwards only validated requests to the GitHub API.
class GitHubFeedbackBackend implements FeedbackBackend {
  /// Creates a [GitHubFeedbackBackend].
  ///
  /// - [owner]: GitHub user or organisation name.
  /// - [repo]: Repository name.
  /// - [token]: GitHub Personal Access Token with `issues: write` permission.
  /// - [labels]: Labels to attach to every created issue. Default: `['feedback']`.
  /// - [titleBuilder]: Custom issue title factory. When `null`, a default
  ///   title of the form `[Feedback] <category> — <first 60 chars of message>`
  ///   is used.
  /// - [bodyBuilder]: Custom issue body factory. When `null`, a Markdown body
  ///   with all entry fields is generated automatically.
  /// - [client]: Optional [http.Client] override for testing.
  GitHubFeedbackBackend({
    required this.owner,
    required this.repo,
    required this.token,
    this.labels = const ['feedback'],
    this.titleBuilder,
    this.bodyBuilder,
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// GitHub user or organisation that owns the repository.
  final String owner;

  /// Repository name where issues are created.
  final String repo;

  /// GitHub Personal Access Token with `issues: write` permission.
  ///
  /// Load this value from a remote config or a server-side proxy — never
  /// embed it directly in the application binary.
  final String token;

  /// Labels attached to every created issue. Default: `['feedback']`.
  final List<String> labels;

  /// Optional factory that builds the issue title from a [FeedbackEntry].
  final String Function(FeedbackEntry)? titleBuilder;

  /// Optional factory that builds the issue body (Markdown) from a [FeedbackEntry].
  final String Function(FeedbackEntry)? bodyBuilder;

  final http.Client _client;

  static const _apiBase = 'https://api.github.com';

  @override
  Future<void> submit(FeedbackEntry entry) async {
    final uri = Uri.parse('$_apiBase/repos/$owner/$repo/issues');

    final title = titleBuilder?.call(entry) ?? _defaultTitle(entry);
    final body = bodyBuilder?.call(entry) ?? _defaultBody(entry);

    final payload = <String, dynamic>{
      'title': title,
      'body': body,
      if (labels.isNotEmpty) 'labels': labels,
    };

    final response = await _client.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode != 201) {
      throw GitHubFeedbackException(
        'GitHub API returned ${response.statusCode}',
      );
    }
  }

  @override
  void dispose() => _client.close();

  // ─── Default formatters ───────────────────────────────────────────────────

  String _defaultTitle(FeedbackEntry entry) {
    final preview = entry.message.length > 60
        ? '${entry.message.substring(0, 60)}…'
        : entry.message;
    return '[Feedback] ${entry.category} — $preview';
  }

  String _defaultBody(FeedbackEntry entry) {
    final buf = StringBuffer();
    buf.writeln('## Feedback');
    buf.writeln();
    buf.writeln('| Field | Value |');
    buf.writeln('|-------|-------|');
    buf.writeln('| Category | `${entry.category}` |');
    buf.writeln('| Platform | `${entry.platform}` |');
    buf.writeln('| App version | `${entry.appVersion}` |');
    buf.writeln('| Created at | `${entry.createdAt.toIso8601String()}` |');
    if (entry.rating != null) {
      buf.writeln('| Rating | ${entry.rating}/5 |');
    }
    if (entry.npsScore != null) {
      buf.writeln('| NPS | ${entry.npsScore}/10 |');
    }

    buf.writeln();
    buf.writeln('### Message');
    buf.writeln();
    buf.writeln(entry.message);

    final meta = entry.metadata;
    if (meta != null) {
      buf.writeln();
      buf.writeln('### Device');
      buf.writeln();
      buf.writeln('| Field | Value |');
      buf.writeln('|-------|-------|');
      if (meta.osName != null) buf.writeln('| OS | `${meta.osName} ${meta.osVersion ?? ''}` |');
      if (meta.deviceModel != null) buf.writeln('| Device | `${meta.deviceModel}` |');
      if (meta.appName != null) buf.writeln('| App | `${meta.appName} (build ${meta.buildNumber ?? '?'})` |');
    }

    final ctx = entry.sessionContext;
    if (ctx != null) {
      buf.writeln();
      buf.writeln('### Session');
      buf.writeln();
      if (ctx.userId != null) buf.writeln('- **User:** `${ctx.userId}`');
      if (ctx.currentRoute != null) buf.writeln('- **Route:** `${ctx.currentRoute}`');
      for (final kv in ctx.extra.entries) {
        buf.writeln('- **${kv.key}:** `${kv.value}`');
      }
    }

    if (entry.screenshots.isNotEmpty) {
      buf.writeln();
      buf.writeln(
        '> **Note:** ${entry.screenshots.length} screenshot(s) attached '
        '(base64-encoded, stripped from issue body to keep it readable).',
      );
    }

    return buf.toString();
  }
}

/// Thrown by [GitHubFeedbackBackend.submit] when the API returns a non-201 response.
class GitHubFeedbackException implements Exception {
  /// Creates a [GitHubFeedbackException] with the given [message].
  const GitHubFeedbackException(this.message);

  /// Human-readable description of the failure.
  final String message;

  @override
  String toString() => 'GitHubFeedbackException: $message';
}
