import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool   _isLoading = false;
  bool   _isLoggedIn = false;
  String _role      = '';
  String _username  = '';
  String _error     = '';

  bool   get isLoading  => _isLoading;
  bool   get isLoggedIn => _isLoggedIn;
  String get role       => _role;
  String get username   => _username;
  String get error      => _error;
  bool   get isAdmin    => _role == 'Admin';

  Future<void> checkSession() async {
    _isLoggedIn = await _authService.isLoggedIn();
    if (_isLoggedIn) {
      _role     = (await _authService.getRole())     ?? '';
      _username = (await _authService.getUsername()) ?? '';
    }
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error     = '';
    notifyListeners();

    try {
      final auth = await _authService.login(username, password);
      _isLoggedIn = true;
      _role       = auth.role;
      _username   = auth.username;
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String username, String password) async {
    _isLoading = true;
    _error     = '';
    notifyListeners();

    try {
      await _authService.register(username, password);
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _isLoggedIn = false;
    _role       = '';
    _username   = '';
    notifyListeners();
  }
}
