import 'package:flutter/material.dart';
import 'package:flutter_feedback_kit/flutter_feedback_kit.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter_feedback_kit example',
      home: HomeScreen(
        backend: WebhookBackend(
          url: 'https://your-webhook-url.example.com/feedback',
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.backend});

  final FeedbackBackend backend;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feedback Kit Demo')),
      body: const Center(child: Text('Tap the button to leave feedback')),
      floatingActionButton: FeedbackButton(
        backend: backend,
        appVersion: '1.0.0',
        onSuccess: () => debugPrint('Feedback sent!'),
        onError: (e) => debugPrint('Error: $e'),
      ),
    );
  }
}
