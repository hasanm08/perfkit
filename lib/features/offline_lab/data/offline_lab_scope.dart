import 'mock_backend.dart';
import 'network_simulator.dart';
import 'product_repository.dart';

/// Shared Offline Lab services for the app session.
class OfflineLabScope {
  OfflineLabScope() {
    network = NetworkSimulator();
    backend = MockBackend();
    repository = ProductRepository(backend: backend, network: network);
    broken = BrokenProductRepository(backend: backend, network: network);
  }

  late final NetworkSimulator network;
  late final MockBackend backend;
  late final ProductRepository repository;
  late final BrokenProductRepository broken;

  Future<void> init() => repository.load();
}
