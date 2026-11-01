// ❌ OFFLINE PROBLEM (connectivity):
// BrokenProductRepository.listProducts trusts naiveLinkConnected (Wi-Fi/link)
// as proof of internet access. Captive portals, DNS failures, and 5xx still
// look "connected".
//
// WHY IT IS A PROBLEM:
// Users see hard failures or hangs despite having a link-layer association.
//
// HOW TO FIX:
// Probe actual backend communication; treat timeouts and server errors as
// offline-capable failure modes.
//
// SEE FIXED IMPLEMENTATION:
// lib/features/offline_lab/data/product_repository.dart (ProductRepository)

// ❌ OFFLINE PROBLEM (timeouts/retries):
// NaiveRetry / runWithoutTimeout allow requests to hang and retry forever.
//
// WHY IT IS A PROBLEM:
// UI freezes waiting; batteries and thread pools waste work; thundering herds.
//
// HOW TO FIX:
// Timeouts + bounded exponential backoff with jitter; skip permanent errors.
//
// SEE FIXED IMPLEMENTATION:
// lib/features/offline_lab/data/retry_policy.dart (RetryPolicy)

// ❌ OFFLINE PROBLEM (cache):
// Every screen requires a live network response — no local cache.
//
// WHY IT IS A PROBLEM:
// The app is unusable offline even for previously loaded content.
//
// HOW TO FIX:
// Repository cache with freshness metadata and stale UI indicators.
//
// SEE FIXED IMPLEMENTATION:
// lib/features/offline_lab/data/product_repository.dart

// ❌ OFFLINE PROBLEM (queue):
// Favorite toggles throw away user intent when offline.
//
// WHY IT IS A PROBLEM:
// Silent data loss destroys trust.
//
// HOW TO FIX:
// Persist pending ops with idempotency keys; flush on reconnect.
//
// SEE FIXED IMPLEMENTATION:
// ProductRepository.setFavorite / flushPending

// ❌ OFFLINE PROBLEM (sync):
// Assuming "online" means local changes are synchronized.
//
// WHY IT IS A PROBLEM:
// Conflicts and dropped ops go unnoticed.
//
// HOW TO FIX:
// Explicit synchronize(), conflict policy, visible sync state.
//
// SEE FIXED IMPLEMENTATION:
// ProductRepository.synchronize
