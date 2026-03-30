import 'package:flutter/material.dart';

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
  });

  final FeedbackBackend backend;
  final String appVersion;
  final Widget? child;
  final VoidCallback? onSuccess;
  final void Function(Object)? onError;

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
          ),
        ),
      ),
      icon: const Icon(Icons.feedback_outlined),
      label: child ?? const Text('Feedback'),
    );
  }
}
