import 'package:flutter/material.dart';

import '../../../../core/progress/module_progress_store.dart';
import '../../../../core/widgets/lab_comparison_scaffold.dart';
import '../../domain/testing_scenarios.dart';

class TestingLabPage extends StatelessWidget {
  const TestingLabPage({super.key, required this.progress});

  final ModuleProgressStore progress;

  @override
  Widget build(BuildContext context) {
    return LabComparisonScaffold(
      labTitle: 'Testing Lab',
      labSubtitle: 'Episode 5 — Fix Flaky Tests',
      scenarios: buildTestingScenarios(),
      onScenarioCompleted: progress.markCompleted,
    );
  }
}
