import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../../app/theme/colors.dart';
import '../../../../core/models/metric_snapshot.dart';
import '../../../../core/widgets/lab_demo_controller.dart';
import '../../data/network_simulator.dart';
import '../../data/offline_lab_scope.dart';
import '../../data/product_models.dart';

enum OfflineFocus { connectivity, timeouts, cache, queue, sync }

class CatalogDemo extends StatefulWidget {
  const CatalogDemo({
    super.key,
    required this.scope,
    required this.controller,
    required this.useFixed,
    required this.focus,
  });

  final OfflineLabScope scope;
  final LabDemoController controller;
  final bool useFixed;
  final OfflineFocus focus;

  @override
  State<CatalogDemo> createState() => _CatalogDemoState();
}

class _CatalogDemoState extends State<CatalogDemo> {
  String? _error;
  String? _selectedId;
  bool _loading = false;
  List<Product> _brokenProducts = const [];

  OfflineLabScope get scope => widget.scope;

  @override
  void initState() {
    super.initState();
    scope.repository.addListener(_refresh);
    scope.network.addListener(_refresh);
    widget.controller.addListener(_onController);
    // Metrics are shown by an ancestor ListenableBuilder. Publishing them
    // from initState runs during build and throws markNeedsBuild.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _publish();
    });
  }

  @override
  void didUpdateWidget(covariant CatalogDemo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.useFixed != widget.useFixed) {
      _error = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _load();
      });
    }
  }

  void _refresh() {
    final phase = SchedulerBinding.instance.schedulerPhase;
    final duringBuild =
        phase == SchedulerPhase.persistentCallbacks ||
        phase == SchedulerPhase.midFrameMicrotasks;
    if (duringBuild) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _refresh();
      });
      return;
    }
    _publish();
    setState(() {});
  }

  void _onController() {
    if (widget.controller.isRunning) {
      _load();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (widget.useFixed) {
        // Fixed path differs by focus.
        switch (widget.focus) {
          case OfflineFocus.connectivity:
          case OfflineFocus.timeouts:
          case OfflineFocus.cache:
            await scope.repository.refresh();
          case OfflineFocus.queue:
            await scope.repository.flushPending();
          case OfflineFocus.sync:
            await scope.repository.synchronize();
        }
      } else {
        switch (widget.focus) {
          case OfflineFocus.connectivity:
            // ❌ Trusts Wi-Fi flag, not actual backend reachability.
            _brokenProducts = await scope.broken.listProducts();
          case OfflineFocus.timeouts:
            // ❌ No timeout — may hang under slow/serverUnavailable.
            _brokenProducts = await scope.broken.listProducts();
          case OfflineFocus.cache:
            _brokenProducts = await scope.broken.listProducts();
          case OfflineFocus.queue:
            if (_selectedId != null) {
              await scope.broken.setFavorite(_selectedId!, favorite: true);
            } else {
              _brokenProducts = await scope.broken.listProducts();
            }
          case OfflineFocus.sync:
            // ❌ Assumes reconnection means synced.
            if (scope.network.naiveLinkConnected) {
              _error = null;
              _brokenProducts = await scope.broken.listProducts();
            }
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) {
        setState(() => _loading = false);
        _publish();
      }
    }
  }

  void _publish() {
    final net = scope.network;
    widget.controller.setMetrics([
      MetricSnapshot(
        label: 'Network mode',
        value: net.mode.name,
        source: MetricSource.simulated,
        note: 'Simulated — not device connectivity',
      ),
      MetricSnapshot(
        label: 'Naive link',
        value: '${net.naiveLinkConnected}',
        source: MetricSource.simulated,
      ),
      MetricSnapshot(
        label: 'Cache items',
        value: '${scope.repository.products.length}',
        source: MetricSource.counter,
      ),
      MetricSnapshot(
        label: 'Pending ops',
        value: '${scope.repository.pending.length}',
        source: MetricSource.counter,
      ),
      MetricSnapshot(
        label: 'Sync state',
        value: scope.repository.syncState.name,
        source: MetricSource.counter,
      ),
      if (scope.repository.stale)
        const MetricSnapshot(
          label: 'Cache',
          value: 'STALE',
          source: MetricSource.counter,
        ),
    ]);
  }

  @override
  void dispose() {
    scope.repository.removeListener(_refresh);
    scope.network.removeListener(_refresh);
    widget.controller.removeListener(_onController);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final products = widget.useFixed
        ? scope.repository.products
        : _brokenProducts;

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _banner(),
              if (_loading) const LinearProgressIndicator(minHeight: 2),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      color: PerfKitColors.danger,
                      fontSize: 12,
                    ),
                  ),
                ),
              if (widget.useFixed && scope.repository.stale)
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    'Showing cached data (stale)',
                    style: TextStyle(
                      color: PerfKitColors.warning,
                      fontSize: 12,
                    ),
                  ),
                ),
              Expanded(
                child: products.isEmpty
                    ? const Center(
                        child: Text(
                          'No products — press Start',
                          style: TextStyle(color: PerfKitColors.secondaryText),
                        ),
                      )
                    : ListView.builder(
                        itemCount: products.length,
                        itemBuilder: (_, i) {
                          final p = products[i];
                          final fav = scope.repository.favorites.contains(p.id);
                          return ListTile(
                            selected: _selectedId == p.id,
                            title: Text(p.name),
                            subtitle: Text(p.priceLabel),
                            trailing: IconButton(
                              icon: Icon(
                                fav ? Icons.favorite : Icons.favorite_border,
                                color: fav ? PerfKitColors.accent : null,
                              ),
                              onPressed: () async {
                                setState(() => _selectedId = p.id);
                                try {
                                  if (widget.useFixed) {
                                    await scope.repository.setFavorite(
                                      p.id,
                                      favorite: !fav,
                                    );
                                  } else {
                                    await scope.broken.setFavorite(
                                      p.id,
                                      favorite: !fav,
                                    );
                                  }
                                  _error = null;
                                } catch (e) {
                                  _error = e.toString();
                                }
                                _publish();
                                setState(() {});
                              },
                            ),
                            onTap: () => setState(() => _selectedId = p.id),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          flex: 2,
          child: _SideInfo(
            network: scope.network,
            pending: scope.repository.pending,
            syncState: scope.repository.syncState,
            selectedId: _selectedId,
          ),
        ),
      ],
    );
  }

  Widget _banner() {
    final color = widget.useFixed ? PerfKitColors.fixed : PerfKitColors.broken;
    final text = switch ((widget.useFixed, widget.focus)) {
      (false, OfflineFocus.connectivity) =>
        // ❌
        'Broken: treats Wi-Fi/link as internet access',
      (true, OfflineFocus.connectivity) =>
        // ✅
        'Fixed: requires successful backend communication',
      (false, OfflineFocus.timeouts) => 'Broken: no timeouts; retries forever',
      (true, OfflineFocus.timeouts) =>
        'Fixed: timeouts + bounded exponential backoff',
      (false, OfflineFocus.cache) => 'Broken: every screen requires network',
      (true, OfflineFocus.cache) =>
        'Fixed: repository serves cache with stale badge',
      (false, OfflineFocus.queue) =>
        'Broken: offline favorite actions are dropped',
      (true, OfflineFocus.queue) =>
        'Fixed: pending ops persisted with idempotency keys',
      (false, OfflineFocus.sync) => 'Broken: assumes online ⇒ synchronized',
      (true, OfflineFocus.sync) => 'Fixed: explicit sync + conflict handling',
    };
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }
}

class _SideInfo extends StatelessWidget {
  const _SideInfo({
    required this.network,
    required this.pending,
    required this.syncState,
    required this.selectedId,
  });

  final NetworkSimulator network;
  final List<PendingFavoriteOp> pending;
  final SyncState syncState;
  final String? selectedId;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const Text(
          'REQUEST LOG (simulated)',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: PerfKitColors.secondaryText,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 8),
        ...network.requestLog.reversed
            .take(12)
            .map(
              (l) => Text(
                l,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 10),
              ),
            ),
        const SizedBox(height: 16),
        Text(
          'PENDING QUEUE (${pending.length})',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: PerfKitColors.secondaryText,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 8),
        if (pending.isEmpty)
          const Text(
            'Empty',
            style: TextStyle(color: PerfKitColors.secondaryText, fontSize: 12),
          )
        else
          ...pending.map(
            (op) => Text(
              '${op.status.name} ${op.productId} fav=${op.favorite} #${op.attempts}',
              style: const TextStyle(fontFamily: 'monospace', fontSize: 10),
            ),
          ),
        const SizedBox(height: 16),
        Text(
          'SYNC: ${syncState.name}',
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
        ),
        if (selectedId != null) ...[
          const SizedBox(height: 8),
          Text(
            'Selected: $selectedId',
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ],
      ],
    );
  }
}
