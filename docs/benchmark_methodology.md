# Benchmark Methodology

1. Prefer **profile** mode (`flutter run --profile`)
2. Keep device, dataset size, and image resolution constant
3. Run multiple iterations; discard warm-up
4. Record Flutter/Dart versions and device model
5. Do not compare different devices as equivalent
6. Label every UI metric as Actual / Counter / Simulated
7. Use DevTools for authoritative Performance and Memory diagnosis
8. Never invent FPS, frame times, or memory improvement percentages
