import 'package:flutter_feedback_kit/flutter_feedback_kit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  group('FeedbackTrigger.shouldShow', () {
    test('returns false when launches are below threshold', () async {
      final trigger = FeedbackTrigger(
        minAppLaunches: 5,
        minDaysInstalled: 0,
        repeatAfterDays: 0,
      );

      // Record 3 launches (below threshold of 5)
      for (var i = 0; i < 3; i++) {
        await trigger.recordLaunch();
      }

      expect(await trigger.shouldShow(), isFalse);
    });

    test('returns true once launch threshold is met', () async {
      final trigger = FeedbackTrigger(
        minAppLaunches: 3,
        minDaysInstalled: 0,
        repeatAfterDays: 999,
      );

      for (var i = 0; i < 3; i++) {
        await trigger.recordLaunch();
      }

      expect(await trigger.shouldShow(), isTrue);
    });

    test('returns false after markShown until repeatAfterDays elapses',
        () async {
      final trigger = FeedbackTrigger(
        minAppLaunches: 1,
        minDaysInstalled: 0,
        repeatAfterDays: 30,
      );

      await trigger.recordLaunch();
      expect(await trigger.shouldShow(), isTrue);

      await trigger.markShown();
      // Still within the 30-day repeat window
      expect(await trigger.shouldShow(), isFalse);
    });

    test('returns false forever after markNeverShow', () async {
      final trigger = FeedbackTrigger(
        minAppLaunches: 1,
        minDaysInstalled: 0,
        repeatAfterDays: 0,
      );

      await trigger.recordLaunch();
      await trigger.markNeverShow();

      expect(await trigger.shouldShow(), isFalse);
    });

    test('reset clears all state', () async {
      final trigger = FeedbackTrigger(
        minAppLaunches: 1,
        minDaysInstalled: 0,
        repeatAfterDays: 0,
      );

      await trigger.recordLaunch();
      await trigger.markNeverShow();
      await trigger.reset();

      // After reset, launches = 0 → should not show yet
      expect(await trigger.shouldShow(), isFalse);
    });

    test('oncePerVersion suppresses repeat within same version', () async {
      final trigger = FeedbackTrigger(
        minAppLaunches: 1,
        minDaysInstalled: 0,
        repeatAfterDays: 0,
        oncePerVersion: true,
      );

      await trigger.recordLaunch();
      expect(await trigger.shouldShow(appVersion: '1.0.0'), isTrue);

      await trigger.markShown(appVersion: '1.0.0');
      expect(await trigger.shouldShow(appVersion: '1.0.0'), isFalse);
    });

    test('oncePerVersion shows again for a new version', () async {
      final trigger = FeedbackTrigger(
        minAppLaunches: 1,
        minDaysInstalled: 0,
        repeatAfterDays: 0,
        oncePerVersion: true,
      );

      await trigger.recordLaunch();
      await trigger.markShown(appVersion: '1.0.0');

      // New version — should be allowed to show again
      expect(await trigger.shouldShow(appVersion: '2.0.0'), isTrue);
    });
  });

  group('FeedbackTrigger.recordLaunch', () {
    test('increments launch count on each call', () async {
      final trigger = FeedbackTrigger(
        minAppLaunches: 3,
        minDaysInstalled: 0,
        repeatAfterDays: 999,
      );

      await trigger.recordLaunch();
      await trigger.recordLaunch();
      expect(await trigger.shouldShow(), isFalse); // 2 < 3

      await trigger.recordLaunch();
      expect(await trigger.shouldShow(), isTrue); // 3 == 3
    });
  });
}
