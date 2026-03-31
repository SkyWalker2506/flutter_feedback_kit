import 'package:flutter/material.dart';

/// A 5-level emoji satisfaction (CSAT) rating widget.
///
/// Embed inside a form or pass [onRatingChanged] to react to selection.
/// The selected value (1–5) is available via [FeedbackWidget] when
/// [FeedbackWidget.showRating] is `true`.
///
/// ```dart
/// FeedbackRatingWidget(
///   onRatingChanged: (rating) => print('Rating: $rating'),
/// )
/// ```
class FeedbackRatingWidget extends StatefulWidget {
  const FeedbackRatingWidget({
    super.key,
    this.onRatingChanged,
    this.initialRating,
    this.label = 'How do you feel?',
  });

  /// Called whenever the user selects a rating.
  final void Function(int rating)? onRatingChanged;

  /// Pre-selected rating (1–5), or `null` for no selection.
  final int? initialRating;

  /// Label shown above the emoji row.
  final String label;

  @override
  State<FeedbackRatingWidget> createState() => _FeedbackRatingWidgetState();
}

class _FeedbackRatingWidgetState extends State<FeedbackRatingWidget> {
  int? _selected;

  static const _emojis = ['😡', '😞', '😐', '😊', '😍'];
  static const _labels = ['Terrible', 'Bad', 'Okay', 'Good', 'Amazing'];

  @override
  void initState() {
    super.initState();
    _selected = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (i) {
            final value = i + 1;
            final isSelected = _selected == value;
            return Semantics(
              label: '${_labels[i]}, rating $value of 5',
              selected: isSelected,
              button: true,
              child: GestureDetector(
                onTap: () {
                  setState(() => _selected = value);
                  widget.onRatingChanged?.call(value);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context)
                            .colorScheme
                            .primaryContainer
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          )
                        : null,
                  ),
                  child: Text(
                    _emojis[i],
                    style: TextStyle(fontSize: isSelected ? 32 : 26),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
