import 'package:flutter/widgets.dart';

import '../../../core/models/lab_scenario.dart';
import '../../../core/widgets/lab_demo_controller.dart';
import '../data/offline_lab_scope.dart';
import '../presentation/widgets/catalog_demo.dart';

List<LabScenario> buildOfflineScenarios(OfflineLabScope scope) => [
  _Scenario(
    id: 'off-connectivity',
    title: '1. Connectivity ≠ Internet',
    problem: 'Broken code assumes Wi-Fi/mobile link guarantees backend access.',
    diagnosis:
        'Toggle Server unavailable while link still looks "connected". '
        'Broken trusts the flag; Fixed requires a successful request.',
    fix:
        'Distinguish link connectivity from successful API communication. '
        'Handle DNS failures, captive portals, timeouts, and 5xx.',
    brokenPath: 'lib/features/offline_lab/data/product_repository.dart (BrokenProductRepository)',
    fixedPath: 'lib/features/offline_lab/data/product_repository.dart (ProductRepository)',
    focus: OfflineFocus.connectivity,
    scope: scope,
  ),
  _Scenario(
    id: 'off-timeouts',
    title: '2. Timeouts & Retry Policies',
    problem: 'Requests hang indefinitely; errors retry immediately forever.',
    diagnosis:
        'Use Slow / Server unavailable modes. Broken may hang; Fixed '
        'times out and applies bounded backoff.',
    fix:
        'Connection/receive timeouts, bounded retries, exponential backoff '
        'with jitter; do not retry permanent errors.',
    brokenPath: 'lib/features/offline_lab/data/retry_policy.dart (NaiveRetry)',
    fixedPath: 'lib/features/offline_lab/data/retry_policy.dart (RetryPolicy)',
    focus: OfflineFocus.timeouts,
    scope: scope,
  ),
  _Scenario(
    id: 'off-cache',
    title: '3. Offline Cache',
    problem: 'Every screen requires a live network response.',
    diagnosis:
        'Load once online, switch Offline, press Start. Fixed still shows '
        'cached products with a stale badge.',
    fix: 'Repository abstraction with cache freshness and clear stale UI.',
    brokenPath:
        'lib/features/offline_lab/data/product_repository.dart (Broken)',
    fixedPath: 'lib/features/offline_lab/data/product_repository.dart (Fixed)',
    focus: OfflineFocus.cache,
    scope: scope,
  ),
  _Scenario(
    id: 'off-queue',
    title: '4. Pending Operation Queue',
    problem: 'User favorite toggles are lost while offline.',
    diagnosis:
        'Go Offline, tap favorite. Broken errors/drops; Fixed enqueues '
        'idempotent ops and flushes later.',
    fix:
        'Persist pending operations, track states, idempotency keys, '
        'safe retry on reconnect.',
    brokenPath: 'lib/features/offline_lab/data/product_repository.dart (Broken setFavorite)',
    fixedPath: 'lib/features/offline_lab/data/product_repository.dart (queue)',
    focus: OfflineFocus.queue,
    scope: scope,
  ),
  _Scenario(
    id: 'off-sync',
    title: '5. Reconnection & Synchronization',
    problem: 'Assumes becoming online automatically means data is synced.',
    diagnosis:
        'Queue edits offline, go Online, compare Broken (assumes synced) '
        'vs Fixed explicit synchronize() + conflict state.',
    fix:
        'Explicit sync process, duplicate safety, conflict policy, '
        'visible sync state.',
    brokenPath:
        'lib/features/offline_lab/presentation/widgets/catalog_demo.dart',
    fixedPath:
        'lib/features/offline_lab/data/product_repository.dart (synchronize)',
    focus: OfflineFocus.sync,
    scope: scope,
  ),
];

class _Scenario extends LabScenario {
  _Scenario({
    required this.id,
    required this.title,
    required String problem,
    required String diagnosis,
    required String fix,
    required String brokenPath,
    required String fixedPath,
    required this.focus,
    required this.scope,
  }) : problemSummary = problem,
       diagnosis = diagnosis,
       recommendedFix = fix,
       brokenSourcePath = brokenPath,
       fixedSourcePath = fixedPath;

  @override
  final String id;
  @override
  final String title;
  @override
  final String problemSummary;
  @override
  final String diagnosis;
  @override
  final String recommendedFix;
  @override
  final String brokenSourcePath;
  @override
  final String fixedSourcePath;
  final OfflineFocus focus;
  final OfflineLabScope scope;

  @override
  Widget buildDemo({
    required bool useFixed,
    required LabDemoController controller,
  }) {
    return CatalogDemo(
      scope: scope,
      controller: controller,
      useFixed: useFixed,
      focus: focus,
    );
  }
}
