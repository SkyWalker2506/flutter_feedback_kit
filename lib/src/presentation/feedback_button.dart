import 'package:flutter/material.dart';

import '../domain/entities/feedback_category.dart';
import '../domain/repositories/feedback_backend.dart';
import 'feedback_widget.dart';

class FeedbackButton extends StatelessWidget {
  const FeedbackButton({
    super.key,
    required this.backend,
    required this.appVersion,
    this.child,
    this.onSuccess,
    this.onError,
    this.categories,
    this.maxMessageLength = 2000,
    this.submitLabel = 'Send Feedback',
    this.successMessage = 'Thank you for your feedback!',
    this.imageQuality = 60,
    this.maxImageWidth = 800,
    this.maxImageHeight = 800,
  });

  final FeedbackBackend backend;
  final String appVersion;
  final Widget? child;
  final VoidCallback? onSuccess;
  final void Function(Object)? onError;
  final List<FeedbackCategory>? categories;
  final int maxMessageLength;
  final String submitLabel;
  final String successMessage;
  final int imageQuality;
  final double maxImageWidth;
  final double maxImageHeight;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (_) => Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: FeedbackWidget(
            backend: backend,
            appVersion: appVersion,
            onSuccess: () {
              Navigator.pop(context);
              onSuccess?.call();
            },
            onError: onError,
            categories: categories,
            maxMessageLength: maxMessageLength,
            submitLabel: submitLabel,
            successMessage: successMessage,
            imageQuality: imageQuality,
            maxImageWidth: maxImageWidth,
            maxImageHeight: maxImageHeight,
          ),
        ),
      ),
      icon: const Icon(Icons.feedback_outlined),
      label: child ?? const Text('Feedback'),
    );
  }
}
