import 'package:flutter/material.dart';

import '../../../../app/theme/colors.dart';
import '../../../../core/progress/module_progress_store.dart';
import '../../../../core/widgets/lab_comparison_scaffold.dart';
import '../../data/network_simulator.dart';
import '../../data/offline_lab_scope.dart';
import '../../domain/offline_scenarios.dart';

class OfflineLabPage extends StatefulWidget {
  const OfflineLabPage({
    super.key,
    required this.progress,
    required this.scope,
  });

  final ModuleProgressStore progress;
  final OfflineLabScope scope;

  @override
  State<OfflineLabPage> createState() => _OfflineLabPageState();
}

class _OfflineLabPageState extends State<OfflineLabPage> {
  @override
  void initState() {
    super.initState();
    widget.scope.init();
  }

  @override
  Widget build(BuildContext context) {
    return LabComparisonScaffold(
      labTitle: 'Offline Lab',
      labSubtitle: 'Episode 3 — Reliable Offline Handling',
      scenarios: buildOfflineScenarios(widget.scope),
      onScenarioCompleted: widget.progress.markCompleted,
      toolbarExtras: ListenableBuilder(
        listenable: widget.scope.network,
        builder: (context, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Simulated net',
                style: TextStyle(
                  color: PerfKitColors.secondaryText,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<NetworkMode>(
                value: widget.scope.network.mode,
                underline: const SizedBox.shrink(),
                items: [
                  for (final m in NetworkMode.values)
                    DropdownMenuItem(value: m, child: Text(m.name)),
                ],
                onChanged: (m) {
                  if (m != null) widget.scope.network.setMode(m);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
