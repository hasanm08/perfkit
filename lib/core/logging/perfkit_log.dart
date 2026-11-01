import 'package:flutter/foundation.dart';

/// Lightweight tagged logger for demos and diagnosis panels.
abstract final class PerfKitLog {
  static final ValueNotifier<List<String>> lines = ValueNotifier<List<String>>(
    <String>[],
  );

  static const int maxLines = 200;

  static void info(String message) => _append('INFO', message);
  static void warn(String message) => _append('WARN', message);
  static void error(String message) => _append('ERROR', message);
  static void nav(String message) => _append('NAV', message);
  static void net(String message) => _append('NET', message);

  static void clear() {
    lines.value = [];
  }

  static void _append(String level, String message) {
    final stamp = DateTime.now().toIso8601String().substring(11, 19);
    final entry = '[$stamp] $level  $message';
    debugPrint(entry);
    final next = List<String>.from(lines.value)..add(entry);
    while (next.length > maxLines) {
      next.removeAt(0);
    }
    lines.value = next;
  }
}
