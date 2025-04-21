import 'package:flutter/material.dart';
import '../../models/user.dart';

import '../screen.dart';

class AuthManager with ChangeNotifier {
  late final AuthService _authService;
  User? _loggedInUser;

  AuthManager() {
    _initialize();
  }

  Future<void> _initialize() async {
    _authService = AuthService(onAuthChange: (user) {
      _loggedInUser = user;
      notifyListeners();
    });

    await tryAutoLogin();
  }

  bool get isAuth => _loggedInUser != null;
  User? get user => _loggedInUser;

  Future<void> signup(String email, String password, String username,
      BuildContext context) async {
    final user = await _authService.signup(email, password, username);
    _loggedInUser = user;
    notifyListeners();
    Navigator.of(context).pushReplacementNamed(BookOverviewScreen.routeName);
  }

  Future<void> login(
      String email, String password, BuildContext context) async {
    final user = await _authService.login(email, password);
    _loggedInUser = user;
    notifyListeners();
    Navigator.of(context).pushReplacementNamed(BookOverviewScreen.routeName);
  }

  Future<void> tryAutoLogin() async {
    final user = await _authService.getUserFromStore();
    if (user != null) {
      _loggedInUser = user;
      notifyListeners();
    }
  }

  Future<void> logout(BuildContext context) async {
    await _authService.logout();
    _loggedInUser = null;
    notifyListeners();
    Navigator.of(context).pushReplacementNamed(AuthScreen.routeName);
  }
}
