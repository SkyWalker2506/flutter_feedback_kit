import 'package:shared_preferences/shared_preferences.dart';

const _kLaunchCountKey = 'ffk_trigger_launches';
const _kFirstLaunchKey = 'ffk_trigger_first_launch';
const _kLastShownKey = 'ffk_trigger_last_shown';
const _kNeverShowKey = 'ffk_trigger_never_show';
const _kLastVersionKey = 'ffk_trigger_last_version';

/// Determines when to proactively prompt for feedback based on usage signals.
///
/// Tracks app launches and install time via [SharedPreferences]. Call
/// [recordLaunch] once per app start, then check [shouldShow] at a suitable
/// moment (e.g. after a key user action).
///
/// ```dart
/// final trigger = FeedbackTrigger(minAppLaunches: 5, minDaysInstalled: 3);
/// await trigger.recordLaunch();
///
/// if (await trigger.shouldShow()) {
///   // show FeedbackButton or open FeedbackWidget manually
///   await trigger.markShown();
/// }
/// ```
class FeedbackTrigger {
  const FeedbackTrigger({
    this.minAppLaunches = 5,
    this.minDaysInstalled = 3,
    this.repeatAfterDays = 60,
    this.oncePerVersion = false,
  });

  /// Minimum number of app launches before showing the prompt. Default: 5.
  final int minAppLaunches;

  /// Minimum days since first launch before showing the prompt. Default: 3.
  final int minDaysInstalled;

  /// How many days to wait before showing the prompt again. Default: 60.
  final int repeatAfterDays;

  /// If `true`, show at most once per app version.
  final bool oncePerVersion;

  /// Records an app launch and initialises the install timestamp on first run.
  Future<void> recordLaunch() async {
    final prefs = SharedPreferencesAsync();
    final now = DateTime.now().millisecondsSinceEpoch;

    final firstLaunch = await prefs.getInt(_kFirstLaunchKey);
    if (firstLaunch == null) {
      await prefs.setInt(_kFirstLaunchKey, now);
    }

    final count = (await prefs.getInt(_kLaunchCountKey)) ?? 0;
    await prefs.setInt(_kLaunchCountKey, count + 1);
  }

  /// Returns `true` when all conditions are met and the prompt should appear.
  Future<bool> shouldShow({String? appVersion}) async {
    final prefs = SharedPreferencesAsync();

    if ((await prefs.getBool(_kNeverShowKey)) == true) return false;

    final launches = (await prefs.getInt(_kLaunchCountKey)) ?? 0;
    if (launches < minAppLaunches) return false;

    final firstLaunch = await prefs.getInt(_kFirstLaunchKey);
    if (firstLaunch != null) {
      final daysSinceInstall = DateTime.now()
          .difference(DateTime.fromMillisecondsSinceEpoch(firstLaunch))
          .inDays;
      if (daysSinceInstall < minDaysInstalled) return false;
    }

    final lastShown = await prefs.getInt(_kLastShownKey);
    if (lastShown != null) {
      final daysSinceShown = DateTime.now()
          .difference(DateTime.fromMillisecondsSinceEpoch(lastShown))
          .inDays;
      if (daysSinceShown < repeatAfterDays) return false;
    }

    if (oncePerVersion && appVersion != null) {
      final lastVersion = await prefs.getString(_kLastVersionKey);
      if (lastVersion == appVersion) return false;
    }

    return true;
  }

  /// Records that the prompt was shown. Call this after displaying the widget.
  Future<void> markShown({String? appVersion}) async {
    final prefs = SharedPreferencesAsync();
    await prefs.setInt(
        _kLastShownKey, DateTime.now().millisecondsSinceEpoch);
    if (oncePerVersion && appVersion != null) {
      await prefs.setString(_kLastVersionKey, appVersion);
    }
  }

  /// Permanently suppresses the prompt (user chose "Never ask again").
  Future<void> markNeverShow() async {
    await SharedPreferencesAsync().setBool(_kNeverShowKey, true);
  }

  /// Resets all trigger state. Useful during testing.
  Future<void> reset() async {
    final prefs = SharedPreferencesAsync();
    await Future.wait([
      prefs.remove(_kLaunchCountKey),
      prefs.remove(_kFirstLaunchKey),
      prefs.remove(_kLastShownKey),
      prefs.remove(_kNeverShowKey),
      prefs.remove(_kLastVersionKey),
    ]);
  }
}
