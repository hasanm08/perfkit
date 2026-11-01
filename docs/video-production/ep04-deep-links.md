# Episode 4 — Deep Link Lab

## Launch

```bash
flutter run -d macos
# Optional device deep link after platform config:
# adb shell am start -a android.intent.action.VIEW -d "perfkit://app/products/p1"
```

## Demo flow

Cold vs warm → auth redirect → nested tabs → invalid URL → notification queue
