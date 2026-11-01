import 'package:flutter/foundation.dart';

enum AuthStatus { unknown, signedOut, signedIn, expired }

/// Simulated auth session for Deep Link Lab.
class AuthSession extends ChangeNotifier {
  AuthStatus _status = AuthStatus.signedOut;
  String? _intended;

  AuthStatus get status => _status;
  String? get intendedDestination => _intended;
  bool get isAuthenticated => _status == AuthStatus.signedIn;

  void setStatus(AuthStatus status) {
    _status = status;
    notifyListeners();
  }

  void signIn() {
    _status = AuthStatus.signedIn;
    notifyListeners();
  }

  void signOut() {
    _status = AuthStatus.signedOut;
    _intended = null;
    notifyListeners();
  }

  void expire() {
    _status = AuthStatus.expired;
    notifyListeners();
  }

  void rememberIntended(String location) {
    _intended = location;
    notifyListeners();
  }

  String? takeIntended() {
    final v = _intended;
    _intended = null;
    notifyListeners();
    return v;
  }
}
