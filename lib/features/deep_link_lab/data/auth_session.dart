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

  //? Main fix: preserve intended destination across login redirect.
  void rememberIntended(String location) {
    _intended = location;
    notifyListeners();
  }

  //? Main fix: resume navigation to intended destination after sign-in.
  String? takeIntended() {
    final v = _intended;
    _intended = null;
    notifyListeners();
    return v;
  }
}
