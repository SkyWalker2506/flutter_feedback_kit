# flutter_feedback_kit

A Flutter package for collecting in-app user feedback with a customizable widget and pluggable backends.

## Features

- Drop-in `FeedbackButton` (floating action button) and `FeedbackWidget` (form)
- Category selection (Bug, Suggestion, UI/UX, Performance, Other)
- Optional screenshot attachment (up to 3 images)
- Pluggable `FeedbackBackend` interface — bring your own backend
- Built-in `WebhookBackend` for Slack, Discord, or any HTTP endpoint

## Installation

```yaml
dependencies:
  flutter_feedback_kit: ^0.1.0
```

## Usage

### 1. Add a FeedbackButton to your Scaffold

```dart
import 'package:flutter_feedback_kit/flutter_feedback_kit.dart';

Scaffold(
  floatingActionButton: FeedbackButton(
    backend: WebhookBackend(url: 'https://your-webhook-url.com/feedback'),
    appVersion: '1.0.0',
    onSuccess: () => print('Sent!'),
    onError: (e) => print('Error: $e'),
  ),
);
```

### 2. Embed FeedbackWidget directly

```dart
FeedbackWidget(
  backend: WebhookBackend(url: 'https://your-webhook-url.com/feedback'),
  appVersion: '1.0.0',
  onSuccess: () => Navigator.pop(context),
)
```

### 3. Custom backend

```dart
class FirebaseBackend implements FeedbackBackend {
  @override
  Future<void> submit(FeedbackEntry entry) async {
    await FirebaseFirestore.instance
        .collection('feedback')
        .add(entry.toJson());
  }
}
```

### 4. Custom webhook payload (e.g. Slack)

```dart
WebhookBackend(
  url: 'https://hooks.slack.com/services/...',
  payloadBuilder: (entry) => {
    'text': '*${entry.category.label}*: ${entry.message}',
  },
)
```

## FeedbackEntry fields

| Field | Type | Description |
|-------|------|-------------|
| `category` | `FeedbackCategory` | Bug, Suggestion, UI/UX, Performance, Other |
| `message` | `String` | User message (max 2000 chars) |
| `platform` | `String` | `android` / `ios` |
| `appVersion` | `String` | App version string |
| `createdAt` | `DateTime` | Submission timestamp |
| `screenshots` | `List<String>` | Base64-encoded images |
