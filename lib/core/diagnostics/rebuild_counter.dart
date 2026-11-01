import 'package:flutter/foundation.dart';

/// Educational rebuild counter. Not equivalent to Flutter DevTools profiling.
class RebuildCounter extends ChangeNotifier {
  final Map<String, int> _counts = {};

  Map<String, int> get counts => Map.unmodifiable(_counts);

  int countFor(String id) => _counts[id] ?? 0;

  void increment(String id) {
    _counts[id] = (_counts[id] ?? 0) + 1;
    notifyListeners();
  }

  void reset() {
    _counts.clear();
    notifyListeners();
  }
}
