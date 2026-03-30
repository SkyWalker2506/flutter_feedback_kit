## 0.1.0

- Initial release
- `FeedbackEntry` entity with `FeedbackCategory` enum
- `FeedbackBackend` abstract interface for pluggable backends
- `FeedbackWidget` form with category, message, and screenshot support
- `FeedbackButton` floating action button with bottom sheet
- `WebhookBackend` built-in HTTP POST backend with custom payload support
