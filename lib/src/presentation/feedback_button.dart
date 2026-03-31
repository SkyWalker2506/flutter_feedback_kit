import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../domain/entities/feedback_category.dart';
import '../domain/repositories/feedback_backend.dart';
import '../services/speech_recognition_service.dart';
import 'feedback_theme.dart';
import 'feedback_widget.dart';

/// A [FloatingActionButton] that opens [FeedbackWidget] in a bottom sheet.
///
/// Drop this into your [Scaffold.floatingActionButton] for an instant
/// feedback flow with zero boilerplate.
///
/// ```dart
/// Scaffold(
///   floatingActionButton: FeedbackButton(
///     backend: WebhookBackend(url: 'https://example.com/feedback'),
///     appVersion: '1.0.0',
///   ),
///   body: MyApp(),
/// )
/// ```
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
    this.maxScreenshots = 5,
    this.submitLabel = 'Send Feedback',
    this.successMessage = 'Thank you for your feedback!',
    this.imageQuality = 60,
    this.maxImageWidth = 800,
    this.maxImageHeight = 800,
    this.speechService,
    this.onCaptureScreenshot,
    this.theme,
  });

  /// The backend that receives submitted entries.
  final FeedbackBackend backend;

  /// Application version string embedded in every submission.
  final String appVersion;

  /// Custom label widget for the FAB. Defaults to `Text('Feedback')`.
  final Widget? child;

  /// Called after a successful submission. The bottom sheet is closed first.
  final VoidCallback? onSuccess;

  /// Called when submission fails.
  final void Function(Object)? onError;

  /// Categories shown in the dropdown. Defaults to all [FeedbackCategory] values.
  final List<FeedbackCategory>? categories;

  /// Maximum characters allowed in the message field. Default: 2000.
  final int maxMessageLength;

  /// Maximum screenshots that can be attached. Default: 5.
  final int maxScreenshots;

  /// Submit button label. Default: `'Send Feedback'`.
  final String submitLabel;

  /// Snack-bar message after a successful submission.
  final String successMessage;

  /// JPEG quality for gallery images (0–100). Default: 60.
  final int imageQuality;

  /// Maximum width for gallery images in pixels. Default: 800.
  final double maxImageWidth;

  /// Maximum height for gallery images in pixels. Default: 800.
  final double maxImageHeight;

  /// Optional voice-to-text service. Enables mic input when provided.
  final SpeechRecognitionService? speechService;

  /// Optional callback for full-screen capture. Enables "Capture Screen" option.
  final Future<Uint8List?> Function()? onCaptureScreenshot;

  /// Optional theme overrides for the feedback form.
  ///
  /// Controls background colour, submit button colour, content padding,
  /// and the bottom sheet corner radius. When `null`, defaults are used.
  final FeedbackThemeData? theme;

  @override
  Widget build(BuildContext context) {
    final effectiveTheme = theme ?? const FeedbackThemeData();

    return FloatingActionButton.extended(
      onPressed: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: effectiveTheme.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: effectiveTheme.sheetBorderRadius,
        ),
        builder: (_) => FeedbackTheme(
          data: effectiveTheme,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              effectiveTheme.contentPadding.left,
              effectiveTheme.contentPadding.top,
              effectiveTheme.contentPadding.right,
              MediaQuery.of(context).viewInsets.bottom +
                  effectiveTheme.contentPadding.bottom,
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
              maxScreenshots: maxScreenshots,
              submitLabel: submitLabel,
              successMessage: successMessage,
              imageQuality: imageQuality,
              maxImageWidth: maxImageWidth,
              maxImageHeight: maxImageHeight,
              speechService: speechService,
              onCaptureScreenshot: onCaptureScreenshot,
            ),
          ),
        ),
      ),
      icon: const Icon(Icons.feedback_outlined),
      label: child ?? const Text('Feedback'),
    );
  }
}
