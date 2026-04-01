# Dev Feedback Log

Issues found and fixed during manual testing with `feedback_tester`.

## Fixed

| # | Date | Issue | Fix | Commit |
|---|------|-------|-----|--------|
| 1 | 2026-04-01 | FeedbackScope capture overlay not appearing — `Overlay.of(context)` fails when scope is above MaterialApp | Replaced Overlay API with Stack-based approach | 2533f03 |
| 2 | 2026-04-01 | DevFileBackend uses dart:io, crashes on web | Created _LocalBackend with SharedPreferences for tester | ff289c1 |
| 3 | 2026-04-01 | FeedbackButton (extended FAB) too large and intrusive | Changed to FloatingActionButton.small | ff289c1 |
| 4 | 2026-04-01 | Feedback FAB visible during capture mode — clutters screen | Hide FeedbackButton when `isCaptureActive` | ff289c1 |
| 5 | 2026-04-01 | FeedbackButton doesn't reappear after capture ends — StatelessWidget not rebuilding | Added InheritedWidget (_FeedbackScopeInherited) for reactive rebuilds | pending |
| 6 | 2026-04-01 | Rating/NPS have no "unselected" state — users may submit accidental ratings | Already null by default; added `isRatingRequired`/`isNpsRequired` validation with error messages | pending |
| 7 | 2026-04-01 | No vignette effect in capture mode — unclear that capture is active | Added RadialGradient vignette overlay during capture | 076599d |

## Open

_None currently._
