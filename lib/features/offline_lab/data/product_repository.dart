import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'mock_backend.dart';
import 'network_simulator.dart';
import 'offline_persistence_stub.dart'
    if (dart.library.io) 'offline_persistence_io.dart'
    as persist;
import 'product_models.dart';
import 'retry_policy.dart';

// ✅ OPTIMIZATION:
// Repository serves cached data when the network fails, persists a pending
// operation queue with idempotency keys, applies RetryPolicy timeouts, and
// exposes an explicit synchronize() with conflict detection.
//
// WHY IT WORKS:
// Connectivity, caching, queueing, and sync are separate concerns with
// visible state — users never lose edits and never assume "online ⇒ synced".
//
// PRODUCTION NOTE:
// Pair this with conflict UX and server-side idempotency for real systems.

/// Fixed offline-capable repository with cache + pending queue + sync.
class ProductRepository extends ChangeNotifier {
  ProductRepository({
    required this.backend,
    required this.network,
    this.policy = const RetryPolicy(),
  });

  final MockBackend backend;
  final NetworkSimulator network;
  final RetryPolicy policy;

  List<Product> _cache = [];
  DateTime? _cacheAt;
  Set<String> _favorites = {};
  int _localRevision = 1;
  final List<PendingFavoriteOp> _pending = [];
  SyncState syncState = SyncState.idle;
  bool stale = false;

  List<Product> get products => List.unmodifiable(_cache);
  Set<String> get favorites => Set.unmodifiable(_favorites);
  List<PendingFavoriteOp> get pending => List.unmodifiable(_pending);
  Duration? get cacheAge =>
      _cacheAt == null ? null : DateTime.now().difference(_cacheAt!);

  Future<void> load() async {
    await _restore();
    try {
      await refresh();
    } catch (_) {
      stale = _cache.isNotEmpty;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    final list = await policy.execute(
      network,
      'GET /products',
      backend.listProducts,
    );
    final favs = await policy.execute(
      network,
      'GET /favorites',
      backend.getFavorites,
    );
    _cache = list;
    _favorites = {...favs};
    _cacheAt = DateTime.now();
    stale = false;
    await _persistCache();
    notifyListeners();
  }

  Future<Product?> getProduct(String id) async {
    try {
      return await policy.execute(
        network,
        'GET /products/$id',
        () => backend.getProduct(id),
      );
    } catch (_) {
      try {
        return _cache.firstWhere((p) => p.id == id);
      } catch (_) {
        return null;
      }
    }
  }

  Future<void> setFavorite(String productId, {required bool favorite}) async {
    final op = PendingFavoriteOp(
      id: 'op-${DateTime.now().microsecondsSinceEpoch}-$productId',
      productId: productId,
      favorite: favorite,
      createdAt: DateTime.now(),
    );
    if (favorite) {
      _favorites.add(productId);
    } else {
      _favorites.remove(productId);
    }
    _pending.add(op);
    await _persistQueue();
    notifyListeners();
    await flushPending();
  }

  Future<void> flushPending() async {
    if (_pending.isEmpty) return;
    syncState = SyncState.syncing;
    notifyListeners();
    for (final op in List<PendingFavoriteOp>.from(_pending)) {
      if (op.status == PendingOpStatus.done) continue;
      op.status = PendingOpStatus.inFlight;
      op.attempts++;
      notifyListeners();
      try {
        await policy.execute(
          network,
          'POST /favorites/${op.productId}',
          () => backend.setFavorite(op.productId, favorite: op.favorite),
        );
        op.status = PendingOpStatus.done;
        _pending.removeWhere((e) => e.id == op.id);
      } catch (_) {
        op.status = PendingOpStatus.failed;
      }
    }
    syncState = _pending.isEmpty ? SyncState.synced : SyncState.error;
    await _persistQueue();
    notifyListeners();
  }

  Future<void> synchronize() async {
    syncState = SyncState.syncing;
    notifyListeners();
    try {
      await flushPending();
      final result = await policy.execute(
        network,
        'POST /sync',
        () => backend.syncFavorites(_favorites, _localRevision),
      );
      if (result.conflict) {
        _favorites = {...result.favorites};
        _localRevision = result.revision;
        syncState = SyncState.conflict;
      } else {
        _favorites = {...result.favorites};
        _localRevision = result.revision;
        syncState = SyncState.synced;
      }
      await _persistCache();
    } catch (_) {
      syncState = SyncState.error;
    }
    notifyListeners();
  }

  Future<void> _persistQueue() async {
    if (kIsWeb) return;
    await persist.writeJson(
      'perfkit_pending_ops.json',
      jsonEncode(_pending.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> _persistCache() async {
    if (kIsWeb) return;
    await persist.writeJson(
      'perfkit_product_cache.json',
      jsonEncode({
        'at': _cacheAt?.toIso8601String(),
        'favorites': _favorites.toList(),
        'revision': _localRevision,
        'products': _cache.map((e) => e.toJson()).toList(),
      }),
    );
  }

  Future<void> _restore() async {
    if (kIsWeb) return;
    try {
      final q = await persist.readJson('perfkit_pending_ops.json');
      if (q != null) {
        final list = jsonDecode(q) as List<dynamic>;
        _pending
          ..clear()
          ..addAll(
            list.map(
              (e) => PendingFavoriteOp.fromJson(e as Map<String, dynamic>),
            ),
          );
      }
      final c = await persist.readJson('perfkit_product_cache.json');
      if (c != null) {
        final data = jsonDecode(c) as Map<String, dynamic>;
        _cache = (data['products'] as List<dynamic>)
            .map((e) => Product.fromJson(e as Map<String, dynamic>))
            .toList();
        _favorites = {...(data['favorites'] as List<dynamic>).cast<String>()};
        _localRevision = data['revision'] as int? ?? 1;
        _cacheAt = data['at'] != null
            ? DateTime.tryParse(data['at'] as String)
            : null;
        stale = true;
      }
    } catch (_) {}
  }
}

// ❌ OFFLINE PROBLEM:
// Requires network for every read; trusts link connectivity; drops edits.
// See examples/broken/broken_patterns.dart for the five-problem commentary.
class BrokenProductRepository {
  BrokenProductRepository({required this.backend, required this.network});

  final MockBackend backend;
  final NetworkSimulator network;

  Future<List<Product>> listProducts() async {
    if (!network.naiveLinkConnected) {
      throw SimulatedNetworkException('No Wi-Fi — giving up');
    }
    return network.runWithoutTimeout(
      'GET /products (broken)',
      backend.listProducts,
    );
  }

  Future<void> setFavorite(String id, {required bool favorite}) async {
    if (!network.naiveLinkConnected) {
      throw SimulatedNetworkException('Offline — favorite lost');
    }
    await network.runWithoutTimeout(
      'POST /favorites (broken)',
      () => backend.setFavorite(id, favorite: favorite),
    );
  }
}
