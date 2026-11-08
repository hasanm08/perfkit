// ✅ OPTIMIZATION:
// ProductRepository + RetryPolicy implement production-minded offline handling:
// timeouts, bounded retries, cache with stale badges, pending queue, sync state.
//
//? Main fix: probe backend success — do not trust Wi-Fi/link alone.
//? Main fix: timeouts + bounded exponential backoff with jitter.
//? Main fix: serve cache with stale UI when network fails.
//? Main fix: persist pending ops with idempotency keys; flush on reconnect.
//? Main fix: explicit synchronize() with visible conflict/sync state.
//
// WHY IT WORKS:
// Failures are expected and recoverable; user intent is preserved.
//
// PRODUCTION NOTE:
// Simulated NetworkSimulator modes are labeled in the UI — never confuse them
// with real device connectivity APIs.
