import 'package:flutter/material.dart';

/// Holds visual customisation for flutter_feedback_kit widgets.
///
/// Pass a [FeedbackThemeData] to [FeedbackButton.theme], or wrap any part of
/// your widget tree with [FeedbackTheme] to apply colours and spacing without
/// touching the global [ThemeData].
///
/// ```dart
/// FeedbackTheme(
///   data: FeedbackThemeData(
///     submitButtonColor: Colors.teal,
///     contentPadding: EdgeInsets.all(24),
///   ),
///   child: FeedbackWidget(backend: myBackend, appVersion: '1.0.0'),
/// )
/// ```
@immutable
class FeedbackThemeData {
  const FeedbackThemeData({
    this.backgroundColor,
    this.submitButtonColor,
    this.contentPadding = const EdgeInsets.all(16),
    this.sheetBorderRadius =
        const BorderRadius.vertical(top: Radius.circular(16)),
  });

  /// Background colour of the feedback form container.
  /// Falls back to [ColorScheme.surface] when `null`.
  final Color? backgroundColor;

  /// Colour of the submit [FilledButton].
  /// Falls back to [ColorScheme.primary] when `null`.
  final Color? submitButtonColor;

  /// Padding applied around the form content.
  ///
  /// [FeedbackButton] automatically adds the keyboard inset
  /// (`MediaQuery.of(context).viewInsets.bottom`) to the bottom padding so
  /// the form remains visible above the keyboard.
  ///
  /// Default: `EdgeInsets.all(16)`.
  final EdgeInsets contentPadding;

  /// Corner radius of the bottom sheet opened by [FeedbackButton].
  ///
  /// Default: `BorderRadius.vertical(top: Radius.circular(16))`.
  final BorderRadius sheetBorderRadius;

  /// Returns a copy with the given fields replaced.
  FeedbackThemeData copyWith({
    Color? backgroundColor,
    Color? submitButtonColor,
    EdgeInsets? contentPadding,
    BorderRadius? sheetBorderRadius,
  }) {
    return FeedbackThemeData(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      submitButtonColor: submitButtonColor ?? this.submitButtonColor,
      contentPadding: contentPadding ?? this.contentPadding,
      sheetBorderRadius: sheetBorderRadius ?? this.sheetBorderRadius,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeedbackThemeData &&
          backgroundColor == other.backgroundColor &&
          submitButtonColor == other.submitButtonColor &&
          contentPadding == other.contentPadding &&
          sheetBorderRadius == other.sheetBorderRadius;

  @override
  int get hashCode => Object.hash(
        backgroundColor,
        submitButtonColor,
        contentPadding,
        sheetBorderRadius,
      );
}

/// An [InheritedWidget] that propagates [FeedbackThemeData] down the tree.
///
/// Place it above [FeedbackWidget] or [FeedbackButton] to apply custom theming.
///
/// ```dart
/// FeedbackTheme(
///   data: FeedbackThemeData(backgroundColor: const Color(0xFF1E1E2E)),
///   child: FeedbackButton(backend: myBackend, appVersion: '1.0.0'),
/// )
/// ```
class FeedbackTheme extends InheritedWidget {
  const FeedbackTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The theme data to propagate down the tree.
  final FeedbackThemeData data;

  /// Returns the nearest [FeedbackThemeData] from the widget tree, or a
  /// default [FeedbackThemeData] instance when no ancestor is found.
  static FeedbackThemeData of(BuildContext context) {
    final theme =
        context.dependOnInheritedWidgetOfExactType<FeedbackTheme>();
    return theme?.data ?? const FeedbackThemeData();
  }

  @override
  bool updateShouldNotify(FeedbackTheme oldWidget) => data != oldWidget.data;
}
