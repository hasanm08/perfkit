# Offline Lab

Episode 3 — Reliable Offline Handling

## Simulated network modes

Online | Offline | Slow | Server unavailable | Intermittent

These are **simulated** via `NetworkSimulator`, not device connectivity APIs.

## Scenarios

1. Connectivity ≠ internet
2. Timeouts & retries
3. Offline cache
4. Pending operation queue
5. Explicit synchronization

Pending ops persist under the app support directory as JSON.
