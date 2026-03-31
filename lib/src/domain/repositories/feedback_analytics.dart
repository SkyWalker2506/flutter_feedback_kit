import '../entities/feedback_entry.dart';

/// Observer interface for feedback widget lifecycle events.
///
/// Implement this to forward events to your analytics stack (Firebase
/// Analytics, Amplitude, Mixpanel, PostHog, etc.).
///
/// All methods have default no-op implementations so you only override what
/// you need.
///
/// ```dart
/// class MyAnalytics implements FeedbackAnalytics {
///   @override
///   void onFeedbackSubmitted(FeedbackEntry entry) {
///     FirebaseAnalytics.instance.logEvent(
///       name: 'feedback_submitted',
///       parameters: {'category': entry.category.name},
///     );
///   }
/// }
///
/// FeedbackWidget(
///   backend: myBackend,
///   appVersion: '1.0.0',
///   analytics: MyAnalytics(),
/// )
/// ```
abstract class FeedbackAnalytics {
  /// Called when the feedback form becomes visible to the user.
  void onFeedbackShown() {}

  /// Called after a successful [FeedbackBackend.submit].
  void onFeedbackSubmitted(FeedbackEntry entry) {}

  /// Called when [FeedbackWidget] is disposed without submitting.
  void onFeedbackDismissed() {}

  /// Called when an entry is saved to the offline queue instead of sent.
  void onFeedbackQueued(FeedbackEntry entry) {}

  /// Called when the user activates voice input (mic button pressed).
  void onVoiceInputUsed() {}

  /// Called each time a screenshot is added. [count] is the new total.
  void onScreenshotAdded(int count) {}
}
