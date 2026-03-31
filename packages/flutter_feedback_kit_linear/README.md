# flutter_feedback_kit_linear

Linear issue tracker backend for [flutter_feedback_kit](https://pub.dev/packages/flutter_feedback_kit).

## Installation

```yaml
dependencies:
  flutter_feedback_kit: ^0.1.2
  flutter_feedback_kit_linear: ^0.1.0
```

## Setup

1. Create a Linear API key at **Settings → API → Personal API keys**.
2. Find your **Team ID** from the Linear app URL or via the API.
3. Optionally note your **Project ID** if you want issues scoped to a project.

## Usage

```dart
FeedbackButton(
  backend: LinearFeedbackBackend(
    apiKey: 'lin_api_xxxx',
    teamId: 'your-team-uuid',
  ),
  appVersion: '1.0.0',
)
```

With optional project assignment and offline queue:

```dart
FeedbackButton(
  backend: QueuedBackend(
    backend: LinearFeedbackBackend(
      apiKey: 'lin_api_xxxx',
      teamId: 'your-team-uuid',
      projectId: 'your-project-uuid',
    ),
    queue: SharedPrefsQueue(),
  ),
  appVersion: '1.0.0',
)
```

Each submission creates a Linear issue with:
- **Title:** `[Feedback] {Category}: {message}`
- **Description:** Full message, platform, app version, device info, and session context in Markdown
