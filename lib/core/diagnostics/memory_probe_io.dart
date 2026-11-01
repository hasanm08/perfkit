import 'dart:io';

int? memoryProbeReadRss() {
  try {
    return ProcessInfo.currentRss;
  } catch (_) {
    return null;
  }
}
