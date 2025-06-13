import 'package:flutter/material.dart';

class UserNotifier with ChangeNotifier {
  Map<String, dynamic>? _user;
  List<Map<String, dynamic>> _joinedEqubs = [];

  Map<String, dynamic>? get user => _user;
  List<Map<String, dynamic>> get joinedEqubs => _joinedEqubs;

  void setUser(Map<String, dynamic> newUser) {
    _user = newUser;
    notifyListeners();
  }

  void addJoinedEqub(Map<String, dynamic> equb) {
    if (!_joinedEqubs.any((e) => e['id'] == equb['id'])) {
      _joinedEqubs.add(equb);
      notifyListeners();
    }
  }

  void removeJoinedEqub(String equbId) {
    _joinedEqubs.removeWhere((e) => e['id'] == equbId);
    notifyListeners();
  }

  void logout() {
    _user = null;
    _joinedEqubs.clear();
    notifyListeners();
  }
}