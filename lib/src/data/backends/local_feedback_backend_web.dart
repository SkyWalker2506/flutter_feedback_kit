import 'dart:typed_data';

/// Web stub for [LocalFeedbackBackend] — filesystem access is not available on web.
Future<void> writeLocalFeedback({
  required String directoryPath,
  required String id,
  required String jsonContent,
  required List<Uint8List> screenshotBytes,
}) async {
  throw UnsupportedError(
    'LocalFeedbackBackend is not supported on web. '
    'Use WebhookBackend or another network-based backend instead.',
  );
}
