import 'package:flutter/foundation.dart';

import 'memory_probe_stub.dart'
    if (dart.library.io) 'memory_probe_io.dart'
    as impl;

/// Best-effort process memory probe.
///
/// On VM platforms (`dart:io`), reports [ProcessInfo.currentRss].
/// On web, reports unavailable. This is NOT proof of a leak by itself —
/// use Flutter DevTools Memory (heap snapshots, retaining paths) to diagnose.
class MemoryProbe {
  MemoryProbe._();

  static bool get isAvailable => !kIsWeb;

  /// Current RSS in bytes, or null if unavailable.
  static int? currentRssBytes() {
    if (kIsWeb) return null;
    return impl.memoryProbeReadRss();
  }

  static String formatRss() {
    final rss = currentRssBytes();
    if (rss == null) return 'Unavailable on this platform';
    if (rss >= 1 << 20) {
      return '${(rss / (1 << 20)).toStringAsFixed(1)} MB';
    }
    return '${(rss / 1024).toStringAsFixed(0)} KB';
  }
}
