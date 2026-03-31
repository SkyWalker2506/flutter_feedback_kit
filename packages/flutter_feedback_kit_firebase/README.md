# flutter_feedback_kit_firebase

Firebase Firestore + Storage backend for [flutter_feedback_kit](https://pub.dev/packages/flutter_feedback_kit).

## Installation

```yaml
dependencies:
  flutter_feedback_kit: ^0.1.2
  flutter_feedback_kit_firebase: ^0.1.0
```

## Setup

1. Complete Firebase setup (`google-services.json` / `GoogleService-Info.plist`)
2. Call `await Firebase.initializeApp()` at app start
3. Use `FirebaseFeedbackBackend` as your backend

## Usage

```dart
FeedbackButton(
  backend: QueuedBackend(
    backend: FirebaseFeedbackBackend(
      collection: 'feedback',
      screenshotsBucket: 'feedback-screenshots',
    ),
    queue: SharedPrefsQueue(),
  ),
  appVersion: '1.0.0',
)
```

Screenshots are uploaded to Firebase Storage and replaced with download URLs in Firestore — keeping document sizes small.
