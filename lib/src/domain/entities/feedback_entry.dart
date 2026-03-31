import 'dart:convert';

import 'package:flutter/foundation.dart';

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

  factory FeedbackEntry.fromJson(Map<String, dynamic> json) {
    return FeedbackEntry(
      category: FeedbackCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => FeedbackCategory.other,
      ),
      message: (json['message'] as String?) ?? '',
      platform: (json['platform'] as String?) ?? '',
      appVersion: (json['appVersion'] as String?) ?? '',
      createdAt:
          DateTime.tryParse((json['createdAt'] as String?) ?? '') ??
          DateTime.now(),
      screenshots:
          (json['screenshots'] as List<dynamic>?)?.cast<String>() ?? const [],
    );
  }

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

  String encode() => jsonEncode(toJson());

  static FeedbackEntry decode(String source) =>
      FeedbackEntry.fromJson(jsonDecode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeedbackEntry &&
          category == other.category &&
          message == other.message &&
          platform == other.platform &&
          appVersion == other.appVersion &&
          createdAt == other.createdAt &&
          listEquals(screenshots, other.screenshots);

  @override
  int get hashCode => Object.hash(
        category,
        message,
        platform,
        appVersion,
        createdAt,
        Object.hashAll(screenshots),
      );
}
