enum FeedbackCategory {
  bug,
  suggestion,
  ui,
  performance,
  translation,
  featureRequest,
  accessibility,
  other;

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
