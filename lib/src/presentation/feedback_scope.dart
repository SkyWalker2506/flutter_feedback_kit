import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Snapshot of feedback form state, used to persist and restore the form
/// across interactive screenshot capture cycles.
///
/// See [FeedbackScope] for usage.
class FeedbackFormData {
  /// Creates a form data snapshot.
  const FeedbackFormData({
    this.message,
    this.categoryId,
    this.screenshots = const [],
    this.rating,
    this.npsScore,
  });

  /// Text content of the message field.
  final String? message;

  /// Selected category identifier.
  final String? categoryId;

  /// Base64-encoded screenshot strings.
  final List<String> screenshots;

  /// CSAT rating (1–5).
  final int? rating;

  /// NPS score (0–10).
  final int? npsScore;

  /// Returns a copy with the given fields replaced.
  FeedbackFormData copyWith({
    String? message,
    String? categoryId,
    List<String>? screenshots,
    int? rating,
    int? npsScore,
  }) {
    return FeedbackFormData(
      message: message ?? this.message,
      categoryId: categoryId ?? this.categoryId,
      screenshots: screenshots ?? this.screenshots,
      rating: rating ?? this.rating,
      npsScore: npsScore ?? this.npsScore,
    );
  }
}

/// Wraps application content to enable interactive screenshot capture and
/// overlay success notifications for the feedback flow.
///
/// Place this above your [MaterialApp] or at least above the content area
/// you want to capture:
///
/// ```dart
/// FeedbackScope(
///   child: MaterialApp(
///     home: Scaffold(
///       floatingActionButton: FeedbackButton(
///         backend: myBackend,
///         appVersion: '1.0.0',
///       ),
///     ),
///   ),
/// )
/// ```
///
/// When present in the widget tree, [FeedbackButton] automatically enables
/// interactive screenshot capture: the feedback form closes, a floating
/// capture button appears, the user can navigate the app freely, and
/// tapping capture takes the screenshot and re-opens the form with all
/// previous state preserved.
class FeedbackScope extends StatefulWidget {
  /// Creates a feedback scope.
  const FeedbackScope({
    super.key,
    required this.child,
    this.showNotificationOnSuccess = true,
    this.notificationDuration = const Duration(seconds: 3),
  });

  /// The widget below this widget in the tree.
  final Widget child;

  /// Whether to show an overlay notification when feedback is submitted
  /// successfully. Default: `true`.
  final bool showNotificationOnSuccess;

  /// How long the success notification stays visible. Default: 3 seconds.
  final Duration notificationDuration;

  /// Returns the nearest [FeedbackScopeState], or `null` if none exists.
  ///
  /// Registers a dependency so the caller rebuilds when capture state changes.
  static FeedbackScopeState? maybeOf(BuildContext context) {
    final inherited = context
        .dependOnInheritedWidgetOfExactType<_FeedbackScopeInherited>();
    return inherited?.state;
  }

  /// Returns the nearest [FeedbackScopeState].
  ///
  /// Throws if no [FeedbackScope] is found in the tree.
  static FeedbackScopeState of(BuildContext context) {
    final state = maybeOf(context);
    assert(state != null, 'No FeedbackScope found in widget tree.');
    return state!;
  }

  @override
  State<FeedbackScope> createState() => FeedbackScopeState();
}

/// State for [FeedbackScope], providing screenshot capture and notification
/// capabilities to descendant feedback widgets.
class FeedbackScopeState extends State<FeedbackScope> {
  final _repaintKey = GlobalKey();
  Completer<Uint8List?>? _captureCompleter;
  bool _showCaptureOverlay = false;
  String? _notificationMessage;

  /// Whether the interactive capture overlay is currently visible.
  bool get isCaptureActive => _showCaptureOverlay;

  /// Captures the current screen content as PNG bytes.
  ///
  /// Returns `null` if the capture fails.
  Future<Uint8List?> captureScreenshot() async {
    try {
      final boundary = _repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final pixelRatio = MediaQuery.of(context).devicePixelRatio;
      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  /// Shows a floating capture overlay and waits for the user to take a
  /// screenshot or cancel.
  ///
  /// Returns the captured PNG bytes, or `null` if cancelled.
  Future<Uint8List?> startInteractiveCapture() async {
    final completer = Completer<Uint8List?>();
    _captureCompleter = completer;
    setState(() => _showCaptureOverlay = true);
    return completer.future;
  }

  Future<void> _onCapture() async {
    setState(() => _showCaptureOverlay = false);
    // Wait for the overlay removal to be rendered.
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      final bytes = await captureScreenshot();
      _captureCompleter?.complete(bytes);
    } catch (_) {
      _captureCompleter?.complete(null);
    }
    _captureCompleter = null;
  }

  void _onCancelCapture() {
    setState(() => _showCaptureOverlay = false);
    _captureCompleter?.complete(null);
    _captureCompleter = null;
  }

  /// Displays an animated success notification at the top of the screen.
  void showSuccessNotification(String message) {
    setState(() => _notificationMessage = message);
  }

  void _onDismissNotification() {
    setState(() => _notificationMessage = null);
  }

  @override
  Widget build(BuildContext context) {
    return _FeedbackScopeInherited(
      state: this,
      isCaptureActive: _showCaptureOverlay,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
        fit: StackFit.passthrough,
        children: [
          RepaintBoundary(
            key: _repaintKey,
            child: widget.child,
          ),
          if (_showCaptureOverlay)
            Positioned.fill(
              child: _CaptureOverlay(
                onCapture: _onCapture,
                onCancel: _onCancelCapture,
              ),
            ),
          if (_notificationMessage != null)
            Positioned.fill(
              child: IgnorePointer(
                ignoring: false,
                child: _SuccessNotification(
                  message: _notificationMessage!,
                  duration: widget.notificationDuration,
                  onDismiss: _onDismissNotification,
                ),
              ),
            ),
        ],
        ),
      ),
    );
  }
}

// ─── InheritedWidget ─────────────────────────────────────────────────────────

class _FeedbackScopeInherited extends InheritedWidget {
  const _FeedbackScopeInherited({
    required this.state,
    required this.isCaptureActive,
    required super.child,
  });

  final FeedbackScopeState state;
  final bool isCaptureActive;

  @override
  bool updateShouldNotify(_FeedbackScopeInherited old) =>
      isCaptureActive != old.isCaptureActive;
}

// ─── Capture overlay ─────────────────────────────────────────────────────────

class _CaptureOverlay extends StatefulWidget {
  const _CaptureOverlay({
    required this.onCapture,
    required this.onCancel,
  });

  final Future<void> Function() onCapture;
  final VoidCallback onCancel;

  @override
  State<_CaptureOverlay> createState() => _CaptureOverlayState();
}

class _CaptureOverlayState extends State<_CaptureOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  bool _capturing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom + 24;
    return Stack(
      children: [
        // Corner frame overlay
        Positioned.fill(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: IgnorePointer(
              child: CustomPaint(
                painter: _CornerFramePainter(),
              ),
            ),
          ),
        ),
        // Capture controls
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: bottom),
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: FloatingActionButton(
                        heroTag: '_ffk_capture_cancel',
                        mini: true,
                        onPressed: widget.onCancel,
                        backgroundColor: Colors.black54,
                        elevation: 2,
                        child:
                            const Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: FloatingActionButton(
                        heroTag: '_ffk_capture',
                        onPressed: _capturing
                            ? null
                            : () {
                                setState(() => _capturing = true);
                                widget.onCapture();
                              },
                        backgroundColor: Colors.redAccent,
                        elevation: 4,
                        child: _capturing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.camera_alt,
                                color: Colors.white, size: 22),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Success notification ────────────────────────────────────────────────────

class _SuccessNotification extends StatefulWidget {
  const _SuccessNotification({
    required this.message,
    required this.duration,
    required this.onDismiss,
  });

  final String message;
  final Duration duration;
  final VoidCallback onDismiss;

  @override
  State<_SuccessNotification> createState() => _SuccessNotificationState();
}

class _SuccessNotificationState extends State<_SuccessNotification>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();

    Future.delayed(widget.duration, _dismiss);
  }

  void _dismiss() {
    if (!mounted) return;
    _controller.reverse().then((_) {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top + 16;
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(top: top, left: 16, right: 16),
        child: SlideTransition(
          position: _slideAnimation,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            color: Colors.green.shade700,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  const Icon(Icons.check_circle,
                      color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _dismiss,
                    child: const Icon(Icons.close,
                        color: Colors.white70, size: 20),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Corner frame painter ─────────────────────────────────────────────────────

class _CornerFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    const margin = 20.0;
    const length = 36.0;

    // Top-left
    canvas.drawLine(Offset(margin, margin + length), Offset(margin, margin), paint);
    canvas.drawLine(Offset(margin, margin), Offset(margin + length, margin), paint);

    // Top-right
    canvas.drawLine(Offset(size.width - margin - length, margin), Offset(size.width - margin, margin), paint);
    canvas.drawLine(Offset(size.width - margin, margin), Offset(size.width - margin, margin + length), paint);

    // Bottom-left
    canvas.drawLine(Offset(margin, size.height - margin - length), Offset(margin, size.height - margin), paint);
    canvas.drawLine(Offset(margin, size.height - margin), Offset(margin + length, size.height - margin), paint);

    // Bottom-right
    canvas.drawLine(Offset(size.width - margin - length, size.height - margin), Offset(size.width - margin, size.height - margin), paint);
    canvas.drawLine(Offset(size.width - margin, size.height - margin), Offset(size.width - margin, size.height - margin - length), paint);
  }

  @override
  bool shouldRepaint(_CornerFramePainter _) => false;
}
