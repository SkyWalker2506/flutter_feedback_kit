import 'feedback_category.dart';

class FeedbackEntry {
  const FeedbackEntry({
    required this.category,
    required this.message,
    required this.platform,
    required this.appVersion,
    required this.createdAt,
    this.screenshots = const [],
  });

  final FeedbackCategory category;
  final String message;
  final String platform;
  final String appVersion;
  final DateTime createdAt;
  final List<String> screenshots; // base64-encoded

  FeedbackEntry copyWith({
    FeedbackCategory? category,
    String? message,
    String? platform,
    String? appVersion,
    DateTime? createdAt,
    List<String>? screenshots,
  }) {
    return FeedbackEntry(
      category: category ?? this.category,
      message: message ?? this.message,
      platform: platform ?? this.platform,
      appVersion: appVersion ?? this.appVersion,
      createdAt: createdAt ?? this.createdAt,
      screenshots: screenshots ?? this.screenshots,
    );
  }

  Map<String, dynamic> toJson() => {
        'category': category.name,
        'message': message,
        'platform': platform,
        'appVersion': appVersion,
        'createdAt': createdAt.toIso8601String(),
        'screenshots': screenshots,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeedbackEntry &&
          category == other.category &&
          message == other.message &&
          platform == other.platform &&
          appVersion == other.appVersion &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(
        category,
        message,
        platform,
        appVersion,
        createdAt,
      );
}
