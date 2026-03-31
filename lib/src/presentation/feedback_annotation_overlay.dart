import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// A full-screen drawing overlay for annotating a screenshot before attaching.
///
/// Shows [imageBytes] as a background and lets the user draw coloured strokes
/// with their finger or stylus. Tapping **Save** renders the annotated result
/// to a PNG [Uint8List] and calls [onSave]. Tapping **Discard** calls
/// [onDiscard] without saving.
///
/// Typically triggered from [FeedbackWidget] via [onCaptureScreenshot] or
/// shown after the user picks an image from the gallery.
///
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (_) => FeedbackAnnotationOverlay(
///       imageBytes: screenshotBytes,
///       onSave: (annotated) {
///         Navigator.pop(context);
///         // attach `annotated` to feedback entry
///       },
///     ),
///   ),
/// );
/// ```
class FeedbackAnnotationOverlay extends StatefulWidget {
  const FeedbackAnnotationOverlay({
    super.key,
    required this.imageBytes,
    required this.onSave,
    this.onDiscard,
    this.saveLabel = 'Save',
    this.discardLabel = 'Discard',
    this.undoTooltip = 'Undo',
  });

  /// PNG bytes of the screenshot to annotate.
  final Uint8List imageBytes;

  /// Called with the annotated PNG bytes when the user taps Save.
  final void Function(Uint8List annotatedBytes) onSave;

  /// Called when the user taps Discard.
  final VoidCallback? onDiscard;

  final String saveLabel;
  final String discardLabel;
  final String undoTooltip;

  @override
  State<FeedbackAnnotationOverlay> createState() =>
      _FeedbackAnnotationOverlayState();
}

class _FeedbackAnnotationOverlayState
    extends State<FeedbackAnnotationOverlay> {
  final _repaintKey = GlobalKey();
  final List<_Stroke> _strokes = [];
  _Stroke? _current;
  Color _color = Colors.red;
  double _strokeWidth = 3.0;
  bool _saving = false;

  static const _palette = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.black,
    Colors.white,
  ];

  void _onPanStart(DragStartDetails d) {
    setState(() {
      _current = _Stroke(color: _color, width: _strokeWidth)
        ..points.add(d.localPosition);
      _strokes.add(_current!);
    });
  }

  void _onPanUpdate(DragUpdateDetails d) {
    setState(() => _current?.points.add(d.localPosition));
  }

  void _onPanEnd(DragEndDetails _) {
    setState(() => _current = null);
  }

  void _undo() {
    if (_strokes.isNotEmpty) setState(() => _strokes.removeLast());
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final boundary = _repaintKey.currentContext!.findRenderObject()!
          as RenderRepaintBoundary;
      final image = await boundary.toImage(
          pixelRatio: MediaQuery.of(context).devicePixelRatio);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();
      widget.onSave(bytes);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            tooltip: widget.undoTooltip,
            onPressed: _strokes.isEmpty ? null : _undo,
          ),
          TextButton(
            onPressed: widget.onDiscard ?? () => Navigator.pop(context),
            child: Text(widget.discardLabel,
                style: const TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Text(widget.saveLabel,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RepaintBoundary(
              key: _repaintKey,
              child: GestureDetector(
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.memory(widget.imageBytes, fit: BoxFit.contain),
                    CustomPaint(painter: _StrokePainter(_strokes)),
                  ],
                ),
              ),
            ),
          ),
          // ─── Toolbar ───────────────────────────────────────────────────────
          Container(
            color: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              children: [
                // Colour palette
                ..._palette.map((c) {
                  final selected = c == _color;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () => setState(() => _color = c),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: selected
                              ? Border.all(color: Colors.white, width: 2)
                              : Border.all(color: Colors.grey, width: 1),
                        ),
                      ),
                    ),
                  );
                }),
                const Spacer(),
                // Stroke width
                const Icon(Icons.line_weight, color: Colors.white70, size: 18),
                Slider(
                  value: _strokeWidth,
                  min: 2,
                  max: 12,
                  divisions: 5,
                  activeColor: Colors.white,
                  inactiveColor: Colors.white24,
                  onChanged: (v) => setState(() => _strokeWidth = v),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Drawing primitives ───────────────────────────────────────────────────────

class _Stroke {
  _Stroke({required this.color, required this.width});
  final Color color;
  final double width;
  final List<Offset> points = [];
}

class _StrokePainter extends CustomPainter {
  const _StrokePainter(this.strokes);
  final List<_Stroke> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      if (stroke.points.isEmpty) continue;
      final paint = Paint()
        ..color = stroke.color
        ..strokeWidth = stroke.width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final path = Path()..moveTo(stroke.points.first.dx, stroke.points.first.dy);
      for (final p in stroke.points.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_StrokePainter old) => true;
}
