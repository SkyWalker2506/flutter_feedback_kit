import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../domain/entities/feedback_category.dart';
import '../domain/entities/feedback_entry.dart';
import '../domain/repositories/feedback_backend.dart';

class FeedbackWidget extends StatefulWidget {
  const FeedbackWidget({
    super.key,
    required this.backend,
    required this.appVersion,
    this.onSuccess,
    this.onError,
    this.maxMessageLength = 2000,
    this.categories,
    this.submitLabel = 'Send Feedback',
    this.successMessage = 'Thank you for your feedback!',
  });

  final FeedbackBackend backend;
  final String appVersion;
  final VoidCallback? onSuccess;
  final void Function(Object error)? onError;
  final int maxMessageLength;
  final List<FeedbackCategory>? categories;
  final String submitLabel;
  final String successMessage;

  @override
  State<FeedbackWidget> createState() => _FeedbackWidgetState();
}

class _FeedbackWidgetState extends State<FeedbackWidget> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  FeedbackCategory _selectedCategory = FeedbackCategory.bug;
  final List<String> _screenshots = [];
  bool _isSubmitting = false;

  List<FeedbackCategory> get _categories =>
      widget.categories ?? FeedbackCategory.values;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickScreenshot() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    final bytes = await File(file.path).readAsBytes();
    setState(() {
      _screenshots.add(base64Encode(bytes));
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final entry = FeedbackEntry(
      category: _selectedCategory,
      message: _messageController.text.trim(),
      platform: Platform.operatingSystem,
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
            content: Text('Failed to send feedback: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            decoration: const InputDecoration(
              labelText: 'Message',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Message is required';
              return null;
            },
          ),
          const SizedBox(height: 8),
          _ScreenshotRow(
            screenshots: _screenshots,
            onAdd: _pickScreenshot,
            onRemove: (i) => setState(() => _screenshots.removeAt(i)),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(widget.submitLabel),
          ),
        ],
      ),
    );
  }
}

class _ScreenshotRow extends StatelessWidget {
  const _ScreenshotRow({
    required this.screenshots,
    required this.onAdd,
    required this.onRemove,
  });

  final List<String> screenshots;
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
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => onRemove(i),
                  child: const CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.red,
                    child: Icon(Icons.close, size: 12, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        }),
        if (screenshots.length < 3)
          OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
            label: const Text('Screenshot'),
          ),
      ],
    );
  }
}
