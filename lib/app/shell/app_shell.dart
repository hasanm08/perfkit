import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/colors.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _destinations = [
    _Dest('Overview', Icons.dashboard_outlined, Icons.dashboard),
    _Dest('Performance', Icons.speed_outlined, Icons.speed),
    _Dest('Memory', Icons.memory_outlined, Icons.memory),
    _Dest('Offline', Icons.cloud_off_outlined, Icons.cloud_off),
    _Dest('Deep Links', Icons.link_outlined, Icons.link),
    _Dest('Testing', Icons.science_outlined, Icons.science),
    _Dest('About', Icons.info_outline, Icons.info),
  ];

  void _go(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final index = navigationShell.currentIndex;

    if (wide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              extended: MediaQuery.sizeOf(context).width >= 1180,
              selectedIndex: index,
              onDestinationSelected: _go,
              leading: const Padding(
                padding: EdgeInsets.fromLTRB(12, 16, 12, 24),
                child: _BrandMark(),
              ),
              destinations: [
                for (final d in _destinations)
                  NavigationRailDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: Text(d.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index.clamp(0, 4),
        onDestinationSelected: (i) {
          // On compact layouts, About is reached via Overview; map first 5.
          if (i < 5) _go(i);
        },
        destinations: [
          for (final d in _destinations.take(5))
            NavigationDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(d.selectedIcon),
              label: d.label,
            ),
        ],
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    final extended = MediaQuery.sizeOf(context).width >= 1180;
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: PerfKitColors.accentMuted,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: PerfKitColors.accent.withValues(alpha: 0.4),
            ),
          ),
          alignment: Alignment.center,
          child: const Text(
            'PK',
            style: TextStyle(
              color: PerfKitColors.accent,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ),
        if (extended) ...[
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PerfKit',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              Text(
                'Measure. Diagnose. Optimize.',
                style: TextStyle(
                  color: PerfKitColors.secondaryText,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _Dest {
  const _Dest(this.label, this.icon, this.selectedIcon);
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
