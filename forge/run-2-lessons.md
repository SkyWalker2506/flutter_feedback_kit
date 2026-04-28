# Forge Run 2 Lessons
_Date: 2026-04-22_

## What went well
- EmailFeedbackBackend generates both plain-text and HTML variants automatically — better UX for email clients
- Partial queue flush design is now correct: removeAt(0) in a loop means if entries 1-3 succeed and 4 fails, entries 1-3 are gone from queue and only 4-5 remain
- CI expansion was straightforward — just copy/paste the linear CI job pattern

## Issues encountered
1. **Abstract class method with body still triggers analyzer**: Adding `removeAt` with a default body to `FeedbackQueue` (abstract class) caused `non_abstract_class_inherits_abstract_member` on `SharedPrefsQueue`. This is because the method references other abstract methods (`pending`, `clear`, `enqueue`). Dart's analyzer treats this as abstract regardless of the body being present.
   - **Fix**: Override `removeAt` explicitly in `SharedPrefsQueue` with an efficient O(n) list manipulation

## Patterns / decisions
- `removeAt(0)` loop is intentional: after each removal the queue shifts, so "index 0" is always the next undelivered entry. This is O(n²) for large queues but correct and simple.
- SendGrid returns `202 Accepted` (not 200 OK) — the `EmailFeedbackException` check must use `!= 202`
- Security comment on `EmailFeedbackBackend` follows the same pattern as GitHubFeedbackBackend: never embed API keys in binary

## For next runs
- `InMemorySharedPreferencesAsync` is the right tool for testing `SharedPreferencesAsync`-based code — note the import path: `package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart`
