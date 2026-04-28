# Forge Run 3 Lessons
_Date: 2026-04-22_

## What went well
- `InMemorySharedPreferencesAsync` pattern worked cleanly once the platform interface was added as a dev dependency
- FeedbackTrigger tests cover all meaningful branches (never-show, per-version, repeatAfterDays) in isolation
- Full 78-test suite passes with zero failures after all 3 runs

## Issues encountered
1. **`SharedPreferences.setMockInitialValues` doesn't work for `SharedPreferencesAsync`**: The legacy mock helper sets up the old platform channel mock, not the newer async platform. `SharedPreferencesAsync` uses `SharedPreferencesAsyncPlatform.instance` which must be set separately.
   - **Fix**: `SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty()` in `setUp`
   - **Import**: `package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart`
   - **Dep**: must add `shared_preferences_platform_interface` explicitly to dev_dependencies (it's transitive but not importable without explicit declaration)

2. **`analysis/` directory is gitignored**: Sprint plan update couldn't be committed. Sprint plans live in gitignored analysis/ — this is intentional (local working docs). Not a bug.

## Patterns / decisions
- `FeedbackTrigger` is `const` so it can't have injected dependencies. Test isolation via platform-level mock is cleaner than refactoring the trigger to be non-const.
- `oncePerVersion` tests use different version strings to simulate upgrades — simple and readable

## Overall forge cycle retrospective
- 3 runs completed in one session, all merged to main
- The sub-package pattern (github, email) is now fully proven and repeatable
- The main blocker pattern: abstract class methods with bodies referencing other abstract members need concrete overrides in implementers — document this in contributor guide if the project grows
- Ecosystem now has 6 backend sub-packages: firebase, sentry, jira, linear, github, email
