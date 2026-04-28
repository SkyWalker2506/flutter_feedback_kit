# Forge Run 1 Lessons
_Date: 2026-04-22_

## What went well
- PiiSanitizerMiddleware design is clean and extensible — custom `patterns` + `replaceWith`
- GitHubFeedbackBackend follows the same pattern as Jira/Linear backends; template reuse was fast
- All tests green on first run with no iteration needed

## Issues encountered
- None — clean run

## Patterns / decisions
- `PiiSanitizerMiddleware` returns the same object (`identical`) when no redaction happens — avoids unnecessary copies and lets callers detect no-op
- `GitHubFeedbackBackend` intentionally excludes base64 screenshot bodies from GitHub issue body (too large); notes screenshot count instead
- Security doc comment on `GitHubFeedbackBackend` warns about token exposure in mobile binaries — recommend server-side proxy pattern

## For next runs
- CHANGELOG duplication won't recur; consolidation complete
- Sub-package pattern (pubspec + analysis_options + lib/ + test/) is now well-established
