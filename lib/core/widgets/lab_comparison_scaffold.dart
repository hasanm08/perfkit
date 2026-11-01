import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../app/theme/colors.dart';
import '../models/lab_scenario.dart';
import 'code_path_chip.dart';
import 'lab_demo_controller.dart';
import 'metric_badge.dart';

/// Reusable broken/fixed comparison experience for every PerfKit lab.
class LabComparisonScaffold extends StatefulWidget {
  const LabComparisonScaffold({
    super.key,
    required this.labTitle,
    required this.labSubtitle,
    required this.scenarios,
    this.toolbarExtras,
    this.onScenarioCompleted,
    this.debugModeWarning = true,
  });

  final String labTitle;
  final String labSubtitle;
  final List<LabScenario> scenarios;
  final Widget? toolbarExtras;
  final ValueChanged<String>? onScenarioCompleted;
  final bool debugModeWarning;

  @override
  State<LabComparisonScaffold> createState() => _LabComparisonScaffoldState();
}

class _LabComparisonScaffoldState extends State<LabComparisonScaffold> {
  late LabScenario _scenario;
  bool _useFixed = false; //true for fixed, false for broken
  late final LabDemoController _controller;

  @override
  void initState() {
    super.initState();
    _scenario = widget.scenarios.first;
    _controller = LabDemoController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _selectScenario(LabScenario scenario) {
    _controller.reset();
    setState(() {
      _scenario = scenario;
    });
  }

  void _toggleVariant(bool useFixed) {
    _controller.reset();
    setState(() => _useFixed = useFixed);
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 980;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(
          title: widget.labTitle,
          subtitle: widget.labSubtitle,
          useFixed: _useFixed,
          onVariantChanged: _toggleVariant,
          controller: _controller,
          toolbarExtras: widget.toolbarExtras,
          onMarkDone: () => widget.onScenarioCompleted?.call(_scenario.id),
        ),
        if (widget.debugModeWarning && kDebugMode) const _DebugModeBanner(),
        Expanded(
          child: wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: 320,
                      child: _SidePanel(
                        scenarios: widget.scenarios,
                        selected: _scenario,
                        useFixed: _useFixed,
                        onSelect: _selectScenario,
                        controller: _controller,
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(
                      child: _DemoPane(
                        scenario: _scenario,
                        useFixed: _useFixed,
                        controller: _controller,
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    SizedBox(
                      height: 220,
                      child: _SidePanel(
                        scenarios: widget.scenarios,
                        selected: _scenario,
                        useFixed: _useFixed,
                        onSelect: _selectScenario,
                        controller: _controller,
                        compact: true,
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: _DemoPane(
                        scenario: _scenario,
                        useFixed: _useFixed,
                        controller: _controller,
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.subtitle,
    required this.useFixed,
    required this.onVariantChanged,
    required this.controller,
    required this.onMarkDone,
    this.toolbarExtras,
  });

  final String title;
  final String subtitle;
  final bool useFixed;
  final ValueChanged<bool> onVariantChanged;
  final LabDemoController controller;
  final VoidCallback onMarkDone;
  final Widget? toolbarExtras;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: const BoxDecoration(
        color: PerfKitColors.background,
        border: Border(bottom: BorderSide(color: PerfKitColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: PerfKitColors.secondaryText,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(
                    value: false,
                    label: Text('Broken'),
                    icon: Icon(Icons.warning_amber_rounded, size: 16),
                  ),
                  ButtonSegment(
                    value: true,
                    label: Text('Fixed'),
                    icon: Icon(Icons.check_circle_outline, size: 16),
                  ),
                ],
                selected: {useFixed},
                onSelectionChanged: (s) => onVariantChanged(s.first),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ListenableBuilder(
                listenable: controller,
                builder: (context, _) {
                  return FilledButton.icon(
                    onPressed: controller.isRunning
                        ? controller.stop
                        : controller.start,
                    icon: Icon(
                      controller.isRunning ? Icons.stop : Icons.play_arrow,
                      size: 18,
                    ),
                    label: Text(controller.isRunning ? 'Stop' : 'Start'),
                  );
                },
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: controller.reset,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Reset'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: onMarkDone,
                icon: const Icon(Icons.task_alt, size: 16),
                label: const Text('Mark done'),
              ),
              if (toolbarExtras != null) ...[
                const SizedBox(width: 12),
                toolbarExtras!,
              ],
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: useFixed
                      ? PerfKitColors.fixed.withValues(alpha: 0.15)
                      : PerfKitColors.broken.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: useFixed
                        ? PerfKitColors.fixed
                        : PerfKitColors.broken,
                  ),
                ),
                child: Text(
                  useFixed ? 'FIXED IMPLEMENTATION' : 'BROKEN IMPLEMENTATION',
                  style: TextStyle(
                    color: useFixed
                        ? PerfKitColors.fixed
                        : PerfKitColors.broken,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DebugModeBanner extends StatelessWidget {
  const _DebugModeBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: PerfKitColors.warning.withValues(alpha: 0.12),
      child: const Text(
        'Debug-mode timings are not representative of release performance. '
        'Use profile mode and Flutter DevTools for reliable measurements.',
        style: TextStyle(color: PerfKitColors.warning, fontSize: 12),
      ),
    );
  }
}

class _SidePanel extends StatelessWidget {
  const _SidePanel({
    required this.scenarios,
    required this.selected,
    required this.useFixed,
    required this.onSelect,
    required this.controller,
    this.compact = false,
  });

  final List<LabScenario> scenarios;
  final LabScenario selected;
  final bool useFixed;
  final ValueChanged<LabScenario> onSelect;
  final LabDemoController controller;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PerfKitColors.surface,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const Text(
            'SCENARIOS',
            style: TextStyle(
              color: PerfKitColors.secondaryText,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          ...scenarios.map((s) {
            final active = s.id == selected.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: InkWell(
                onTap: () => onSelect(s),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: active
                        ? PerfKitColors.accentMuted
                        : PerfKitColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: active
                          ? PerfKitColors.accent
                          : PerfKitColors.border,
                    ),
                  ),
                  child: Text(
                    s.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                      color: PerfKitColors.primaryText,
                    ),
                  ),
                ),
              ),
            );
          }),
          if (!compact) ...[
            const SizedBox(height: 16),
            const Text(
              'PROBLEM',
              style: TextStyle(
                color: PerfKitColors.secondaryText,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              selected.problemSummary,
              style: const TextStyle(fontSize: 13, height: 1.45),
            ),
            const SizedBox(height: 16),
            const Text(
              'DIAGNOSIS',
              style: TextStyle(
                color: PerfKitColors.secondaryText,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              selected.diagnosis,
              style: const TextStyle(
                fontSize: 13,
                height: 1.45,
                color: PerfKitColors.secondaryText,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'RECOMMENDED FIX',
              style: TextStyle(
                color: PerfKitColors.secondaryText,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              selected.recommendedFix,
              style: const TextStyle(fontSize: 13, height: 1.45),
            ),
            const SizedBox(height: 16),
            CodePathChip(
              path: useFixed
                  ? selected.fixedSourcePath
                  : selected.brokenSourcePath,
              label: useFixed ? 'Fixed' : 'Broken',
            ),
            const SizedBox(height: 16),
            const Text(
              'METRICS',
              style: TextStyle(
                color: PerfKitColors.secondaryText,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            ListenableBuilder(
              listenable: controller,
              builder: (context, _) {
                final metrics = controller.metrics.values.toList();
                if (metrics.isEmpty) {
                  return const Text(
                    'Start the demo to collect metrics.',
                    style: TextStyle(
                      color: PerfKitColors.secondaryText,
                      fontSize: 12,
                    ),
                  );
                }
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [for (final m in metrics) MetricBadge(metric: m)],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _DemoPane extends StatelessWidget {
  const _DemoPane({
    required this.scenario,
    required this.useFixed,
    required this.controller,
  });

  final LabScenario scenario;
  final bool useFixed;
  final LabDemoController controller;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: PerfKitColors.background,
      child: KeyedSubtree(
        key: ValueKey('${scenario.id}-$useFixed-${controller.generation}'),
        child: scenario.buildDemo(useFixed: useFixed, controller: controller),
      ),
    );
  }
}
