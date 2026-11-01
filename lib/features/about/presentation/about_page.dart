import 'package:flutter/material.dart';

import '../../../app/theme/colors.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
      children: [
        const Text(
          'About PerfKit',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        const Text(
          'Educational Flutter engineering playground for the FlowForge series.',
          style: TextStyle(color: PerfKitColors.secondaryText, fontSize: 14),
        ),
        const SizedBox(height: 24),
        _section(
          'Purpose',
          'PerfKit demonstrates common production problems with intentionally '
              'broken implementations, then shows production-quality fixes. '
              'Broken code is isolated under examples/broken and never contaminates '
              'the fixed reference implementations.',
        ),
        _section(
          'Measurement honesty',
          'Debug-mode timings are not release performance. Custom rebuild and '
              'lifecycle counters are educational instrumentation — they are not '
              'equivalent to Flutter DevTools. Use profile mode, DevTools Performance, '
              'and DevTools Memory for authoritative diagnosis.',
        ),
        _section(
          'Series episodes',
          '1. Performance Lab — unnecessary rebuilds, expensive build, lists, images, paint\n'
              '2. Memory Lab — controllers, timers, lifecycle, image cache, closures\n'
              '3. Offline Lab — connectivity, timeouts, cache, pending queue, sync\n'
              '4. Deep Link Lab — cold/warm start, auth, nested nav, invalid links, notifications\n'
              '5. Testing Lab — async timing, dependencies, platform, shared state, widgets',
        ),
        _section(
          'Quick start',
          'flutter run -d macos --profile\n'
              'flutter run -d chrome\n'
              'flutter test\n'
              'See docs/ and docs/video-production/ for recording guides.',
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: PerfKitColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: PerfKitColors.border),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PerfKit',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: PerfKitColors.accent,
                ),
              ),
              SizedBox(height: 4),
              Text('Measure. Diagnose. Optimize.'),
              SizedBox(height: 12),
              Text(
                'Not a production business app — an engineering teaching instrument '
                'with production-quality corrected code.',
                style: TextStyle(
                  color: PerfKitColors.secondaryText,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _section(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              color: PerfKitColors.secondaryText,
              height: 1.5,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
