class Product {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.priceCents,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String description;
  final int priceCents;
  final DateTime updatedAt;

  String get priceLabel => '\$${(priceCents / 100).toStringAsFixed(2)}';

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'priceCents': priceCents,
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    priceCents: json['priceCents'] as int,
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );
}

enum PendingOpStatus { queued, inFlight, failed, done }

class PendingFavoriteOp {
  PendingFavoriteOp({
    required this.id,
    required this.productId,
    required this.favorite,
    required this.createdAt,
    this.status = PendingOpStatus.queued,
    this.attempts = 0,
  });

  final String id;
  final String productId;
  final bool favorite;
  final DateTime createdAt;
  PendingOpStatus status;
  int attempts;

  Map<String, dynamic> toJson() => {
    'id': id,
    'productId': productId,
    'favorite': favorite,
    'createdAt': createdAt.toIso8601String(),
    'status': status.name,
    'attempts': attempts,
  };

  factory PendingFavoriteOp.fromJson(Map<String, dynamic> json) =>
      PendingFavoriteOp(
        id: json['id'] as String,
        productId: json['productId'] as String,
        favorite: json['favorite'] as bool,
        createdAt: DateTime.parse(json['createdAt'] as String),
        status: PendingOpStatus.values.byName(
          json['status'] as String? ?? 'queued',
        ),
        attempts: json['attempts'] as int? ?? 0,
      );
}

enum SyncState { idle, syncing, synced, conflict, error }
