import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  int _userId = -1;
  String _displayname = '';
  String get getDisplayname => _displayname;
  String avatarUrl='';
  String get getAvatarUrl => avatarUrl;
  int get userId => _userId;

  void setUser(int id, String name, String avatar) {
    _userId = id;
    _displayname = name;
    avatarUrl=avatar.isNotEmpty ? avatar : "https://www.pngall.com/wp-content/uploads/5/Profile-PNG-High-Quality-Image.png";
    notifyListeners();
  }
}