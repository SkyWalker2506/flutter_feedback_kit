import 'dart:io';
import 'dart:typed_data';

/// IO (mobile/desktop) implementation for [LocalFeedbackBackend].
Future<void> writeLocalFeedback({
  required String directoryPath,
  required String id,
  required String jsonContent,
  required List<Uint8List> screenshotBytes,
}) async {
  final dir = Directory(directoryPath);
  await dir.create(recursive: true);

  for (var i = 0; i < screenshotBytes.length; i++) {
    await File('$directoryPath/${id}_ss${i + 1}.png')
        .writeAsBytes(screenshotBytes[i]);
  }

  await File('$directoryPath/$id.json').writeAsString(jsonContent);
}
