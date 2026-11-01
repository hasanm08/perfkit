import 'package:flutter/widgets.dart';

import '../widgets/lab_demo_controller.dart';

/// Contract shared by every PerfKit lab scenario.
abstract class LabScenario {
  String get id;
  String get title;
  String get problemSummary;
  String get diagnosis;
  String get recommendedFix;
  String get brokenSourcePath;
  String get fixedSourcePath;

  /// Optional extra metrics for the comparison panel.
  List<String> get metricHints => const [];

  Widget buildDemo({
    required bool useFixed,
    required LabDemoController controller,
  });
}
