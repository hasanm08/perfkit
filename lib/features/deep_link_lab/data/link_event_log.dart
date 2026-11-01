import 'package:flutter/foundation.dart';

class LinkEvent {
  LinkEvent(this.message) : at = DateTime.now();
  final DateTime at;
  final String message;

  @override
  String toString() => '[${at.toIso8601String().substring(11, 19)}] $message';
}

class LinkEventLog extends ChangeNotifier {
  final List<LinkEvent> _events = [];
  List<LinkEvent> get events => List.unmodifiable(_events);

  void add(String message) {
    _events.add(LinkEvent(message));
    while (_events.length > 100) {
      _events.removeAt(0);
    }
    notifyListeners();
  }

  void clear() {
    _events.clear();
    notifyListeners();
  }
}
