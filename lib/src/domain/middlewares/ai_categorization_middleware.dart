import 'dart:convert';

import 'package:http/http.dart' as http;

import '../entities/feedback_category.dart';
import '../entities/feedback_entry.dart';
import '../feedback_middleware.dart';

/// A middleware that uses the Claude API to auto-suggest a feedback category.
///
/// When an [apiKey] is supplied and the [FeedbackEntry] does not already have
/// a category set (i.e. it equals [FeedbackCategory.other] or is empty), the
/// middleware calls the Claude API to classify the feedback message and updates
/// [FeedbackEntry.category] with the suggested value.
///
/// On any error (missing key, network failure, unexpected response) the entry
/// is returned **unchanged** — the middleware never throws or cancels a
/// submission.
///
/// ```dart
/// FeedbackWidget(
///   backend: myBackend,
///   appVersion: '1.0.0',
///   middlewares: [
///     AiCategorizationMiddleware(apiKey: const String.fromEnvironment('ANTHROPIC_API_KEY')),
///   ],
/// )
/// ```
class AiCategorizationMiddleware implements FeedbackMiddleware {
  /// Creates an [AiCategorizationMiddleware].
  ///
  /// - [apiKey]: Anthropic API key. When `null` or empty the middleware is a
  ///   no-op and returns the entry unchanged.
  /// - [model]: Claude model identifier. Defaults to `claude-haiku-4-5-20251001`
  ///   (fastest and cheapest).
  /// - [httpClient]: Optional HTTP client for testing. When omitted a default
  ///   `http.Client()` is created per-request.
  AiCategorizationMiddleware({
    this.apiKey,
    this.model = 'claude-haiku-4-5-20251001',
    http.Client? httpClient,
  }) : _httpClient = httpClient;

  /// Anthropic API key.
  final String? apiKey;

  /// Claude model identifier used for categorisation.
  final String model;

  final http.Client? _httpClient;

  static const _endpoint = 'https://api.anthropic.com/v1/messages';

  static const _systemPrompt =
      'You are a feedback categorizer. Given user feedback, respond with '
      'exactly one category name from: bug, suggestion, ui, performance, '
      'translation, featureRequest, accessibility, other. '
      'Respond with ONLY the category name, nothing else.';

  /// Maps raw Claude response text to a known [FeedbackCategory] constant.
  ///
  /// Returns `null` when the text cannot be matched.
  static String? _parseCategory(String raw) {
    final trimmed = raw.trim().toLowerCase();
    return switch (trimmed) {
      'bug' => FeedbackCategory.bug,
      'suggestion' => FeedbackCategory.suggestion,
      'ui' || 'uiux' || 'ui/ux' => FeedbackCategory.ui,
      'performance' => FeedbackCategory.performance,
      'translation' => FeedbackCategory.translation,
      'featurerequest' || 'feature_request' || 'feature request' =>
        FeedbackCategory.featureRequest,
      'accessibility' => FeedbackCategory.accessibility,
      'other' => FeedbackCategory.other,
      _ => null,
    };
  }

  @override
  Future<FeedbackEntry?> process(FeedbackEntry entry) async {
    // No-op when API key is absent.
    final key = apiKey;
    if (key == null || key.isEmpty) return entry;

    // Skip when the user has already chosen a meaningful category.
    final currentCategory = entry.category;
    if (currentCategory.isNotEmpty && currentCategory != FeedbackCategory.other) {
      return entry;
    }

    try {
      final client = _httpClient ?? http.Client();
      final bool shouldClose = _httpClient == null;

      try {
        final response = await client.post(
          Uri.parse(_endpoint),
          headers: {
            'x-api-key': key,
            'anthropic-version': '2023-06-01',
            'content-type': 'application/json',
          },
          body: jsonEncode({
            'model': model,
            'max_tokens': 16,
            'system': _systemPrompt,
            'messages': [
              {'role': 'user', 'content': entry.message},
            ],
          }),
        );

        if (response.statusCode != 200) return entry;

        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final content = body['content'] as List<dynamic>?;
        if (content == null || content.isEmpty) return entry;

        final firstBlock = content.first as Map<String, dynamic>?;
        final text = firstBlock?['text'] as String?;
        if (text == null) return entry;

        final suggested = _parseCategory(text);
        if (suggested == null) return entry;

        return entry.copyWith(category: suggested);
      } finally {
        if (shouldClose) client.close();
      }
    } catch (_) {
      // Graceful degradation: never crash, return entry unchanged.
      return entry;
    }
  }
}
