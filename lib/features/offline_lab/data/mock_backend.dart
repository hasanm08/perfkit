import 'product_models.dart';

/// Deterministic in-process catalog — no external credentials.
class MockBackend {
  MockBackend() {
    _products = List.generate(
      24,
      (i) => Product(
        id: 'p$i',
        name: 'Product ${i + 1}',
        description: 'Demo catalog item #${i + 1} for Offline Lab.',
        priceCents: 499 + i * 50,
        updatedAt: DateTime.utc(2026, 1, 1).add(Duration(days: i)),
      ),
    );
    _favorites = {'p1', 'p3'};
  }

  late List<Product> _products;
  late Set<String> _favorites;
  int _revision = 1;

  int get revision => _revision;

  Future<List<Product>> listProducts() async => List.unmodifiable(_products);

  Future<Product?> getProduct(String id) async {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<Set<String>> getFavorites() async => Set.unmodifiable(_favorites);

  Future<void> setFavorite(String id, {required bool favorite}) async {
    if (favorite) {
      _favorites.add(id);
    } else {
      _favorites.remove(id);
    }
    _revision++;
  }

  /// Simulates a conflict when client revision is stale.
  Future<SyncResult> syncFavorites(
    Set<String> clientFavorites,
    int clientRevision,
  ) async {
    if (clientRevision < _revision - 1) {
      return SyncResult.conflict(
        serverFavorites: Set.unmodifiable(_favorites),
        serverRevision: _revision,
      );
    }
    _favorites = {...clientFavorites};
    _revision++;
    return SyncResult.ok(
      favorites: Set.unmodifiable(_favorites),
      revision: _revision,
    );
  }
}

class SyncResult {
  SyncResult._({
    required this.ok,
    required this.favorites,
    required this.revision,
    required this.conflict,
  });

  factory SyncResult.ok({
    required Set<String> favorites,
    required int revision,
  }) => SyncResult._(
    ok: true,
    favorites: favorites,
    revision: revision,
    conflict: false,
  );

  factory SyncResult.conflict({
    required Set<String> serverFavorites,
    required int serverRevision,
  }) => SyncResult._(
    ok: false,
    favorites: serverFavorites,
    revision: serverRevision,
    conflict: true,
  );

  final bool ok;
  final bool conflict;
  final Set<String> favorites;
  final int revision;
}
