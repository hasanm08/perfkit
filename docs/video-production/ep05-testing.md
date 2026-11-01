# Episode 5 — Testing Lab

## Commands

```bash
flutter test test/features/testing_lab/deterministic
flutter test test/features/testing_lab/flaky
```

## Talking points

- Await completion, not delays
- Inject clocks/network
- Isolate fixtures
- Explicit pump vs pumpAndSettle
- CI excludes intentional flaky demos
