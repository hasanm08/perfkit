# PerfKit Architecture

PerfKit is a single Flutter educational product with five independently accessible labs.

## Principles

- Feature-first modules under `lib/features/`
- Broken demos isolated in `examples/broken/`; fixed references in `examples/fixed/`
- Shared comparison UX via `LabComparisonScaffold`
- Lightweight state: `ValueNotifier` / `ChangeNotifier`
- Routing: `go_router` (required for Deep Link Lab realism)
- Offline persistence: `path_provider` + JSON
- Metrics are tagged `actual` | `counter` | `simulated`

## Layers

| Area | Responsibility |
|------|----------------|
| `lib/app` | Theme, shell, router, `PerfKitApp` |
| `lib/core` | Diagnostics, logging, progress, comparison widgets |
| `lib/features/*` | Labs + About/Overview |

## Diagnostics honesty

- `FrameTimingMonitor` uses engine frame timings (debug ≠ release)
- `RebuildCounter` / `LifecycleCounters` are educational instrumentation
- `MemoryProbe` reports RSS when `dart:io` is available
- Never treat custom counters as DevTools proof
