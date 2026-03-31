import 'package:flutter/material.dart';
import '../i18n/feedback_localizations.dart';

/// A Net Promoter Score (NPS) widget with a 0–10 scale.
///
/// Embed inside a form or use standalone. The selected score is exposed
/// via [FeedbackWidget] when [FeedbackWidget.showNps] is `true`.
///
/// ```dart
/// FeedbackNpsWidget(
///   onScoreChanged: (score) => print('NPS: $score'),
///   question: 'How likely are you to recommend this app?',
/// )
/// ```
class FeedbackNpsWidget extends StatefulWidget {
  const FeedbackNpsWidget({
    super.key,
    this.onScoreChanged,
    this.initialScore,
    this.question = 'How likely are you to recommend this app to a friend?',
  });

  /// Called when the user selects a score.
  final void Function(int score)? onScoreChanged;

  /// Pre-selected score (0–10), or `null` for no selection.
  final int? initialScore;

  /// Question shown above the score buttons.
  final String question;

  @override
  State<FeedbackNpsWidget> createState() => _FeedbackNpsWidgetState();
}

class _FeedbackNpsWidgetState extends State<FeedbackNpsWidget> {
  int? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialScore;
  }

  Color _colorForScore(int score) {
    if (score <= 6) return Colors.red.shade400;
    if (score <= 8) return Colors.orange.shade400;
    return Colors.green.shade500;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = FeedbackLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.question,
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: List.generate(11, (i) {
            final isSelected = _selected == i;
            final color = _colorForScore(i);
            return Semantics(
              label: 'Score $i',
              selected: isSelected,
              button: true,
              child: GestureDetector(
                onTap: () {
                  setState(() => _selected = i);
                  widget.onScoreChanged?.call(i);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? color : color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected
                        ? Border.all(color: color, width: 2)
                        : null,
                  ),
                  child: Text(
                    '$i',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : color,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.npsNotLikely,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: Colors.red.shade400)),
            Text(l10n.npsVeryLikely,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: Colors.green.shade500)),
          ],
        ),
      ],
    );
  }
}
