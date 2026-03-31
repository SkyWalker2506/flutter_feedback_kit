/// Represents a single selectable category in the feedback form.
///
/// Use [FeedbackCategoryItem.builtIns] for the default set, or create custom
/// items to replace or extend the built-in list:
///
/// ```dart
/// FeedbackWidget(
///   backend: myBackend,
///   appVersion: '1.0.0',
///   categories: [
///     ...FeedbackCategoryItem.builtIns,
///     const FeedbackCategoryItem(id: 'billing', label: 'Billing Issue'),
///   ],
/// )
/// ```
class FeedbackCategoryItem {
  const FeedbackCategoryItem({required this.id, required this.label});

  /// Unique identifier stored in [FeedbackEntry.category].
  final String id;

  /// Human-readable label shown in the category dropdown.
  final String label;

  /// The default built-in category list.
  static const List<FeedbackCategoryItem> builtIns = [
    FeedbackCategoryItem(id: 'bug', label: 'Bug'),
    FeedbackCategoryItem(id: 'suggestion', label: 'Suggestion'),
    FeedbackCategoryItem(id: 'ui', label: 'UI/UX'),
    FeedbackCategoryItem(id: 'performance', label: 'Performance'),
    FeedbackCategoryItem(id: 'translation', label: 'Translation'),
    FeedbackCategoryItem(id: 'featureRequest', label: 'Feature Request'),
    FeedbackCategoryItem(id: 'accessibility', label: 'Accessibility'),
    FeedbackCategoryItem(id: 'other', label: 'Other'),
  ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeedbackCategoryItem && id == other.id && label == other.label;

  @override
  int get hashCode => Object.hash(id, label);

  @override
  String toString() => 'FeedbackCategoryItem(id: $id, label: $label)';
}

/// Built-in category identifiers for easy reference.
///
/// These string constants match the [FeedbackCategoryItem.id] values in
/// [FeedbackCategoryItem.builtIns] and the `category` field in stored JSON.
abstract final class FeedbackCategory {
  static const String bug = 'bug';
  static const String suggestion = 'suggestion';
  static const String ui = 'ui';
  static const String performance = 'performance';
  static const String translation = 'translation';
  static const String featureRequest = 'featureRequest';
  static const String accessibility = 'accessibility';
  static const String other = 'other';
}
