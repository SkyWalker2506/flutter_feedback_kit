import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../domain/entities/feedback_category.dart';
import '../domain/feedback_middleware.dart';
import '../domain/repositories/feedback_analytics.dart';
import '../domain/repositories/feedback_backend.dart';
import '../domain/entities/feedback_session_context.dart';
import '../i18n/feedback_localizations.dart';
import '../services/feedback_trigger.dart';
import '../services/metadata_collector.dart';
import '../services/speech_recognition_service.dart';
import 'feedback_scope.dart';
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
///     metadataCollector: FeedbackMetadataCollector(),
///     showRating: true,
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
    this.onQueued,
    this.categories,
    this.maxMessageLength = 2000,
    this.maxScreenshots = 5,
    this.submitLabel,
    this.successMessage,
    this.queuedMessage,
    this.imageQuality = 60,
    this.maxImageWidth = 800,
    this.maxImageHeight = 800,
    this.speechService,
    this.onCaptureScreenshot,
    this.autoCapture = false,
    this.theme,
    this.analytics,
    this.metadataCollector,
    this.sessionContextBuilder,
    this.showRating = false,
    this.showNps = false,
    this.isRatingRequired = false,
    this.isNpsRequired = false,
    this.isMessageRequired = true,
    this.localizations,
    this.trigger,
    this.middlewares = const [],
  });

  final FeedbackBackend backend;
  final String appVersion;

  /// Custom label widget for the FAB. Defaults to `Text('Feedback')`.
  final Widget? child;

  final VoidCallback? onSuccess;
  final void Function(Object)? onError;

  /// Called when the entry is saved offline instead of sent.
  final VoidCallback? onQueued;

  final List<FeedbackCategoryItem>? categories;
  final int maxMessageLength;
  final int maxScreenshots;

  /// Overrides [FeedbackLocalizations.submitLabel].
  final String? submitLabel;

  /// Overrides [FeedbackLocalizations.successMessage].
  final String? successMessage;

  /// Overrides [FeedbackLocalizations.queuedMessage].
  final String? queuedMessage;

  final int imageQuality;
  final double maxImageWidth;
  final double maxImageHeight;
  final SpeechRecognitionService? speechService;
  final Future<Uint8List?> Function()? onCaptureScreenshot;

  /// Automatically captures the screen when the form opens. Default: `false`.
  final bool autoCapture;

  /// Visual overrides for the bottom sheet and form.
  final FeedbackThemeData? theme;

  final FeedbackAnalytics? analytics;
  final FeedbackMetadataCollector? metadataCollector;
  final FeedbackSessionContext? Function()? sessionContextBuilder;

  /// Show emoji CSAT rating row. Default: `false`.
  final bool showRating;

  /// Show NPS (0–10) row. Default: `false`.
  final bool showNps;

  /// Whether the rating field is required. Default: `false`.
  final bool isRatingRequired;

  /// Whether the NPS field is required. Default: `false`.
  final bool isNpsRequired;

  /// Whether the message field is required. Default: `true`.
  final bool isMessageRequired;

  final FeedbackLocalizations? localizations;

  /// Optional [FeedbackTrigger] — if provided the button checks [FeedbackTrigger.shouldShow]
  /// before opening and calls [FeedbackTrigger.markShown] after opening.
  final FeedbackTrigger? trigger;

  /// Optional middleware pipeline forwarded to [FeedbackWidget].
  ///
  /// Runs in list order before every submission. A middleware returning `null`
  /// cancels the submission silently.
  final List<FeedbackMiddleware> middlewares;

  Future<void> _open(BuildContext context) async {
    if (trigger != null) {
      final show = await trigger!.shouldShow(appVersion: appVersion);
      if (!show) return;
      await trigger!.markShown(appVersion: appVersion);
    }

    if (!context.mounted) return;

    final scope = FeedbackScope.maybeOf(context);
    final useInteractiveCapture = scope != null && onCaptureScreenshot == null;
    final effectiveTheme = theme ?? const FeedbackThemeData();

    FeedbackFormData? formData;

    while (context.mounted) {
      FeedbackFormData? captureRequestData;

      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: effectiveTheme.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: effectiveTheme.sheetBorderRadius,
        ),
        builder: (sheetCtx) => FeedbackTheme(
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
              initialFormData: formData,
              onRequestInteractiveCapture: useInteractiveCapture
                  ? (data) {
                      captureRequestData = data;
                      Navigator.pop(sheetCtx);
                    }
                  : null,
              onSuccess: () {
                Navigator.pop(sheetCtx);
                if (scope != null && scope.widget.showNotificationOnSuccess) {
                  final l10n =
                      localizations ?? const EnFeedbackLocalizations();
                  scope.showSuccessNotification(
                      successMessage ?? l10n.successMessage);
                }
                onSuccess?.call();
              },
              onError: onError,
              onQueued: onQueued,
              categories: categories,
              maxMessageLength: maxMessageLength,
              maxScreenshots: maxScreenshots,
              submitLabel: submitLabel,
              successMessage: successMessage,
              queuedMessage: queuedMessage,
              imageQuality: imageQuality,
              maxImageWidth: maxImageWidth,
              maxImageHeight: maxImageHeight,
              speechService: speechService,
              onCaptureScreenshot: onCaptureScreenshot,
              autoCapture: formData == null && autoCapture,
              analytics: analytics,
              metadataCollector: metadataCollector,
              sessionContextBuilder: sessionContextBuilder,
              showRating: showRating,
              showNps: showNps,
              isRatingRequired: isRatingRequired,
              isNpsRequired: isNpsRequired,
              isMessageRequired: isMessageRequired,
              localizations: localizations,
              middlewares: middlewares,
            ),
          ),
        ),
      );

      // Interactive capture requested — run it then re-open the form.
      if (captureRequestData != null && scope != null && context.mounted) {
        final savedData = captureRequestData!;
        final bytes = await scope.startInteractiveCapture();
        formData = bytes != null
            ? savedData.copyWith(
                screenshots: [
                  ...savedData.screenshots,
                  base64Encode(bytes),
                ],
              )
            : savedData;
        continue;
      }

      break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scope = FeedbackScope.maybeOf(context);
    if (scope != null && scope.isCaptureActive) {
      return const SizedBox.shrink();
    }

    return FloatingActionButton.small(
      onPressed: () => _open(context),
      child: child ?? const Icon(Icons.feedback_outlined, size: 20),
    );
  }
}
