/// Categorises a piece of user feedback.
enum FeedbackCategory {
  /// A defect or crash report.
  bug,

  /// A general improvement idea from the user.
  suggestion,

  /// A comment about the app's visual design or user experience.
  ui,

  /// A note about perceived slowness or high resource usage.
  performance,

  /// An issue with incorrect or missing translation / localisation.
  translation,

  /// A request for a wholly new feature or capability.
  featureRequest,

  /// A report of an accessibility barrier.
  accessibility,

  /// Anything that does not fit the other categories.
  other;

  /// Human-readable label shown in the category picker.
  String get label => switch (this) {
        FeedbackCategory.bug => 'Bug',
        FeedbackCategory.suggestion => 'Suggestion',
        FeedbackCategory.ui => 'UI/UX',
        FeedbackCategory.performance => 'Performance',
        FeedbackCategory.translation => 'Translation',
        FeedbackCategory.featureRequest => 'Feature Request',
        FeedbackCategory.accessibility => 'Accessibility',
        FeedbackCategory.other => 'Other',
      };
}
