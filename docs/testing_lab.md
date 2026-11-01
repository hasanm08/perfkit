# Testing Lab

Episode 5 — Fix Flaky Tests

## Suites

| Suite | Path | CI |
|-------|------|----|
| Deterministic | `test/features/testing_lab/deterministic/` | Included |
| Flaky demos | `test/features/testing_lab/flaky/` | Skipped / isolated |

Flaky tests are intentionally skipped so `flutter test` stays green, while source remains for teaching.

```bash
flutter test test/features/testing_lab/deterministic
flutter test test/features/testing_lab/flaky   # shows skip reasons
```
