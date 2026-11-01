import 'package:flutter/material.dart';

import '../../../app/theme/colors.dart';
import '../../../core/models/lab_scenario.dart';
import '../../../core/models/metric_snapshot.dart';
import '../../../core/widgets/lab_demo_controller.dart';

List<LabScenario> buildTestingScenarios() => [
  _TestScenario(
    id: 'test-async',
    title: '1. Async Timing Issues',
    problem: 'Broken tests depend on arbitrary delays and assume async work finishes in time.',
    diagnosis:
        'See test/features/testing_lab/flaky/async_timing_flaky_test.dart — '
        'uses Future.delayed. Fixed awaits a Completer.',
    fix: 'Await explicit completion; use fake async / controlled hooks.',
    brokenPath: 'test/features/testing_lab/flaky/async_timing_flaky_test.dart',
    fixedPath:
        'test/features/testing_lab/deterministic/async_timing_fixed_test.dart',
    brokenSnippet: r'''
test('flaky async', () async {
  var done = false;
  Future.microtask(() => done = true);
  await Future.delayed(const Duration(milliseconds: 1)); // ❌ race
  expect(done, isTrue);
});''',
    fixedSnippet: r'''
test('deterministic async', () async {
  final done = Completer<void>();
  Future.microtask(done.complete);
  await done.future; // ✅ explicit
  expect(done.isCompleted, isTrue);
});''',
  ),
  _TestScenario(
    id: 'test-deps',
    title: '2. Uncontrolled Dependencies',
    problem: 'Tests hit live time/APIs and become environment-dependent.',
    diagnosis: 'Flaky suite uses DateTime.now(); fixed injects a Clock fake.',
    fix: 'Inject dependencies; fake clocks and network.',
    brokenPath:
        'test/features/testing_lab/flaky/uncontrolled_deps_flaky_test.dart',
    fixedPath: 'test/features/testing_lab/deterministic/uncontrolled_deps_fixed_test.dart',
    brokenSnippet: r'''
test('greeting', () {
  final hour = DateTime.now().hour; // ❌ wall clock
  expect(greet(hour), contains('o'));
});''',
    fixedSnippet: r'''
test('greeting', () {
  expect(greet(9, clock: FixedClock()), 'Good morning'); // ✅
});''',
  ),
  _TestScenario(
    id: 'test-platform',
    title: '3. Platform-Specific Behavior',
    problem: 'Assumes identical behavior on every platform.',
    diagnosis: 'Broken reads Platform.operatingSystem directly; fixed uses an abstract bridge.',
    fix: 'Abstract platform deps; test contracts; integration tests for real platforms.',
    brokenPath:
        'test/features/testing_lab/flaky/platform_assumption_flaky_test.dart',
    fixedPath: 'test/features/testing_lab/deterministic/platform_bridge_fixed_test.dart',
    brokenSnippet: r'''
test('path sep', () {
  expect(Platform.pathSeparator, '/'); // ❌ fails on Windows
});''',
    fixedSnippet: r'''
test('path sep', () {
  expect(FakePlatform(sep: '/').pathSeparator, '/'); // ✅
});''',
  ),
  _TestScenario(
    id: 'test-shared',
    title: '4. Shared State Between Tests',
    problem: 'Mutable static state leaks across tests; order-dependent.',
    diagnosis: 'Flaky suite mutates a global counter without reset; fixed isolates fixtures.',
    fix: 'Per-test fixtures; reset in setUp/tearDown; independent execution.',
    brokenPath: 'test/features/testing_lab/flaky/shared_state_flaky_test.dart',
    fixedPath:
        'test/features/testing_lab/deterministic/shared_state_fixed_test.dart',
    brokenSnippet: r'''
int global = 0;
test('a', () => global++);
test('b', () => expect(global, 0)); // ❌ order-dependent
''',
    fixedSnippet: r'''
setUp(() => fixture = Fixture());
test('b', () => expect(fixture.count, 0)); // ✅
''',
  ),
  _TestScenario(
    id: 'test-widgets',
    title: '5. Unreliable Widget Tests',
    problem: 'Fragile finders and pumpAndSettle with infinite animations.',
    diagnosis: 'Broken uses pumpAndSettle on a repeating animation; fixed pumps explicitly.',
    fix:
        'Explicit pump; control/disable animations; assert user-visible state.',
    brokenPath: 'test/features/testing_lab/flaky/widget_pump_flaky_test.dart',
    fixedPath:
        'test/features/testing_lab/deterministic/widget_pump_fixed_test.dart',
    brokenSnippet: r'''
await tester.pumpWidget(App());
await tester.pumpAndSettle(); // ❌ never settles
''',
    fixedSnippet: r'''
await tester.pumpWidget(App());
await tester.pump(); // ✅
expect(find.text('Ready'), findsOneWidget);
''',
  ),
];

class _TestScenario extends LabScenario {
  _TestScenario({
    required this.id,
    required this.title,
    required String problem,
    required String diagnosis,
    required String fix,
    required String brokenPath,
    required String fixedPath,
    required this.brokenSnippet,
    required this.fixedSnippet,
  }) : problemSummary = problem,
       diagnosis = diagnosis,
       recommendedFix = fix,
       brokenSourcePath = brokenPath,
       fixedSourcePath = fixedPath;

  @override
  final String id;
  @override
  final String title;
  @override
  final String problemSummary;
  @override
  final String diagnosis;
  @override
  final String recommendedFix;
  @override
  final String brokenSourcePath;
  @override
  final String fixedSourcePath;
  final String brokenSnippet;
  final String fixedSnippet;

  @override
  Widget buildDemo({
    required bool useFixed,
    required LabDemoController controller,
  }) {
    return _TestingDemo(
      useFixed: useFixed,
      controller: controller,
      brokenSnippet: brokenSnippet,
      fixedSnippet: fixedSnippet,
      brokenPath: brokenSourcePath,
      fixedPath: fixedSourcePath,
      title: title,
    );
  }
}

class _TestingDemo extends StatefulWidget {
  const _TestingDemo({
    required this.useFixed,
    required this.controller,
    required this.brokenSnippet,
    required this.fixedSnippet,
    required this.brokenPath,
    required this.fixedPath,
    required this.title,
  });

  final bool useFixed;
  final LabDemoController controller;
  final String brokenSnippet;
  final String fixedSnippet;
  final String brokenPath;
  final String fixedPath;
  final String title;

  @override
  State<_TestingDemo> createState() => _TestingDemoState();
}

class _TestingDemoState extends State<_TestingDemo> {
  String _result = 'Not run';

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onController);
  }

  void _onController() {
    if (widget.controller.isRunning) {
      // Deterministic demonstration of expected suite outcome — not random.
      setState(() {
        _result = widget.useFixed
            ? 'PASS — deterministic suite'
            : 'DOCUMENTED FLAKY — excluded from default CI';
      });
      widget.controller.setMetrics([
        MetricSnapshot(
          label: 'Suite',
          value: widget.useFixed ? 'deterministic' : 'flaky',
          source: MetricSource.counter,
        ),
        MetricSnapshot(
          label: 'CI default',
          value: widget.useFixed ? 'included' : 'excluded',
          source: MetricSource.simulated,
          note: 'See .github/workflows/ci.yml',
        ),
        MetricSnapshot(
          label: 'Result',
          value: widget.useFixed ? 'pass' : 'flaky-risk',
          source: MetricSource.simulated,
          note: 'Illustrative — run flutter test for real results',
        ),
      ]);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onController);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.useFixed ? PerfKitColors.fixed : PerfKitColors.broken;
    final code = widget.useFixed ? widget.fixedSnippet : widget.brokenSnippet;
    final path = widget.useFixed ? widget.fixedPath : widget.brokenPath;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color),
          ),
          child: Text(
            '${widget.title}\nResult: $_result\n$path',
            style: const TextStyle(fontSize: 12, height: 1.4),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'EXAMPLE CODE',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: PerfKitColors.secondaryText,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: PerfKitColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: PerfKitColors.border),
          ),
          child: Text(
            code,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              height: 1.45,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Commands', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text(
          widget.useFixed
              ? 'flutter test test/features/testing_lab/deterministic'
              : 'flutter test test/features/testing_lab/flaky  # isolated',
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
        ),
      ],
    );
  }
}
