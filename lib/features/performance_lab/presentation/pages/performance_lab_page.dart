import 'package:flutter/material.dart';

import '../../../../app/theme/colors.dart';
import '../../../../core/diagnostics/frame_timing_monitor.dart';
import '../../../../core/diagnostics/rebuild_counter.dart';
import '../../../../core/models/lab_scenario.dart';
import '../../../../core/progress/module_progress_store.dart';
import '../../../../core/widgets/lab_comparison_scaffold.dart';
import '../../domain/performance_scenarios.dart';

class PerformanceLabPage extends StatefulWidget {
  const PerformanceLabPage({super.key, required this.progress});

  final ModuleProgressStore progress;

  @override
  State<PerformanceLabPage> createState() => _PerformanceLabPageState();
}

class _PerformanceLabPageState extends State<PerformanceLabPage> {
  final _datasetSize = ValueNotifier<int>(2000);
  final _imageResolution = ValueNotifier<int>(1024);
  final _rebuildCounter = RebuildCounter();
  final _frameMonitor = FrameTimingMonitor();
  late final List<LabScenario> scenarios;

  @override
  void initState() {
    super.initState();
    scenarios = buildPerformanceScenarios((
      datasetSize: _datasetSize,
      imageResolution: _imageResolution,
      rebuildCounter: _rebuildCounter,
      frameMonitor: _frameMonitor,
    ));
  }

  @override
  void dispose() {
    _datasetSize.dispose();
    _imageResolution.dispose();
    _rebuildCounter.dispose();
    _frameMonitor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LabComparisonScaffold(
      labTitle: 'Performance Lab',
      labSubtitle: 'Episode 1 — Why Is Your Flutter App Slow?',
      scenarios: scenarios,
      onScenarioCompleted: widget.progress.markCompleted,
      toolbarExtras: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Dataset',
            style: TextStyle(color: PerfKitColors.secondaryText, fontSize: 12),
          ),
          SizedBox(
            width: 140,
            child: ValueListenableBuilder<int>(
              valueListenable: _datasetSize,
              builder: (_, v, _) {
                return Slider(
                  value: v.toDouble(),
                  min: 500,
                  max: 8000,
                  divisions: 15,
                  label: '$v',
                  onChanged: (n) => _datasetSize.value = n.round(),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Image',
            style: TextStyle(color: PerfKitColors.secondaryText, fontSize: 12),
          ),
          SizedBox(
            width: 120,
            child: ValueListenableBuilder<int>(
              valueListenable: _imageResolution,
              builder: (_, v, _) {
                return Slider(
                  value: v.toDouble(),
                  min: 256,
                  max: 2048,
                  divisions: 7,
                  label: '${v}px',
                  onChanged: (n) => _imageResolution.value = n.round(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
