# flutter_feedback_kit brick

A [Mason](https://pub.dev/packages/mason_cli) brick that generates a `feedback_setup.dart` file
with a fully configured `FeedbackButton` for your Flutter app.

## Usage

```sh
# Install mason CLI if not already installed
dart pub global activate mason_cli

# Add the brick (from local path)
mason add flutter_feedback_kit --path ./bricks/flutter_feedback_kit

# Generate the file
mason make flutter_feedback_kit
```

## Variables

| Variable               | Type    | Default                         | Description                                                |
|------------------------|---------|---------------------------------|------------------------------------------------------------|
| `backend`              | enum    | `webhook`                       | Backend to use: `webhook`, `firebase`, or `linear`         |
| `webhook_url`          | string  | `https://example.com/feedback`  | Endpoint URL (webhook backend only)                        |
| `app_version`          | string  | `1.0.0`                         | App version string embedded in every feedback entry        |
| `use_ai_categorization`| boolean | `false`                         | Add `AiCategorizationMiddleware` (requires Anthropic key)  |

## What gets generated

Running `mason make flutter_feedback_kit` creates `feedback_setup.dart` containing:

- A `createFeedbackBackend()` factory configured for the chosen backend
- A `createMiddlewares()` function (with `AiCategorizationMiddleware` when opted in)
- An example `HomeScreen` widget with `FeedbackButton` wired up

### Backend-specific setup

**webhook** — No extra package needed. The generated URL points to `webhook_url`.

**firebase** — Add `flutter_feedback_kit_firebase` to `pubspec.yaml` and ensure
`Firebase.initializeApp()` is called before using the backend.

**linear** — Add `flutter_feedback_kit_linear` to `pubspec.yaml`. Load your Linear
API key from remote config; never hard-code it.

### AI categorization

When enabled, `AiCategorizationMiddleware` calls the Claude API to auto-suggest a
feedback category. Set `ANTHROPIC_API_KEY` via `--dart-define` or load it from
remote config at runtime.

```sh
flutter run --dart-define=ANTHROPIC_API_KEY=sk-ant-...
```

## pubspec.yaml snippets

### Webhook
```yaml
dependencies:
  flutter_feedback_kit: ^0.1.0
```

### Firebase
```yaml
dependencies:
  flutter_feedback_kit: ^0.1.0
  flutter_feedback_kit_firebase: ^0.1.0
```

### Linear
```yaml
dependencies:
  flutter_feedback_kit: ^0.1.0
  flutter_feedback_kit_linear: ^0.1.0
```
