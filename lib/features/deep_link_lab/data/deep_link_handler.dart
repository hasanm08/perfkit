import 'dart:async';

import 'package:flutter/foundation.dart';

import 'link_event_log.dart';

/// Simulates platform deep-link delivery (initial + stream).
class DeepLinkHandler extends ChangeNotifier {
  DeepLinkHandler({required this.log});

  final LinkEventLog log;
  final _controller = StreamController<Uri>.broadcast();
  Uri? _initial;
  Uri? _lastProcessed;
  bool _warmOnlyBroken = false;

  Stream<Uri> get stream => _controller.stream;
  Uri? get initialLink => _initial;
  bool get warmOnlyBrokenMode => _warmOnlyBroken;

  void setWarmOnlyBroken(bool value) {
    _warmOnlyBroken = value;
    notifyListeners();
  }

  /// Fixed: capture initial link for cold start.
  void setInitialLink(Uri uri) {
    _initial = uri;
    log.add('Cold-start initial link stored: $uri');
    notifyListeners();
  }

  // ❌ DEEP LINK PROBLEM:
  // Only warm-start links are processed. Cold-start initial links are ignored,
  // so users who open the app via a link land on the default screen.
  //
  // WHY IT IS A PROBLEM:
  // Marketing / share links fail when the process was not already running.
  //
  // HOW TO FIX:
  // Capture initialLink on startup and subscribe to the incoming link stream,
  // with deduplication.
  //
  // SEE FIXED IMPLEMENTATION: ingestFixed
  void ingestBroken(Uri uri, {required bool coldStart}) {
    if (coldStart) {
      log.add('BROKEN: ignored cold-start link $uri');
      return;
    }
    _controller.add(uri);
    log.add('BROKEN: warm link emitted $uri');
  }

  // ✅ OPTIMIZATION:
  // Handles cold-start (initial) and warm-start links; dedupes consecutive
  // identical URIs so the same link is not processed twice.
  //
  // WHY IT WORKS:
  // Both launch paths converge on one handler with explicit dedupe state.
  //
  // PRODUCTION NOTE:
  // On device, wire uni_links/app_links (or OS APIs) into this handler.
  void ingestFixed(Uri uri, {required bool coldStart}) {
    if (coldStart) {
      setInitialLink(uri);
    }
    if (_lastProcessed == uri) {
      log.add('FIXED: deduped duplicate $uri');
      return;
    }
    _lastProcessed = uri;
    _controller.add(uri);
    log.add(
      'FIXED: link emitted ($coldStart=${coldStart ? 'cold' : 'warm'}) $uri',
    );
  }

  Uri? consumeInitial() {
    final v = _initial;
    _initial = null;
    notifyListeners();
    return v;
  }

  void resetDedupe() {
    _lastProcessed = null;
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }
}

// Educational notes live at top of ingestBroken / ingestFixed methods via call sites.
// ❌ Cold/warm: ingestBroken ignores cold-start.
// ✅ Fixed: ingestFixed stores initial + dedupes.
