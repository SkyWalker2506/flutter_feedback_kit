import 'dart:io';
import 'dart:typed_data';

/// IO (mobile/desktop) implementation for [DevFileBackend].
Future<void> writeDevFeedback({
  required String directory,
  required String timestamp,
  required String text,
  required List<Uint8List> screenshotBytes,
}) async {
  final dir = Directory('$directory/$timestamp');
  await dir.create(recursive: true);

  await File('${dir.path}/feedback.txt').writeAsString(text);

  for (var i = 0; i < screenshotBytes.length; i++) {
    await File('${dir.path}/screenshot_${i + 1}.png')
        .writeAsBytes(screenshotBytes[i]);
  }
}
