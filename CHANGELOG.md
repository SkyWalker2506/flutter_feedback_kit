## 0.2.0

### Sprint 10 (Forge Runs 1-3)
- `PiiSanitizerMiddleware` — redacts email addresses and phone numbers from the feedback message before backend delivery; supports custom regex patterns and replacement strings
- `flutter_feedback_kit_github` sub-package — creates GitHub Issues via REST API v3 on feedback submission; custom title/body/label support
- `flutter_feedback_kit_email` sub-package — delivers feedback as SendGrid v3 emails (plain-text + HTML); custom subject/body/htmlBody builders
- `QueuedBackend.flushQueue` — improved partial flush: successfully delivered entries are removed immediately via `removeAt`, so a partial failure does not re-send already-delivered entries
- `FeedbackQueue.removeAt` — new interface method for per-entry removal; `SharedPrefsQueue` overrides with O(n) implementation
- `FeedbackTrigger` — comprehensive unit-test coverage (8 tests); uses `InMemorySharedPreferencesAsync` for isolation

### Breaking Changes
- `LocalFeedbackBackend(directory: Directory)` → `LocalFeedbackBackend(directoryPath: String)` — removes `dart:io` from the public API
- `FeedbackDevViewer(directory: Directory)` → `FeedbackDevViewer(directoryPath: String)` — removes `dart:io` from the public API

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

### Features
- Web and desktop platforms now compile without errors
- `DevFileBackend`, `LocalFeedbackBackend`, and `FeedbackDevViewer` gracefully report `UnsupportedError` on web via conditional imports
- `DevFileBackend.isSupported` and `LocalFeedbackBackend.isSupported` static getters for runtime checks
- `FeedbackMiddleware` pipeline — compose transformations (logging, PII redaction, AI categorisation) before every submit
- `AiCategorizationMiddleware` — auto-suggests a category using the Claude API (graceful no-op when key absent)
- `PiiSanitizerMiddleware` — strips email addresses and phone numbers from the feedback message before delivery
- `FeedbackNpsWidget` — 0–10 Net Promoter Score row
- `FeedbackRatingWidget` — 1–5 emoji CSAT row; both fields support required validation
- `FeedbackTrigger` — smart proactive prompt based on launches / days installed / repeat cadence
- `FeedbackAnnotationOverlay` — full-screen drawing overlay for annotating screenshots
- `FeedbackMetadataCollector` — automatically enriches entries with OS, device model, and app info
- `FeedbackSessionContext` — attach user ID, current route, and custom key-value pairs
- `FeedbackAnalytics` interface — event callbacks for shown, submitted, dismissed, voice, screenshot, queued
- `FeedbackLocalizations` with 8 built-in locales (EN, TR, DE, FR, ES, AR, JA, ZH) and a `LocalizationsDelegate`
- `flutter_feedback_kit_firebase` sub-package — Firestore + Storage backend
- `flutter_feedback_kit_sentry` sub-package — Sentry `UserFeedback` backend
- `flutter_feedback_kit_jira` sub-package — Jira Cloud REST API backend
- `flutter_feedback_kit_linear` sub-package — Linear GraphQL API backend
- Mason brick (`flutter_feedback_kit`) for instant project scaffolding
- `LocalFeedbackBackend` — debug-only JSON + PNG file backend
- `FeedbackDevViewer` — in-app log viewer with list, detail, fullscreen screenshot, delete

### Architecture
- `XFile.readAsBytes()` replaces `File(path).readAsBytes()` for cross-platform compatibility
- `WebhookBackend.dispose()` added to close HTTP client
- `FeedbackBackend` base class gains no-op `dispose()` method
- `FeedbackEntry.operator==` and `hashCode` now include `screenshots` list (`listEquals`)
- GitHub Actions CI workflow added (`flutter analyze && flutter test` on every PR)
- `FeedbackButton` now exposes all `FeedbackWidget` props (categories, labels, image constraints)

---

## 0.1.2

- Fix pubspec topics (max 5 allowed)

## 0.1.1

- Add MIT license
- Fix dart doc warnings (0 warnings)
- Broaden version constraints for device_info_plus and package_info_plus

## 0.1.0

- Initial release
- `FeedbackEntry` entity with `FeedbackCategory` enum
- `FeedbackBackend` abstract interface for pluggable backends
- `FeedbackWidget` form with category, message, and screenshot support
- `FeedbackButton` floating action button with bottom sheet
- `WebhookBackend` built-in HTTP POST backend with custom payload support
