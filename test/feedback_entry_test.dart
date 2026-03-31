import 'package:flutter_feedback_kit/flutter_feedback_kit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FeedbackCategoryItem', () {
    test('builtIns contains 8 items with correct labels', () {
      final items = FeedbackCategoryItem.builtIns;
      expect(items.length, 8);
      expect(items.firstWhere((c) => c.id == FeedbackCategory.bug).label, 'Bug');
      expect(items.firstWhere((c) => c.id == FeedbackCategory.suggestion).label, 'Suggestion');
      expect(items.firstWhere((c) => c.id == FeedbackCategory.ui).label, 'UI/UX');
      expect(items.firstWhere((c) => c.id == FeedbackCategory.performance).label, 'Performance');
      expect(items.firstWhere((c) => c.id == FeedbackCategory.translation).label, 'Translation');
      expect(items.firstWhere((c) => c.id == FeedbackCategory.featureRequest).label, 'Feature Request');
      expect(items.firstWhere((c) => c.id == FeedbackCategory.accessibility).label, 'Accessibility');
      expect(items.firstWhere((c) => c.id == FeedbackCategory.other).label, 'Other');
    });

    test('custom category has correct id and label', () {
      const custom = FeedbackCategoryItem(id: 'billing', label: 'Billing Issue');
      expect(custom.id, 'billing');
      expect(custom.label, 'Billing Issue');
    });

    test('equality is value-based', () {
      const a = FeedbackCategoryItem(id: 'bug', label: 'Bug');
      const b = FeedbackCategoryItem(id: 'bug', label: 'Bug');
      expect(a, equals(b));
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

    test('fromJson uses "other" for unknown category value', () {
      final json = entry.toJson()..['category'] = 'unknown_value';
      final restored = FeedbackEntry.fromJson(json);
      // Unknown values are stored as-is (not mapped to built-in)
      expect(restored.category, 'unknown_value');
    });

    test('custom category id is preserved in round-trip', () {
      final custom = FeedbackEntry(
        category: 'billing',
        message: 'Charge issue',
        platform: 'ios',
        appVersion: '2.0.0',
        createdAt: DateTime(2026, 4, 1),
      );
      final decoded = FeedbackEntry.decode(custom.encode());
      expect(decoded.category, 'billing');
    });

    test('screenshots are included in equality check', () {
      final withScreenshot = entry.copyWith(screenshots: ['abc123']);
      expect(entry == withScreenshot, isFalse);
    });
  });
}
