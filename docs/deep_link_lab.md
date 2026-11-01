# Deep Link Lab

Episode 4 — Routing and Navigation

## In-app simulation vs device

The link tester simulates cold/warm start, auth, nested routes, invalid URLs, and notification intents.

### Android (device)

Configure intent filters for `perfkit://` / App Links in `android/app/src/main/AndroidManifest.xml`.

### iOS (device)

Configure associated domains / URL types in `ios/Runner/Info.plist`.

Document platform wiring for recording days; in-app paths remain labeled as simulated where OS hooks cannot run.
