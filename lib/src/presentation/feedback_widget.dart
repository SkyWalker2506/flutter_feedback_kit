import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../domain/entities/feedback_category.dart';
import '../domain/entities/feedback_entry.dart';
import '../domain/repositories/feedback_analytics.dart';
import '../domain/repositories/feedback_backend.dart';
import '../domain/feedback_middleware.dart';
import '../domain/entities/feedback_session_context.dart';
import '../i18n/feedback_localizations.dart';
import '../services/metadata_collector.dart';
import '../services/speech_recognition_service.dart';
import '../data/backends/queued_backend.dart';
import 'feedback_nps_widget.dart';
import 'feedback_rating_widget.dart';
import 'feedback_theme.dart';

/// An inline form widget for collecting user feedback.
///
/// Provides category selection, free-text input with optional voice dictation,
/// emoji rating, NPS score, and screenshot attachment. Submits via a pluggable
/// [FeedbackBackend].
///
/// For a ready-to-use floating action button see [FeedbackButton].
///
/// ```dart
/// FeedbackWidget(
///   backend: WebhookBackend(url: 'https://example.com/feedback'),
///   appVersion: '1.0.0',
///   onSuccess: () => Navigator.pop(context),
///   metadataCollector: FeedbackMetadataCollector(),
///   showRating: true,
/// )
/// ```
class FeedbackWidget extends StatefulWidget {
  const FeedbackWidget({
    super.key,
    required this.backend,
    required this.appVersion,
    this.onSuccess,
    this.onError,
    this.onQueued,
    this.maxMessageLength = 2000,
    this.maxScreenshots = 5,
    this.categories,
    this.submitLabel,
    this.successMessage,
    this.queuedMessage,
    this.imageQuality = 60,
    this.maxImageWidth = 800,
    this.maxImageHeight = 800,
    this.speechService,
    this.onCaptureScreenshot,
    this.autoCapture = false,
    this.analytics,
    this.metadataCollector,
    this.sessionContextBuilder,
    this.showRating = false,
    this.showNps = false,
    this.localizations,
    this.middlewares = const [],
  });

  /// The backend that receives the submitted [FeedbackEntry].
  final FeedbackBackend backend;

  /// Application version string embedded in every submission.
  final String appVersion;

  /// Called after a successful submission.
  final VoidCallback? onSuccess;

  /// Called when submission fails, with the thrown error as argument.
  final void Function(Object error)? onError;

  /// Called when the entry is saved to the offline queue instead of sent.
  ///
  /// Only fires when [backend] is a [QueuedBackend] and connectivity is absent.
  final VoidCallback? onQueued;

  /// Maximum characters in the message field. Default: 2000.
  final int maxMessageLength;

  /// Maximum screenshots that can be attached. Default: 5.
  final int maxScreenshots;

  /// Categories shown in the dropdown.
  ///
  /// Defaults to [FeedbackCategoryItem.builtIns]. Pass a custom list to
  /// restrict, reorder, or extend the built-in set:
  ///
  /// ```dart
  /// categories: [
  ///   ...FeedbackCategoryItem.builtIns,
  ///   const FeedbackCategoryItem(id: 'billing', label: 'Billing'),
  /// ]
  /// ```
  final List<FeedbackCategoryItem>? categories;

  /// Custom submit button label. Overrides [FeedbackLocalizations.submitLabel].
  final String? submitLabel;

  /// Custom success snack-bar message. Overrides [FeedbackLocalizations.successMessage].
  final String? successMessage;

  /// Custom queued snack-bar message. Overrides [FeedbackLocalizations.queuedMessage].
  final String? queuedMessage;

  /// JPEG quality for gallery images (0–100). Default: 60.
  final int imageQuality;

  /// Maximum width for gallery images in pixels. Default: 800.
  final double maxImageWidth;

  /// Maximum height for gallery images in pixels. Default: 800.
  final double maxImageHeight;

  /// Optional voice-to-text service. Enables mic button when provided.
  final SpeechRecognitionService? speechService;

  /// Optional callback for full-screen capture.
  ///
  /// Returns PNG bytes or `null` on cancel. When provided, a "Capture Screen"
  /// option appears alongside the gallery picker.
  final Future<Uint8List?> Function()? onCaptureScreenshot;

  /// When `true` and [onCaptureScreenshot] is provided, automatically
  /// captures the screen when the widget first renders. Default: `false`.
  final bool autoCapture;

  /// Optional analytics observer for widget lifecycle events.
  final FeedbackAnalytics? analytics;

  /// Optional metadata collector — enriches each [FeedbackEntry] with
  /// OS/device/app info at submission time.
  final FeedbackMetadataCollector? metadataCollector;

  /// Optional session context builder called at submission time.
  ///
  /// Use this to attach the current user ID, route, or custom key-value pairs.
  final FeedbackSessionContext? Function()? sessionContextBuilder;

  /// Show an emoji CSAT rating row (1–5). Default: `false`.
  final bool showRating;

  /// Show an NPS (0–10) row. Default: `false`.
  final bool showNps;

  /// Custom localisation strings. Falls back to [FeedbackLocalizations.of]
  /// from the widget tree, then [EnFeedbackLocalizations].
  final FeedbackLocalizations? localizations;

  /// Optional middleware pipeline applied before every submission.
  ///
  /// Middleware runs in list order. Each step receives the entry returned by
  /// the previous one. If any middleware returns `null` the submission is
  /// cancelled silently — [backend] is never called and [onSuccess] / [onError]
  /// are not invoked.
  ///
  /// ```dart
  /// middlewares: [
  ///   LoggingMiddleware(),
  ///   RedactMiddleware(),
  /// ]
  /// ```
  final List<FeedbackMiddleware> middlewares;

  @override
  State<FeedbackWidget> createState() => _FeedbackWidgetState();
}

class _FeedbackWidgetState extends State<FeedbackWidget> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  late FeedbackCategoryItem _selectedCategory;
  final List<String> _screenshots = [];
  bool _isSubmitting = false;
  bool _isListening = false;
  int? _rating;
  int? _npsScore;
  bool _submitted = false;

  List<FeedbackCategoryItem> get _categories =>
      widget.categories ?? FeedbackCategoryItem.builtIns;

  bool get _canAddScreenshot => _screenshots.length < widget.maxScreenshots;

  FeedbackLocalizations get _l10n =>
      widget.localizations ??
      (context.mounted ? FeedbackLocalizations.of(context) : const EnFeedbackLocalizations());

  @override
  void initState() {
    super.initState();
    _selectedCategory = _categories.first;
    widget.analytics?.onFeedbackShown();
    if (widget.autoCapture && widget.onCaptureScreenshot != null) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _captureScreen());
    }
  }

  @override
  void dispose() {
    widget.speechService?.cancel();
    _messageController.dispose();
    if (!_submitted) widget.analytics?.onFeedbackDismissed();
    super.dispose();
  }

  // ─── Input sanitization ───────────────────────────────────────────────────

  String _sanitize(String input) {
    final stripped = input.replaceAll(RegExp(r'[<>]'), '');
    final trimmed = stripped.trim();
    return trimmed.length > widget.maxMessageLength
        ? trimmed.substring(0, widget.maxMessageLength)
        : trimmed;
  }

  // ─── Voice input ──────────────────────────────────────────────────────────

  Future<void> _toggleVoice() async {
    final stt = widget.speechService;
    if (stt == null) return;

    if (_isListening) {
      await stt.stop();
      setState(() => _isListening = false);
      return;
    }

    final ok = await stt.ensureInitialized();
    if (!ok) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_l10n.microphoneNotAvailable)),
        );
      }
      return;
    }

    widget.analytics?.onVoiceInputUsed();
    setState(() => _isListening = true);
    await stt.listen(
      onResult: (words, isFinal) {
        if (mounted) {
          _messageController.text = words;
          _messageController.selection =
              TextSelection.collapsed(offset: words.length);
          if (isFinal) setState(() => _isListening = false);
        }
      },
    );
  }

  // ─── Screenshot picking ───────────────────────────────────────────────────

  Future<void> _pickFromGallery() async {
    if (!_canAddScreenshot) return;
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: widget.imageQuality,
      maxWidth: widget.maxImageWidth,
      maxHeight: widget.maxImageHeight,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    final encoded = await compute(base64Encode, bytes);
    if (!mounted) return;
    setState(() => _screenshots.add(encoded));
    widget.analytics?.onScreenshotAdded(_screenshots.length);
  }

  Future<void> _captureScreen() async {
    if (!_canAddScreenshot) return;
    final bytes = await widget.onCaptureScreenshot?.call();
    if (bytes == null || !mounted) return;
    final encoded = await compute(base64Encode, bytes);
    if (!mounted) return;
    setState(() => _screenshots.add(encoded));
    widget.analytics?.onScreenshotAdded(_screenshots.length);
  }

  void _showScreenshotOptions() {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(_l10n.chooseFromGalleryLabel),
              onTap: () {
                Navigator.pop(ctx);
                _pickFromGallery();
              },
            ),
            if (widget.onCaptureScreenshot != null)
              ListTile(
                leading: const Icon(Icons.screenshot_outlined),
                title: Text(_l10n.captureScreenLabel),
                onTap: () {
                  Navigator.pop(ctx);
                  _captureScreen();
                },
              ),
          ],
        ),
      ),
    );
  }

  // ─── Submit ───────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final metadata = await widget.metadataCollector?.collect();
    final sessionContext = widget.sessionContextBuilder?.call();

    final entry = FeedbackEntry(
      category: _selectedCategory.id,
      message: _sanitize(_messageController.text),
      platform: defaultTargetPlatform.name.toLowerCase(),
      appVersion: widget.appVersion,
      createdAt: DateTime.now(),
      screenshots: List.unmodifiable(_screenshots),
      metadata: metadata,
      sessionContext: sessionContext,
      rating: _rating,
      npsScore: _npsScore,
    );

    // Run the middleware chain — any step may transform or cancel the entry.
    FeedbackEntry? processed = entry;
    for (final middleware in widget.middlewares) {
      processed = await middleware.process(processed!);
      if (processed == null) {
        if (mounted) setState(() => _isSubmitting = false);
        return;
      }
    }

    try {
      await widget.backend.submit(processed!);

      final wasQueued = widget.backend is QueuedBackend &&
          (widget.backend as QueuedBackend).lastSubmitWasQueued;

      _submitted = true;

      if (wasQueued) {
        widget.onQueued?.call();
        widget.analytics?.onFeedbackQueued(processed);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(widget.queuedMessage ?? _l10n.queuedMessage)),
          );
          _messageController.clear();
          setState(() {
            _screenshots.clear();
            _rating = null;
            _npsScore = null;
          });
        }
      } else {
        widget.onSuccess?.call();
        widget.analytics?.onFeedbackSubmitted(processed);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(widget.successMessage ?? _l10n.successMessage)),
          );
          _messageController.clear();
          setState(() {
            _screenshots.clear();
            _rating = null;
            _npsScore = null;
          });
        }
      }
    } catch (e) {
      _submitted = false;
      widget.onError?.call(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_l10n.feedbackSendError),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final feedbackTheme = FeedbackTheme.of(context);
    final l10n = widget.localizations ?? FeedbackLocalizations.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showRating) ...[
            FeedbackRatingWidget(
              label: l10n.ratingLabel,
              initialRating: _rating,
              onRatingChanged: (v) => setState(() => _rating = v),
            ),
            const SizedBox(height: 16),
          ],
          if (widget.showNps) ...[
            FeedbackNpsWidget(
              question: l10n.npsQuestion,
              initialScore: _npsScore,
              onScoreChanged: (v) => setState(() => _npsScore = v),
            ),
            const SizedBox(height: 16),
          ],
          DropdownButtonFormField<FeedbackCategoryItem>(
            initialValue: _selectedCategory,
            decoration: InputDecoration(labelText: l10n.categoryLabel),
            items: _categories
                .map((c) => DropdownMenuItem(value: c, child: Text(c.label)))
                .toList(),
            onChanged: (v) => setState(() => _selectedCategory = v!),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _messageController,
            maxLength: widget.maxMessageLength,
            maxLines: 5,
            decoration: InputDecoration(
              labelText: l10n.messageLabel,
              alignLabelWithHint: true,
              border: const OutlineInputBorder(),
              suffixIcon: widget.speechService != null
                  ? IconButton(
                      icon: Icon(
                        _isListening ? Icons.mic : Icons.mic_none_outlined,
                        color: _isListening
                            ? Theme.of(context).colorScheme.error
                            : null,
                      ),
                      tooltip: _isListening
                          ? l10n.stopListeningTooltip
                          : l10n.voiceInputTooltip,
                      onPressed: _toggleVoice,
                    )
                  : null,
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return l10n.messageRequired;
              return null;
            },
          ),
          const SizedBox(height: 8),
          _ScreenshotRow(
            screenshots: _screenshots,
            canAdd: _canAddScreenshot,
            screenshotLabel: l10n.screenshotLabel,
            onAdd: widget.onCaptureScreenshot != null
                ? _showScreenshotOptions
                : _pickFromGallery,
            onRemove: (i) => setState(() => _screenshots.removeAt(i)),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _isSubmitting ? null : _submit,
            style: feedbackTheme.submitButtonColor != null
                ? FilledButton.styleFrom(
                    backgroundColor: feedbackTheme.submitButtonColor,
                  )
                : null,
            child: _isSubmitting
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: Semantics(
                      label: l10n.sendingLabel,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : Text(widget.submitLabel ?? l10n.submitLabel),
          ),
        ],
      ),
    );
  }
}

// ─── Screenshot row ───────────────────────────────────────────────────────────

class _ScreenshotRow extends StatelessWidget {
  const _ScreenshotRow({
    required this.screenshots,
    required this.canAdd,
    required this.screenshotLabel,
    required this.onAdd,
    required this.onRemove,
  });

  final List<String> screenshots;
  final bool canAdd;
  final String screenshotLabel;
  final VoidCallback onAdd;
  final void Function(int) onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = FeedbackLocalizations.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...List.generate(screenshots.length, (i) {
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  base64Decode(screenshots[i]),
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  semanticLabel:
                      'Screenshot ${i + 1} of ${screenshots.length}',
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  tooltip: '${l10n.removeScreenshot} ${i + 1}',
                  onPressed: () => onRemove(i),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(28, 28),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          );
        }),
        if (canAdd)
          OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
            label: Text(screenshotLabel),
          ),
      ],
    );
  }
}
