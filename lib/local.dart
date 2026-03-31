// Debug-only utilities: LocalFeedbackBackend and FeedbackDevViewer.
//
// These classes rely on dart:io and are only available on mobile / desktop.
// On web this library exports nothing — guard usage with kIsWeb checks.
export 'local_io.dart' if (dart.library.html) 'local_stub.dart';
