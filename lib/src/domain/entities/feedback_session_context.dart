import 'package:flutter/foundation.dart';

/// Optional user and navigation context attached to a [FeedbackEntry].
///
/// Pass a builder callback to [FeedbackWidget.sessionContextBuilder] so the
/// context is captured at submission time — not at widget construction time.
///
/// ```dart
/// FeedbackWidget(
///   backend: myBackend,
///   appVersion: '1.0.0',
///   sessionContextBuilder: () => FeedbackSessionContext(
///     userId: authService.currentUserId,
///     currentRoute: GoRouterState.of(context).matchedLocation,
///     extra: {'plan': 'pro'},
///   ),
/// )
/// ```
@immutable
class FeedbackSessionContext {
  const FeedbackSessionContext({
    this.userId,
    this.currentRoute,
    this.extra = const {},
  });

  /// Deserialises from a JSON map produced by [toJson].
  factory FeedbackSessionContext.fromJson(Map<String, dynamic> json) =>
      FeedbackSessionContext(
        userId: json['userId'] as String?,
        currentRoute: json['currentRoute'] as String?,
        extra:
            (json['extra'] as Map<String, dynamic>?)?.cast<String, String>() ??
            const {},
      );

  /// Optional anonymous or authenticated user identifier.
  final String? userId;

  /// The active route/screen name when feedback was submitted.
  final String? currentRoute;

  /// Arbitrary key-value pairs, e.g. subscription plan, feature flags.
  final Map<String, String> extra;

  /// Serialises to a JSON-compatible map. Omits null / empty fields.
  Map<String, dynamic> toJson() => {
        if (userId != null) 'userId': userId,
        if (currentRoute != null) 'currentRoute': currentRoute,
        if (extra.isNotEmpty) 'extra': extra,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeedbackSessionContext &&
          userId == other.userId &&
          currentRoute == other.currentRoute &&
          mapEquals(extra, other.extra);

  @override
  int get hashCode => Object.hash(userId, currentRoute, Object.hashAll(extra.entries));
}
