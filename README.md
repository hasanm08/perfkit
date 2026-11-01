# PerfKit

**Measure. Diagnose. Optimize.**

A hands-on Flutter engineering playground for the FlowForge YouTube series. Five labs demonstrate common production problems with intentionally broken implementations and production-quality fixes.

## Labs

1. **Performance Lab** — rebuilds, expensive build, lists, images, paint
2. **Memory Lab** — controllers, timers, lifecycle, image cache, closures
3. **Offline Lab** — connectivity, timeouts, cache, pending queue, sync
4. **Deep Link Lab** — cold/warm, auth, nested nav, invalid links, notifications
5. **Testing Lab** — async timing, deps, platform, shared state, widgets

## Quick start

```bash
flutter pub get
flutter run -d macos --profile   # preferred for performance demos
flutter run -d chrome
flutter test
```

## Recording launch cheatsheet

| Episode | Command / navigation |
|---------|----------------------|
| 1 Performance | `flutter run -d macos --profile` → Performance |
| 2 Memory | `flutter run -d macos --profile` → Memory |
| 3 Offline | `flutter run -d macos` → Offline (use Simulated net dropdown) |
| 4 Deep Links | `flutter run -d macos` → Deep Links |
| 5 Testing | `flutter test test/features/testing_lab/deterministic` |

See `docs/video-production/` for full episode guides.

## Measurement honesty

Debug-mode timings are not release performance. Custom counters are educational — use Flutter DevTools for authoritative diagnosis. Metrics in the UI are labeled **Actual**, **Counter**, or **Simulated**.

## Documentation

- [Architecture](docs/architecture.md)
- [Benchmark methodology](docs/benchmark_methodology.md)
- Per-lab docs under `docs/`
