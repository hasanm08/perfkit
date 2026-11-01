import 'package:flutter/foundation.dart';

import 'auth_session.dart';
import 'link_event_log.dart';

enum AppLifecyclePhase { terminated, background, foreground }

/// Queues notification navigation until auth + lifecycle allow it.
class NotificationNavQueue extends ChangeNotifier {
  NotificationNavQueue({required this.auth, required this.log});

  final AuthSession auth;
  final LinkEventLog log;

  AppLifecyclePhase phase = AppLifecyclePhase.foreground;
  String? _pending;
  String? lastNavigated;

  String? get pending => _pending;

  void setPhase(AppLifecyclePhase phase) {
    this.phase = phase;
    log.add('Lifecycle phase → ${phase.name}');
    notifyListeners();
    flush();
  }

  // ❌ DEEP LINK PROBLEM:
  // Navigates immediately from a notification intent without considering
  // lifecycle phase or authentication.
  //
  // WHY IT IS A PROBLEM:
  // Can open protected screens while signed out, or navigate while backgrounded.
  //
  // HOW TO FIX:
  // Queue the intent; flush when foreground + auth allow; dedupe.
  //
  // SEE FIXED IMPLEMENTATION: ingestFixed
  String? ingestBroken(String location) {
    log.add(
      'BROKEN: immediate navigate to $location (phase=${phase.name}, auth=${auth.status.name})',
    );
    lastNavigated = location;
    notifyListeners();
    return location;
  }

  // ✅ OPTIMIZATION:
  // Queues notification navigation until the app is foregrounded and auth
  // (when required) is satisfied; prevents duplicate navigation.
  //
  // WHY IT WORKS:
  // Lifecycle and auth gates are explicit; destination is preserved.
  //
  // PRODUCTION NOTE:
  // Wire FCM/APNs click handlers into this queue rather than calling go() directly.
  void ingestFixed(String location, {required bool requiresAuth}) {
    _pending = location;
    log.add('FIXED: queued notification intent $location');
    notifyListeners();
    flush(requiresAuth: requiresAuth);
  }

  String? flush({bool requiresAuth = true}) {
    if (_pending == null) return null;
    if (phase != AppLifecyclePhase.foreground) {
      log.add('FIXED: waiting for foreground (phase=${phase.name})');
      return null;
    }
    if (requiresAuth && !auth.isAuthenticated) {
      auth.rememberIntended(_pending!);
      log.add('FIXED: waiting for auth; preserved $_pending');
      return null;
    }
    if (lastNavigated == _pending) {
      log.add('FIXED: prevented duplicate navigation to $_pending');
      _pending = null;
      notifyListeners();
      return null;
    }
    final dest = _pending!;
    _pending = null;
    lastNavigated = dest;
    log.add('FIXED: navigating to $dest');
    notifyListeners();
    return dest;
  }
}
