import 'package:flutter/material.dart';

/// Web stub for [FeedbackDevViewer] — filesystem access is not available on web.

Future<List<Map<String, dynamic>>> loadEntries(String directoryPath) async =>
    [];

Future<void> deleteEntry(String directoryPath, String id) async {}

Widget buildThumbnail(String directoryPath, String screenshotName) =>
    const Icon(Icons.image_not_supported, size: 32, color: Colors.grey);

Widget buildScreenshotPreview(
  BuildContext context,
  String directoryPath,
  String screenshotName,
) =>
    const SizedBox(
      width: 140,
      height: 140,
      child: Icon(Icons.image_not_supported, color: Colors.grey),
    );
