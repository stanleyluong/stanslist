import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String _userEmail = '';
  String _userName = '';
  bool _isLoggedIn = false;

  String get userEmail => _userEmail;
  String get userName => _userName;
  bool get isLoggedIn => _isLoggedIn;

  void setUser(String email, String name) {
    _userEmail = email;
    _userName = name;
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _userEmail = '';
    _userName = '';
    _isLoggedIn = false;
    notifyListeners();
  }
}
