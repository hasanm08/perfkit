import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/colors.dart';
import '../../../core/progress/module_progress_store.dart';

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key, required this.progress});

  final ModuleProgressStore progress;

  static const modules = [
    _Module(
      id: 'performance',
      title: 'Performance Lab',
      episode: 'Episode 1',
      tagline: 'Why Is Your Flutter App Slow?',
      route: '/performance',
      icon: Icons.speed,
      scenarioIds: [
        'perf-rebuilds',
        'perf-expensive-build',
        'perf-lists',
        'perf-images',
        'perf-paint',
      ],
    ),
    _Module(
      id: 'memory',
      title: 'Memory Lab',
      episode: 'Episode 2',
      tagline: 'Flutter Memory Leaks: 5 Mistakes',
      route: '/memory',
      icon: Icons.memory,
      scenarioIds: [
        'mem-controllers',
        'mem-timers',
        'mem-lifecycle',
        'mem-images',
        'mem-closures',
      ],
    ),
    _Module(
      id: 'offline',
      title: 'Offline Lab',
      episode: 'Episode 3',
      tagline: 'Build Reliable Offline Handling',
      route: '/offline',
      icon: Icons.cloud_off,
      scenarioIds: [
        'off-connectivity',
        'off-timeouts',
        'off-cache',
        'off-queue',
        'off-sync',
      ],
    ),
    _Module(
      id: 'deep-link',
      title: 'Deep Link Lab',
      episode: 'Episode 4',
      tagline: 'Fix Routing and Navigation',
      route: '/deep-link',
      icon: Icons.link,
      scenarioIds: [
        'dl-cold-warm',
        'dl-auth',
        'dl-nested',
        'dl-invalid',
        'dl-notification',
      ],
    ),
    _Module(
      id: 'testing',
      title: 'Testing Lab',
      episode: 'Episode 5',
      tagline: 'Fix Flaky Tests in CI',
      route: '/testing',
      icon: Icons.science,
      scenarioIds: [
        'test-async',
        'test-deps',
        'test-platform',
        'test-shared',
        'test-widgets',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: progress,
      builder: (context, _) {
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PerfKit',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Measure. Diagnose. Optimize.',
                      style: TextStyle(
                        color: PerfKitColors.accent,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'A hands-on Flutter engineering playground for reproducing '
                      'production problems, diagnosing them, and shipping the fix.',
                      style: TextStyle(
                        color: PerfKitColors.secondaryText,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _ProgressBar(progress: progress),
                  ],
                ),
              ),
            ),
            ...modules.map((m) {
              final done = m.scenarioIds.where(progress.isCompleted).length;
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                  child: _ModuleCard(
                    module: m,
                    completed: done,
                    total: m.scenarioIds.length,
                    onOpen: () => context.go(m.route),
                  ),
                ),
              );
            }),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        );
      },
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress});
  final ModuleProgressStore progress;

  @override
  Widget build(BuildContext context) {
    final total = OverviewPage.modules.expand((m) => m.scenarioIds).length;
    final done = progress.completed.length.clamp(0, total);
    final ratio = total == 0 ? 0.0 : done / total;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PerfKitColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: PerfKitColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Learning progress',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(
                '$done / $total scenarios',
                style: const TextStyle(
                  color: PerfKitColors.secondaryText,
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: PerfKitColors.surfaceElevated,
              color: PerfKitColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.module,
    required this.completed,
    required this.total,
    required this.onOpen,
  });

  final _Module module;
  final int completed;
  final int total;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final complete = completed >= total;
    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: PerfKitColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: complete ? PerfKitColors.accent : PerfKitColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: PerfKitColors.accentMuted,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(module.icon, color: PerfKitColors.accent),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    module.episode.toUpperCase(),
                    style: const TextStyle(
                      color: PerfKitColors.accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    module.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    module.tagline,
                    style: const TextStyle(
                      color: PerfKitColors.secondaryText,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$completed/$total',
                  style: TextStyle(
                    color: complete
                        ? PerfKitColors.accent
                        : PerfKitColors.secondaryText,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Icon(
                  complete ? Icons.check_circle : Icons.arrow_forward,
                  color: complete
                      ? PerfKitColors.accent
                      : PerfKitColors.secondaryText,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Module {
  const _Module({
    required this.id,
    required this.title,
    required this.episode,
    required this.tagline,
    required this.route,
    required this.icon,
    required this.scenarioIds,
  });

  final String id;
  final String title;
  final String episode;
  final String tagline;
  final String route;
  final IconData icon;
  final List<String> scenarioIds;
}
