import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  int _userId = -1;
  String _username = '';
  String get username => _username;
  String avatarUrl='';
  String get getAvatarUrl => avatarUrl;
  int get userId => _userId;

  void setUser(int id, String name, String avatar) {
    _userId = id;
    _username = name;
    avatarUrl=avatar;
    notifyListeners();
  }
}