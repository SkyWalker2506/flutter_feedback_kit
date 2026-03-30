import 'package:flutter_feedback_kit/flutter_feedback_kit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('package exports are accessible', () {
    final entry = FeedbackEntry(
      category: FeedbackCategory.bug,
      message: 'test',
      platform: 'android',
      appVersion: '1.0.0',
      createdAt: DateTime(2026),
    );
    expect(entry.category, FeedbackCategory.bug);
  });
}
