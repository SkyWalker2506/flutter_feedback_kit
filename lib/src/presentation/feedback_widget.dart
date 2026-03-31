import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../domain/entities/feedback_category.dart';
import '../domain/entities/feedback_entry.dart';
import '../domain/repositories/feedback_backend.dart';
import '../services/speech_recognition_service.dart';
import 'feedback_theme.dart';

/// An inline form widget for collecting user feedback.
///
/// Provides category selection, free-text input with optional voice dictation,
/// and screenshot attachment (gallery or screen capture). Submits via a
/// pluggable [FeedbackBackend].
///
/// For a ready-to-use floating action button that opens this form in a bottom
/// sheet, see [FeedbackButton].
///
/// ```dart
/// FeedbackWidget(
///   backend: WebhookBackend(url: 'https://example.com/feedback'),
///   appVersion: '1.0.0',
///   onSuccess: () => Navigator.pop(context),
/// )
/// ```
class FeedbackWidget extends StatefulWidget {
  const FeedbackWidget({
    super.key,
    required this.backend,
    required this.appVersion,
    this.onSuccess,
    this.onError,
    this.maxMessageLength = 2000,
    this.maxScreenshots = 5,
    this.categories,
    this.submitLabel = 'Send Feedback',
    this.successMessage = 'Thank you for your feedback!',
    this.imageQuality = 60,
    this.maxImageWidth = 800,
    this.maxImageHeight = 800,
    this.speechService,
    this.onCaptureScreenshot,
  });

  /// The backend that receives the submitted [FeedbackEntry].
  final FeedbackBackend backend;

  /// Application version string embedded in every submission.
  final String appVersion;

  /// Called after a successful submission.
  final VoidCallback? onSuccess;

  /// Called when submission fails, with the thrown error as argument.
  final void Function(Object error)? onError;

  /// Maximum number of characters allowed in the message field. Default: 2000.
  final int maxMessageLength;

  /// Maximum number of screenshots that can be attached. Default: 5.
  final int maxScreenshots;

  /// Categories shown in the dropdown.
  ///
  /// Defaults to all [FeedbackCategory] values when `null`.
  final List<FeedbackCategory>? categories;

  /// Label of the submit button. Default: `'Send Feedback'`.
  final String submitLabel;

  /// Snack-bar message shown after a successful submission.
  final String successMessage;

  /// JPEG quality for gallery images (0–100). Default: 60.
  final int imageQuality;

  /// Maximum width for gallery images in pixels. Default: 800.
  final double maxImageWidth;

  /// Maximum height for gallery images in pixels. Default: 800.
  final double maxImageHeight;

  /// Optional voice-to-text service.
  ///
  /// When provided, a microphone button appears in the message field.
  /// See [SpeechRecognitionService].
  final SpeechRecognitionService? speechService;

  /// Optional callback for full-screen capture.
  ///
  /// Should return the captured PNG bytes, or `null` on cancel/failure.
  /// When provided, a "Capture Screen" option appears alongside the gallery
  /// picker in the screenshot bottom sheet.
  final Future<Uint8List?> Function()? onCaptureScreenshot;

  @override
  State<FeedbackWidget> createState() => _FeedbackWidgetState();
}

class _FeedbackWidgetState extends State<FeedbackWidget> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  FeedbackCategory _selectedCategory = FeedbackCategory.bug;
  final List<String> _screenshots = [];
  bool _isSubmitting = false;
  bool _isListening = false;

  List<FeedbackCategory> get _categories =>
      widget.categories ?? FeedbackCategory.values;

  bool get _canAddScreenshot => _screenshots.length < widget.maxScreenshots;

  @override
  void dispose() {
    widget.speechService?.cancel();
    _messageController.dispose();
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
          const SnackBar(content: Text('Microphone not available')),
        );
      }
      return;
    }

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
  }

  Future<void> _captureScreen() async {
    if (!_canAddScreenshot) return;
    final bytes = await widget.onCaptureScreenshot?.call();
    if (bytes == null || !mounted) return;
    final encoded = await compute(base64Encode, bytes);
    if (!mounted) return;
    setState(() => _screenshots.add(encoded));
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
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pickFromGallery();
              },
            ),
            if (widget.onCaptureScreenshot != null)
              ListTile(
                leading: const Icon(Icons.screenshot_outlined),
                title: const Text('Capture screen'),
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

    final entry = FeedbackEntry(
      category: _selectedCategory,
      message: _sanitize(_messageController.text),
      platform: defaultTargetPlatform.name.toLowerCase(),
      appVersion: widget.appVersion,
      createdAt: DateTime.now(),
      screenshots: List.unmodifiable(_screenshots),
    );

    try {
      await widget.backend.submit(entry);
      widget.onSuccess?.call();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.successMessage)),
        );
        _messageController.clear();
        setState(() => _screenshots.clear());
      }
    } catch (e) {
      widget.onError?.call(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to send feedback. Please try again.'),
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

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<FeedbackCategory>(
            initialValue: _selectedCategory,
            decoration: const InputDecoration(labelText: 'Category'),
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
              labelText: 'Message',
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
                      tooltip:
                          _isListening ? 'Stop listening' : 'Voice input',
                      onPressed: _toggleVoice,
                    )
                  : null,
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Message is required';
              return null;
            },
          ),
          const SizedBox(height: 8),
          _ScreenshotRow(
            screenshots: _screenshots,
            canAdd: _canAddScreenshot,
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
                      label: 'Sending feedback, please wait',
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : Text(widget.submitLabel),
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
    required this.onAdd,
    required this.onRemove,
  });

  final List<String> screenshots;
  final bool canAdd;
  final VoidCallback onAdd;
  final void Function(int) onRemove;

  @override
  Widget build(BuildContext context) {
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
                  tooltip: 'Remove screenshot ${i + 1}',
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
            label: const Text('Screenshot'),
          ),
      ],
    );
  }
}
