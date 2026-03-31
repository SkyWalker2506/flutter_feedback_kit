import 'package:flutter_feedback_kit/flutter_feedback_kit.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// [FeedbackBackend] that submits user feedback via the Sentry SDK.
///
/// **Setup:**
/// 1. Add `flutter_feedback_kit_sentry` to your `pubspec.yaml`.
/// 2. Initialise Sentry with `SentryFlutter.init(...)` before use.
///
/// ```dart
/// FeedbackButton(
///   backend: SentryFeedbackBackend(),
///   appVersion: '1.0.0',
/// )
/// ```
///
/// To associate feedback with a specific error event, pass [eventId]:
///
/// ```dart
/// SentryFeedbackBackend(
///   eventId: latestSentryEventId,
///   nameResolver: () => authService.currentUserName ?? 'Anonymous',
///   emailResolver: () => authService.currentUserEmail ?? '',
/// )
/// ```
class SentryFeedbackBackend implements FeedbackBackend {
  /// Creates a [SentryFeedbackBackend].
  ///
  /// [eventId] — Sentry event to associate with. Defaults to a new random ID.
  /// [nameResolver] — Returns the reporter name. Default: `'Anonymous'`.
  /// [emailResolver] — Returns the reporter email. Default: empty string.
  const SentryFeedbackBackend({
    this.eventId,
    this.nameResolver,
    this.emailResolver,
  });

  /// Sentry event ID to attach the feedback to.
  final SentryId? eventId;

  /// Optional callback returning the reporter's display name.
  final String Function()? nameResolver;

  /// Optional callback returning the reporter's email.
  final String Function()? emailResolver;

  @override
  Future<void> submit(FeedbackEntry entry) async {
    final feedback = SentryUserFeedback(
      eventId: eventId ?? SentryId.newId(),
      comments: '[${entry.category.label}] ${entry.message}',
      name: nameResolver?.call() ?? 'Anonymous',
      email: emailResolver?.call() ?? '',
    );
    await Sentry.captureUserFeedback(feedback);
  }
}
