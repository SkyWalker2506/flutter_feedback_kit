# flutter_feedback_kit

[![CI](https://github.com/SkyWalker2506/flutter_feedback_kit/actions/workflows/ci.yml/badge.svg)](https://github.com/SkyWalker2506/flutter_feedback_kit/actions/workflows/ci.yml)

A Flutter package for collecting in-app user feedback — drop-in widget, voice input, offline queue, screenshot capture, and a pluggable backend interface.

## Features

- **`FeedbackButton`** — FAB that opens a feedback form in a bottom sheet
- **`FeedbackWidget`** — inline form for embedding anywhere in your UI
- **8 categories** — Bug, Suggestion, UI/UX, Performance, Translation, Feature Request, Accessibility, Other
- **Voice input** — optional speech-to-text with `SpeechRecognitionService`
- **Screenshot attachment** — gallery picker + screen capture callback (up to 5 images)
- **Offline queue** — `QueuedBackend` + `SharedPrefsQueue` persist feedback across restarts
- **Pluggable backend** — implement `FeedbackBackend` for any service
- **Built-in `WebhookBackend`** — POST to Slack, Discord, n8n, or any HTTPS endpoint
- **Custom theming** — `FeedbackThemeData` / `FeedbackTheme` for colours, padding, corner radius
- **`LocalFeedbackBackend` + `FeedbackDevViewer`** — debug-only local sink with in-app viewer

## Installation

```yaml
dependencies:
  flutter_feedback_kit: ^0.1.0
```

### Platform notes

**Android** — add to `AndroidManifest.xml` if using voice input:
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
```

**iOS** — add to `Info.plist` if using voice input:
```xml
<key>NSSpeechRecognitionUsageDescription</key>
<string>Used for voice feedback input</string>
<key>NSMicrophoneUsageDescription</key>
<string>Used for voice feedback input</string>
```

---

## Usage

### 1. Basic — FeedbackButton

```dart
import 'package:flutter_feedback_kit/flutter_feedback_kit.dart';

Scaffold(
  floatingActionButton: FeedbackButton(
    backend: WebhookBackend(url: 'https://your-webhook.example.com/feedback'),
    appVersion: '1.0.0',
    onSuccess: () => print('Sent!'),
    onError: (e) => print('Error: $e'),
  ),
  body: MyApp(),
);
```

### 2. Inline — FeedbackWidget

```dart
FeedbackWidget(
  backend: WebhookBackend(url: 'https://your-webhook.example.com/feedback'),
  appVersion: '1.0.0',
  onSuccess: () => Navigator.pop(context),
)
```

### 3. Voice input

```dart
FeedbackWidget(
  backend: myBackend,
  appVersion: '1.0.0',
  speechService: SpeechRecognitionService(), // mic button appears automatically
)
```

### 4. Offline queue

Wrap any backend with `QueuedBackend` — entries are persisted when offline and
flushed on the next call when connectivity is restored.

```dart
final backend = QueuedBackend(
  backend: WebhookBackend(url: 'https://example.com/feedback'),
  queue: SharedPrefsQueue(),
);

// Later, when connectivity is restored:
await (backend as QueuedBackend).flushQueue();
```

### 5. Custom webhook payload (e.g. Slack)

```dart
WebhookBackend(
  url: 'https://hooks.slack.com/services/...',
  payloadBuilder: (entry) => {
    'text': '*[${entry.category.label}]* ${entry.message}\n'
            '_${entry.platform} • v${entry.appVersion}_',
  },
)
```

### 6. Custom backend

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

### 7. Custom theming

```dart
FeedbackButton(
  backend: myBackend,
  appVersion: '1.0.0',
  theme: FeedbackThemeData(
    submitButtonColor: Colors.teal,
    backgroundColor: const Color(0xFF1E1E2E),
    contentPadding: const EdgeInsets.all(24),
    sheetBorderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
  ),
)
```

Or wrap with `FeedbackTheme` for inherited theming:

```dart
FeedbackTheme(
  data: FeedbackThemeData(submitButtonColor: Colors.deepPurple),
  child: FeedbackWidget(backend: myBackend, appVersion: '1.0.0'),
)
```

### 8. Debug viewer (emulator / local testing)

Import from the separate `local` export to keep the main package web-compatible:

```dart
import 'package:path_provider/path_provider.dart';
import 'package:flutter_feedback_kit/local.dart'; // LocalFeedbackBackend + FeedbackDevViewer

final dir = await getApplicationDocumentsDirectory();
final feedbackDir = Directory('${dir.path}/feedback');

// Use LocalFeedbackBackend in debug builds:
final backend = kDebugMode
    ? LocalFeedbackBackend(directory: feedbackDir)
    : WebhookBackend(url: 'https://example.com/feedback');

// Open the in-app viewer:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => FeedbackDevViewer(directory: feedbackDir),
  ),
);
```

---

## API reference

### FeedbackEntry fields

| Field | Type | Description |
|-------|------|-------------|
| `category` | `FeedbackCategory` | Selected category |
| `message` | `String` | User message (max 2 000 chars) |
| `platform` | `String` | `android` / `ios` / `web` |
| `appVersion` | `String` | App version string |
| `createdAt` | `DateTime` | UTC submission timestamp |
| `screenshots` | `List<String>` | Base64-encoded PNG images |

### FeedbackCategory values

`bug` · `suggestion` · `ui` · `performance` · `translation` · `featureRequest` · `accessibility` · `other`

### FeedbackThemeData

| Property | Type | Default |
|----------|------|---------|
| `backgroundColor` | `Color?` | `ColorScheme.surface` |
| `submitButtonColor` | `Color?` | `ColorScheme.primary` |
| `contentPadding` | `EdgeInsets` | `EdgeInsets.all(16)` |
| `sheetBorderRadius` | `BorderRadius` | `vertical(top: Radius.circular(16))` |
