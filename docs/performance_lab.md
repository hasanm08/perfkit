# Performance Lab

Episode 1 — Why Is Your Flutter App Slow?

## Scenarios

1. Unnecessary rebuilds — localize ticker state
2. Expensive build — cache / `compute()`
3. Poor lists — `ListView.builder` + `itemExtent`
4. Image decode — `cacheWidth` / `cacheHeight`
5. Expensive paint — fewer layers, honest `shouldRepaint`

## Measuring

```bash
flutter run -d macos --profile
```

Open DevTools → Performance. Enable rebuild tracking for scenario 1. Compare Broken vs Fixed with the same dataset slider values.

Debug-mode stopwatches in the UI are illustrative only.
