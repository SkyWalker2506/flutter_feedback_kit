import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'feedback_category.dart';
import 'feedback_metadata.dart';
import 'feedback_session_context.dart';

/// Represents a single piece of in-app user feedback.
///
/// Entries are immutable value objects. Use [copyWith] to produce modified
/// copies, and [toJson] / [fromJson] (or the compact [encode] / [decode] pair)
/// for serialisation — e.g. when persisting to a queue.
class FeedbackEntry {
  /// Creates a feedback entry.
  const FeedbackEntry({
    required this.category,
    required this.message,
    required this.platform,
    required this.appVersion,
    required this.createdAt,
    this.screenshots = const [],
    this.metadata,
    this.sessionContext,
    this.rating,
    this.npsScore,
  });

  /// Deserialises from a JSON map previously produced by [toJson].
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
      metadata: json['metadata'] != null
          ? FeedbackMetadata.fromJson(
              json['metadata'] as Map<String, dynamic>)
          : null,
      sessionContext: json['sessionContext'] != null
          ? FeedbackSessionContext.fromJson(
              json['sessionContext'] as Map<String, dynamic>)
          : null,
      rating: json['rating'] as int?,
      npsScore: json['npsScore'] as int?,
    );
  }

  /// The category selected by the user.
  final FeedbackCategory category;

  /// The free-text message entered by the user (max 2 000 characters).
  final String message;

  /// Platform identifier, e.g. `'android'` or `'ios'`.
  final String platform;

  /// Application version string at the time of submission.
  final String appVersion;

  /// UTC timestamp when the entry was created.
  final DateTime createdAt;

  /// Base64-encoded PNG screenshots attached to this entry.
  final List<String> screenshots;

  /// Optional device / app metadata collected by [FeedbackMetadataCollector].
  final FeedbackMetadata? metadata;

  /// Optional session context (user ID, current route, custom KVs).
  final FeedbackSessionContext? sessionContext;

  /// Optional 1–5 satisfaction rating from [FeedbackRatingWidget].
  final int? rating;

  /// Optional 0–10 Net Promoter Score from [FeedbackNpsWidget].
  final int? npsScore;

  /// Returns a copy with the specified fields replaced.
  FeedbackEntry copyWith({
    FeedbackCategory? category,
    String? message,
    String? platform,
    String? appVersion,
    DateTime? createdAt,
    List<String>? screenshots,
    FeedbackMetadata? metadata,
    FeedbackSessionContext? sessionContext,
    int? rating,
    int? npsScore,
  }) {
    return FeedbackEntry(
      category: category ?? this.category,
      message: message ?? this.message,
      platform: platform ?? this.platform,
      appVersion: appVersion ?? this.appVersion,
      createdAt: createdAt ?? this.createdAt,
      screenshots: screenshots ?? this.screenshots,
      metadata: metadata ?? this.metadata,
      sessionContext: sessionContext ?? this.sessionContext,
      rating: rating ?? this.rating,
      npsScore: npsScore ?? this.npsScore,
    );
  }

  /// Serialises this entry to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
        'category': category.name,
        'message': message,
        'platform': platform,
        'appVersion': appVersion,
        'createdAt': createdAt.toIso8601String(),
        'screenshots': screenshots,
        if (metadata != null) 'metadata': metadata!.toJson(),
        if (sessionContext != null)
          'sessionContext': sessionContext!.toJson(),
        if (rating != null) 'rating': rating,
        if (npsScore != null) 'npsScore': npsScore,
      };

  /// Encodes this entry to a compact JSON string suitable for storage.
  ///
  /// Use [decode] to restore the entry.
  String encode() => jsonEncode(toJson());

  /// Restores an entry from a string previously returned by [encode].
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
          listEquals(screenshots, other.screenshots) &&
          metadata == other.metadata &&
          sessionContext == other.sessionContext &&
          rating == other.rating &&
          npsScore == other.npsScore;

  @override
  int get hashCode => Object.hash(
        category,
        message,
        platform,
        appVersion,
        createdAt,
        Object.hashAll(screenshots),
        metadata,
        sessionContext,
        rating,
        npsScore,
      );
}
