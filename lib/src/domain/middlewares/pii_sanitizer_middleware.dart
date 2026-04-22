import '../entities/feedback_entry.dart';
import '../feedback_middleware.dart';

/// A middleware that strips Personally Identifiable Information (PII) from
/// the feedback message before it reaches the backend.
///
/// By default the following patterns are redacted with `[redacted]`:
/// - Email addresses (`user@example.com`)
/// - Phone numbers in common formats (`+1 555-123-4567`, `07911 123456`, etc.)
///
/// You can supply additional [patterns] to extend the built-in list, or set
/// [replaceWith] to a custom replacement string.
///
/// The middleware never cancels a submission — it returns the entry with the
/// message field sanitised.
///
/// ```dart
/// FeedbackWidget(
///   backend: myBackend,
///   middlewares: [
///     PiiSanitizerMiddleware(),
///   ],
///   appVersion: '1.0.0',
/// )
/// ```
class PiiSanitizerMiddleware implements FeedbackMiddleware {
  /// Creates a [PiiSanitizerMiddleware].
  ///
  /// - [replaceWith]: string that replaces each matched pattern. Default: `'[redacted]'`.
  /// - [patterns]: additional [RegExp]s to apply on top of the built-in set.
  const PiiSanitizerMiddleware({
    this.replaceWith = '[redacted]',
    this.patterns = const [],
  });

  /// The replacement string inserted in place of each PII match.
  final String replaceWith;

  /// Additional regular expressions applied after the built-in patterns.
  final List<RegExp> patterns;

  // ─── Built-in patterns ────────────────────────────────────────────────────

  static final RegExp _emailPattern = RegExp(
    r'[\w.+\-]+@[\w\-]+\.[\w.]+',
    caseSensitive: false,
  );

  /// Matches common phone number formats, including:
  /// - International: `+1 555-123-4567`, `+44 7911 123456`
  /// - US local: `555-867-5309`, `(555) 867-5309`
  /// - UK: `07911 123456`
  static final RegExp _phonePattern = RegExp(
    r'(\+?\d{1,3}[\s\-.])?(\(?\d{2,4}\)?[\s\-.])\d{3,4}[\s\-.]\d{3,4}',
  );

  @override
  Future<FeedbackEntry?> process(FeedbackEntry entry) async {
    var sanitized = entry.message;
    sanitized = sanitized.replaceAll(_emailPattern, replaceWith);
    sanitized = sanitized.replaceAll(_phonePattern, replaceWith);
    for (final pattern in patterns) {
      sanitized = sanitized.replaceAll(pattern, replaceWith);
    }
    if (sanitized == entry.message) return entry;
    return entry.copyWith(message: sanitized);
  }
}
