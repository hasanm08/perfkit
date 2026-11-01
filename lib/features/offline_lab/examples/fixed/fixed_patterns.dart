// ✅ OPTIMIZATION:
// ProductRepository + RetryPolicy implement production-minded offline handling:
// timeouts, bounded retries, cache with stale badges, pending queue, sync state.
//
// WHY IT WORKS:
// Failures are expected and recoverable; user intent is preserved.
//
// PRODUCTION NOTE:
// Simulated NetworkSimulator modes are labeled in the UI — never confuse them
// with real device connectivity APIs.
