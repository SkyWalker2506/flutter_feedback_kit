import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feedback_kit/flutter_feedback_kit.dart';
import 'package:flutter_feedback_kit/local.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter_feedback_kit example',
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FeedbackBackend? _backend;
  Directory? _feedbackDir;

  @override
  void initState() {
    super.initState();
    _initBackend();
  }

  Future<void> _initBackend() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/feedback');
    final backend = kDebugMode
        ? LocalFeedbackBackend(directory: dir)
        : WebhookBackend(url: 'https://your-webhook-url.example.com/feedback');
    setState(() {
      _feedbackDir = dir;
      _backend = backend;
    });
  }

  @override
  void dispose() {
    _backend?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_backend == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback Kit Demo'),
        actions: [
          if (kDebugMode && _feedbackDir != null)
            IconButton(
              icon: const Icon(Icons.list_alt_outlined),
              tooltip: 'Feedback Log',
              onPressed: () => Navigator.push<void>(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      FeedbackDevViewer(directory: _feedbackDir!),
                ),
              ),
            ),
        ],
      ),
      body: const Center(child: Text('Tap the button to leave feedback')),
      floatingActionButton: FeedbackButton(
        backend: _backend!,
        appVersion: '1.0.0',
        onSuccess: () => debugPrint('[FeedbackKit] Submitted successfully'),
        onError: (e) => debugPrint('[FeedbackKit] Error: $e'),
      ),
    );
  }
}
