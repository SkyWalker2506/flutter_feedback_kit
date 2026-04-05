import 'dart:typed_data';

/// Web stub for [DevFileBackend] — filesystem access is not available on web.
Future<void> writeDevFeedback({
  required String directory,
  required String timestamp,
  required String text,
  required List<Uint8List> screenshotBytes,
}) async {
  throw UnsupportedError(
    'DevFileBackend is not supported on web. '
    'Use WebhookBackend or another network-based backend instead.',
  );
}
