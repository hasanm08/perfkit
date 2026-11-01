import 'package:flutter/material.dart';

import '../../../../app/theme/colors.dart';
import '../../../../core/diagnostics/lifecycle_counters.dart';
import '../../../../core/progress/module_progress_store.dart';
import '../../../../core/widgets/lab_comparison_scaffold.dart';
import '../../domain/memory_scenarios.dart';
import '../../examples/broken/closure_retain_broken.dart';
import '../../examples/broken/object_lifecycle_broken.dart';

class MemoryLabPage extends StatelessWidget {
  const MemoryLabPage({super.key, required this.progress});

  final ModuleProgressStore progress;

  @override
  Widget build(BuildContext context) {
    return LabComparisonScaffold(
      labTitle: 'Memory Lab',
      labSubtitle: 'Episode 2 — Flutter Memory Leaks: 5 Mistakes',
      scenarios: buildMemoryScenarios(),
      onScenarioCompleted: progress.markCompleted,
      toolbarExtras: OutlinedButton.icon(
        onPressed: () {
          lifecycleCounters.reset();
          LeakyObjectRegistry.instance.retained.clear();
          closureRetainLingering.clear();
          PaintingBinding.instance.imageCache
            ..maximumSize = 100
            ..maximumSizeBytes = 100 << 20;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Educational counters & demo registries cleared'),
              backgroundColor: PerfKitColors.surfaceElevated,
            ),
          );
        },
        icon: const Icon(Icons.cleaning_services_outlined, size: 16),
        label: const Text('Cleanup'),
      ),
    );
  }
}
