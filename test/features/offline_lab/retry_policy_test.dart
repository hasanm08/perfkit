import 'package:flutter_test/flutter_test.dart';
import 'package:perfkit/features/offline_lab/data/network_simulator.dart';
import 'package:perfkit/features/offline_lab/data/retry_policy.dart';

void main() {
  test('RetryPolicy succeeds after transient failures', () async {
    final net = NetworkSimulator()..setMode(NetworkMode.online);
    var attempts = 0;
    final result = await const RetryPolicy(maxAttempts: 3)
        .execute(net, 'probe', () async {
          attempts++;
          if (attempts < 2) {
            throw SimulatedNetworkException('transient');
          }
          return 42;
        });
    expect(result, 42);
    expect(attempts, 2);
  });

  test('NetworkSimulator offline throws', () async {
    final net = NetworkSimulator()..setMode(NetworkMode.offline);
    await expectLater(
      net.run('x', () async => 1),
      throwsA(isA<SimulatedNetworkException>()),
    );
  });
}
