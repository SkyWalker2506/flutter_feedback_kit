import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/feedback_entry.dart';
import '../../domain/repositories/feedback_queue.dart';

const _kQueueKey = 'flutter_feedback_kit_queue';

/// [FeedbackQueue] backed by [SharedPreferences].
/// Persists entries across app restarts; survives offline periods.
class SharedPrefsQueue implements FeedbackQueue {
  SharedPrefsQueue({SharedPreferencesAsync? prefs})
      : _prefs = prefs ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _prefs;

  @override
  Future<void> enqueue(FeedbackEntry entry) async {
    final current = await _readRaw();
    current.add(entry.encode());
    await _prefs.setStringList(_kQueueKey, current);
  }

  @override
  Future<List<FeedbackEntry>> pending() async {
    final raw = await _readRaw();
    return raw.map(FeedbackEntry.decode).toList();
  }

  @override
  Future<void> clear() => _prefs.setStringList(_kQueueKey, []);

  Future<List<String>> _readRaw() async =>
      await _prefs.getStringList(_kQueueKey) ?? [];
}
