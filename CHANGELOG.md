## 0.1.1

- Add MIT license
- Fix dart doc warnings (0 warnings)
- Broaden version constraints for device_info_plus and package_info_plus

## 0.2.0 (Unreleased)

### Security
- `WebhookBackend` now enforces HTTPS-only URLs (`ArgumentError` for HTTP)
- `WebhookException` no longer leaks `response.body` content
- Error SnackBar replaced with safe generic message (no raw exception details)

### Performance
- `base64Encode` moved to `compute()` isolate — prevents UI jank on large images
- `ImagePicker` now applies `imageQuality: 60, maxWidth: 800, maxHeight: 800` by default

### Accessibility
- Screenshot delete button replaced with `IconButton` + `tooltip` (WCAG 1.1.1)
- `Image.memory` screenshots have `semanticLabel` for screen readers
- Submit spinner wrapped with `Semantics(label: 'Sending feedback, please wait')`

### Architecture
- Web support: replaced `dart:io` / `Platform.operatingSystem` with `defaultTargetPlatform`
- `XFile.readAsBytes()` replaces `File(path).readAsBytes()` for cross-platform compatibility
- `WebhookBackend.dispose()` added to close HTTP client
- `FeedbackBackend` base class gains no-op `dispose()` method
- `FeedbackEntry.operator==` and `hashCode` now include `screenshots` list (`listEquals`)
- GitHub Actions CI workflow added (`flutter analyze && flutter test` on every PR)

### Developer Experience
- `FeedbackButton` now exposes all `FeedbackWidget` props (categories, labels, image constraints)
- `LocalFeedbackBackend` — debug-only backend that saves feedback as JSON + PNG files
- `FeedbackDevViewer` — in-app log viewer with list, detail, fullscreen screenshot, delete
- Both exported via `package:flutter_feedback_kit/local.dart` (keeps web builds clean)

---

## 0.1.0

- Initial release
- `FeedbackEntry` entity with `FeedbackCategory` enum
- `FeedbackBackend` abstract interface for pluggable backends
- `FeedbackWidget` form with category, message, and screenshot support
- `FeedbackButton` floating action button with bottom sheet
- `WebhookBackend` built-in HTTP POST backend with custom payload support
