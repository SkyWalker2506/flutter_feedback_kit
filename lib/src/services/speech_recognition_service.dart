import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Wraps [SpeechToText] with microphone permission management.
/// Pass an instance to [FeedbackWidget.speechService] to enable voice input.
///
/// ```dart
/// FeedbackWidget(
///   speechService: SpeechRecognitionService(),
///   ...
/// )
/// ```
class SpeechRecognitionService {
  final SpeechToText _stt = SpeechToText();
  bool _initialized = false;
  bool _available = false;

  bool get isAvailable => _available;

  /// Requests microphone permission and initialises the STT engine once.
  /// Returns `true` when ready to listen.
  Future<bool> ensureInitialized() async {
    if (_initialized) return _available;

    if (!kIsWeb) {
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        _initialized = true;
        _available = false;
        return false;
      }
    }

    final ok = await _stt.initialize();
    _initialized = true;
    _available = ok;
    return ok;
  }

  /// Starts listening and calls [onResult] with partial/final transcriptions.
  Future<void> listen({
    required void Function(String words, bool isFinal) onResult,
    String localeId = 'en_US',
    Duration listenFor = const Duration(seconds: 30),
    Duration pauseFor = const Duration(seconds: 3),
  }) {
    return _stt.listen(
      localeId: localeId,
      listenFor: listenFor,
      pauseFor: pauseFor,
      onResult: (r) => onResult(r.recognizedWords, r.finalResult),
    );
  }

  Future<void> stop() => _stt.stop();
  Future<void> cancel() => _stt.cancel();
}
