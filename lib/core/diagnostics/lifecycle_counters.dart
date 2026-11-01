import 'package:flutter/foundation.dart';

/// Tracks created/disposed educational resources for Memory Lab demos.
class LifecycleCounters extends ChangeNotifier {
  int controllersCreated = 0;
  int controllersDisposed = 0;
  int subscriptionsCreated = 0;
  int subscriptionsCancelled = 0;
  int timersCreated = 0;
  int timersCancelled = 0;
  int retainedObjects = 0;

  int get activeControllers => controllersCreated - controllersDisposed;
  int get activeSubscriptions => subscriptionsCreated - subscriptionsCancelled;
  int get activeTimers => timersCreated - timersCancelled;

  void recordControllerCreated() {
    controllersCreated++;
    notifyListeners();
  }

  void recordControllerDisposed() {
    controllersDisposed++;
    notifyListeners();
  }

  void recordSubscriptionCreated() {
    subscriptionsCreated++;
    notifyListeners();
  }

  void recordSubscriptionCancelled() {
    subscriptionsCancelled++;
    notifyListeners();
  }

  void recordTimerCreated() {
    timersCreated++;
    notifyListeners();
  }

  void recordTimerCancelled() {
    timersCancelled++;
    notifyListeners();
  }

  void setRetainedObjects(int count) {
    retainedObjects = count;
    notifyListeners();
  }

  void reset() {
    controllersCreated = 0;
    controllersDisposed = 0;
    subscriptionsCreated = 0;
    subscriptionsCancelled = 0;
    timersCreated = 0;
    timersCancelled = 0;
    retainedObjects = 0;
    notifyListeners();
  }
}

/// App-wide singleton for Memory Lab instrumentation.
final lifecycleCounters = LifecycleCounters();
