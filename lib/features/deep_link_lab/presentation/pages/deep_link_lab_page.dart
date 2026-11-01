import 'package:flutter/material.dart';

import '../../../../core/progress/module_progress_store.dart';
import '../../../../core/widgets/lab_comparison_scaffold.dart';
import '../../domain/deep_link_scenarios.dart';

class DeepLinkLabPage extends StatelessWidget {
  const DeepLinkLabPage({
    super.key,
    required this.progress,
    required this.services,
  });

  final ModuleProgressStore progress;
  final DeepLinkLabServices services;

  @override
  Widget build(BuildContext context) {
    return LabComparisonScaffold(
      labTitle: 'Deep Link Lab',
      labSubtitle: 'Episode 4 — Fix Routing and Navigation',
      scenarios: buildDeepLinkScenarios(services),
      onScenarioCompleted: progress.markCompleted,
    );
  }
}
