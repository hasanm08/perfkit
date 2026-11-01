import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'progress_io_stub.dart' if (dart.library.io) 'progress_io.dart' as io;

/// Persists which learning modules / scenarios the user has completed.
class ModuleProgressStore extends ChangeNotifier {
  ModuleProgressStore();

  final Set<String> _completed = {};
  bool _loaded = false;

  bool get isLoaded => _loaded;
  Set<String> get completed => Set.unmodifiable(_completed);

  bool isCompleted(String id) => _completed.contains(id);

  Future<void> load() async {
    if (kIsWeb) {
      _loaded = true;
      notifyListeners();
      return;
    }
    try {
      final raw = await io.readProgressJson();
      if (raw != null) {
        final data = jsonDecode(raw) as Map<String, dynamic>;
        final list = (data['completed'] as List<dynamic>?) ?? [];
        _completed
          ..clear()
          ..addAll(list.cast<String>());
      }
    } catch (_) {}
    _loaded = true;
    notifyListeners();
  }

  Future<void> markCompleted(String id) async {
    if (_completed.contains(id)) return;
    _completed.add(id);
    notifyListeners();
    await _persist();
  }

  Future<void> clear() async {
    _completed.clear();
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    if (kIsWeb) return;
    try {
      await io.writeProgressJson(
        jsonEncode({'completed': _completed.toList()}),
      );
    } catch (_) {}
  }
}
