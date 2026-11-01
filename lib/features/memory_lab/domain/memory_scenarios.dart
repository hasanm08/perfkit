import 'package:flutter/widgets.dart';

import '../../../core/diagnostics/lifecycle_counters.dart';
import '../../../core/models/lab_scenario.dart';
import '../../../core/widgets/lab_demo_controller.dart';
import '../examples/broken/closure_retain_broken.dart';
import '../examples/broken/image_cache_broken.dart';
import '../examples/broken/object_lifecycle_broken.dart';
import '../examples/broken/surviving_timers_broken.dart';
import '../examples/broken/undisposed_controllers_broken.dart';
import '../examples/fixed/closure_retain_fixed.dart';
import '../examples/fixed/image_cache_fixed.dart';
import '../examples/fixed/object_lifecycle_fixed.dart';
import '../examples/fixed/surviving_timers_fixed.dart';
import '../examples/fixed/undisposed_controllers_fixed.dart';

List<LabScenario> buildMemoryScenarios() => [
  _Controllers(),
  _Timers(),
  _Lifecycle(),
  _Images(),
  _Closures(),
];

class _Controllers extends LabScenario {
  @override
  String get id => 'mem-controllers';
  @override
  String get title => '1. Undisposed Controllers & Streams';
  @override
  String get problemSummary =>
      'Controllers and stream subscriptions are created and never disposed.';
  @override
  String get diagnosis =>
      'Watch active controller/subscription counters climb. In DevTools Memory, '
      'take heap snapshots before/after open-close and inspect retaining paths.';
  @override
  String get recommendedFix =>
      'Dispose controllers and cancel subscriptions in State.dispose.';
  @override
  String get brokenSourcePath =>
      'lib/features/memory_lab/examples/broken/undisposed_controllers_broken.dart';
  @override
  String get fixedSourcePath =>
      'lib/features/memory_lab/examples/fixed/undisposed_controllers_fixed.dart';

  @override
  Widget buildDemo({
    required bool useFixed,
    required LabDemoController controller,
  }) {
    lifecycleCounters.reset();
    return useFixed
        ? UndisposedControllersFixed(controller: controller)
        : UndisposedControllersBroken(controller: controller);
  }
}

class _Timers extends LabScenario {
  @override
  String get id => 'mem-timers';
  @override
  String get title => '2. Timers Surviving Screens';
  @override
  String get problemSummary =>
      'Periodic timers keep running after the screen that started them is gone.';
  @override
  String get diagnosis =>
      'Active timer counters rise with each Start. DevTools allocation tracing '
      'can show Timer and callback retention.';
  @override
  String get recommendedFix =>
      'Cancel timers and remove listeners when the screen disposes.';
  @override
  String get brokenSourcePath =>
      'lib/features/memory_lab/examples/broken/surviving_timers_broken.dart';
  @override
  String get fixedSourcePath =>
      'lib/features/memory_lab/examples/fixed/surviving_timers_fixed.dart';

  @override
  Widget buildDemo({
    required bool useFixed,
    required LabDemoController controller,
  }) {
    lifecycleCounters.reset();
    return useFixed
        ? SurvivingTimersFixed(controller: controller)
        : SurvivingTimersBroken(controller: controller);
  }
}

class _Lifecycle extends LabScenario {
  @override
  String get id => 'mem-lifecycle';
  @override
  String get title => '3. Incorrect Object Lifecycle';
  @override
  String get problemSummary =>
      'A singleton registry retains large objects beyond their intended lifetime.';
  @override
  String get diagnosis =>
      'Retained blob counter grows. Compare heap snapshots; look for the '
      'singleton as a retaining path root.';
  @override
  String get recommendedFix =>
      'Scope ownership to the feature/session; clear references when done.';
  @override
  String get brokenSourcePath =>
      'lib/features/memory_lab/examples/broken/object_lifecycle_broken.dart';
  @override
  String get fixedSourcePath =>
      'lib/features/memory_lab/examples/fixed/object_lifecycle_fixed.dart';

  @override
  Widget buildDemo({
    required bool useFixed,
    required LabDemoController controller,
  }) {
    return useFixed
        ? ObjectLifecycleFixed(controller: controller)
        : ObjectLifecycleBroken(controller: controller);
  }
}

class _Images extends LabScenario {
  @override
  String get id => 'mem-images';
  @override
  String get title => '4. Large Image & Cache Retention';
  @override
  String get problemSummary =>
      'Full-size images are retained in a list while ImageCache limits are raised.';
  @override
  String get diagnosis =>
      'Compare ImageCache currentSizeBytes and retained PNG counts. Prefer '
      'DevTools Memory for decoded image attribution.';
  @override
  String get recommendedFix =>
      'Thumbnails, sensible cache limits, release strong refs; avoid thrashing clear().';
  @override
  String get brokenSourcePath =>
      'lib/features/memory_lab/examples/broken/image_cache_broken.dart';
  @override
  String get fixedSourcePath =>
      'lib/features/memory_lab/examples/fixed/image_cache_fixed.dart';

  @override
  Widget buildDemo({
    required bool useFixed,
    required LabDemoController controller,
  }) {
    return useFixed
        ? ImageCacheFixed(controller: controller)
        : ImageCacheBroken(controller: controller);
  }
}

class _Closures extends LabScenario {
  @override
  String get id => 'mem-closures';
  @override
  String get title => '5. Closures Retaining References';
  @override
  String get problemSummary =>
      'Long-lived closures capture large object graphs even after fields are nulled.';
  @override
  String get diagnosis =>
      'Field nullity is not reachability. Inspect retaining paths from the '
      'static callback list in DevTools.';
  @override
  String get recommendedFix =>
      'Capture primitives, cancel registrations, clear callback lists.';
  @override
  String get brokenSourcePath =>
      'lib/features/memory_lab/examples/broken/closure_retain_broken.dart';
  @override
  String get fixedSourcePath =>
      'lib/features/memory_lab/examples/fixed/closure_retain_fixed.dart';

  @override
  Widget buildDemo({
    required bool useFixed,
    required LabDemoController controller,
  }) {
    return useFixed
        ? ClosureRetainFixed(controller: controller)
        : ClosureRetainBroken(controller: controller);
  }
}
