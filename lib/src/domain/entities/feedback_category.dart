enum FeedbackCategory {
  bug,
  suggestion,
  ui,
  performance,
  other;

  String get label => switch (this) {
        FeedbackCategory.bug => 'Bug',
        FeedbackCategory.suggestion => 'Suggestion',
        FeedbackCategory.ui => 'UI/UX',
        FeedbackCategory.performance => 'Performance',
        FeedbackCategory.other => 'Other',
      };
}
