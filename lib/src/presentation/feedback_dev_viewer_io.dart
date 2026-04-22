import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

/// IO implementation helpers for [FeedbackDevViewer].

Future<List<Map<String, dynamic>>> loadEntries(String directoryPath) async {
  final dir = Directory(directoryPath);
  if (!dir.existsSync()) return [];

  final files = dir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.json'))
      .toList()
    ..sort((a, b) => b.path.compareTo(a.path)); // newest first

  final entries = <Map<String, dynamic>>[];
  for (final file in files) {
    try {
      final map = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      // Inject the id (filename without extension) so the viewer can use it
      final id = file.uri.pathSegments.last.replaceAll('.json', '');
      entries.add({...map, '_id': id});
    } catch (_) {}
  }
  return entries;
}

Future<void> deleteEntry(String directoryPath, String id) async {
  final jsonFile = File('$directoryPath/$id.json');
  if (jsonFile.existsSync()) jsonFile.deleteSync();

  // Delete associated screenshots
  var i = 1;
  while (true) {
    final ss = File('$directoryPath/${id}_ss$i.png');
    if (!ss.existsSync()) break;
    ss.deleteSync();
    i++;
  }
}

Widget buildThumbnail(String directoryPath, String screenshotName) {
  final file = File('$directoryPath/$screenshotName');
  if (!file.existsSync()) {
    return const Icon(Icons.image_not_supported, size: 32, color: Colors.grey);
  }
  return Image.file(
    file,
    fit: BoxFit.cover,
    semanticLabel: 'Screenshot thumbnail',
  );
}

Widget buildScreenshotPreview(
  BuildContext context,
  String directoryPath,
  String screenshotName,
) {
  final file = File('$directoryPath/$screenshotName');
  if (!file.existsSync()) {
    return const SizedBox(
      width: 140,
      height: 140,
      child: Icon(Icons.image_not_supported, color: Colors.grey),
    );
  }
  return GestureDetector(
    onTap: () => Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => _FullScreenImage(file: file),
      ),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(
        file,
        width: 140,
        height: 140,
        fit: BoxFit.cover,
        semanticLabel: 'Screenshot',
      ),
    ),
  );
}

class _FullScreenImage extends StatelessWidget {
  const _FullScreenImage({required this.file});
  final File file;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.file(file, semanticLabel: 'Full-size screenshot'),
        ),
      ),
    );
  }
}
