import 'package:flutter_feedback_kit/flutter_feedback_kit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FeedbackCategory', () {
    test('label returns correct string for all 8 categories', () {
      expect(FeedbackCategory.bug.label, 'Bug');
      expect(FeedbackCategory.suggestion.label, 'Suggestion');
      expect(FeedbackCategory.ui.label, 'UI/UX');
      expect(FeedbackCategory.performance.label, 'Performance');
      expect(FeedbackCategory.translation.label, 'Translation');
      expect(FeedbackCategory.featureRequest.label, 'Feature Request');
      expect(FeedbackCategory.accessibility.label, 'Accessibility');
      expect(FeedbackCategory.other.label, 'Other');
    });
  });

  group('FeedbackEntry', () {
    final entry = FeedbackEntry(
      category: FeedbackCategory.bug,
      message: 'App crashes on startup',
      platform: 'android',
      appVersion: '1.0.0',
      createdAt: DateTime(2026, 3, 31),
    );

    test('copyWith overrides selected fields', () {
      final updated = entry.copyWith(message: 'Updated message');
      expect(updated.message, 'Updated message');
      expect(updated.category, FeedbackCategory.bug);
      expect(updated.appVersion, '1.0.0');
    });

    test('toJson contains all fields', () {
      final json = entry.toJson();
      expect(json['category'], 'bug');
      expect(json['message'], 'App crashes on startup');
      expect(json['platform'], 'android');
      expect(json['appVersion'], '1.0.0');
      expect(json['screenshots'], isEmpty);
    });

    test('equality works', () {
      final same = entry.copyWith();
      expect(entry, equals(same));
    });

    test('screenshots default to empty list', () {
      expect(entry.screenshots, isEmpty);
    });

    test('fromJson round-trips toJson', () {
      final json = entry.toJson();
      final restored = FeedbackEntry.fromJson(json);
      expect(restored, equals(entry));
    });

    test('encode / decode round-trip', () {
      final encoded = entry.encode();
      final decoded = FeedbackEntry.decode(encoded);
      expect(decoded, equals(entry));
    });

    test('fromJson uses other category for unknown value', () {
      final json = entry.toJson()..['category'] = 'unknown_value';
      final restored = FeedbackEntry.fromJson(json);
      expect(restored.category, FeedbackCategory.other);
    });

    test('screenshots are included in equality check', () {
      final withScreenshot = entry.copyWith(screenshots: ['abc123']);
      expect(entry == withScreenshot, isFalse);
    });
  });
}
