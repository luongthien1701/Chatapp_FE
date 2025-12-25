import 'dart:io';

import 'package:chatapp/Service/profile_service.dart';
import 'package:chatapp/Service/upload_service.dart';
import 'package:chatapp/model/message.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  ProfileService profileService=ProfileService();
  int _userId = -1;
  String _displayname = '';
  String get getDisplayname => _displayname;
  String avatarUrl='';
  String get getAvatarUrl => avatarUrl;
  int get userId => _userId;
  UploadService uploadService = UploadService();
  void setUser(int id, String name, String avatar) {
    _userId = id;
    _displayname = name;
    avatarUrl=avatar.isNotEmpty ? avatar : "https://www.pngall.com/wp-content/uploads/5/Profile-PNG-High-Quality-Image.png";
    notifyListeners();
  }
  Future<String> updateAvatar(File img) async
  {
    try{
      String url=await uploadService.uploadimage(img,"avatar", _userId);
      avatarUrl=url;
      notifyListeners();
      debugPrint(url);
      return url;
    } 
    catch (e) 
    {
      debugPrint("Đã xảy ra lỗi khi cập nhật avatar");
    }
    return "";
  }
  Future<void> updateProfile(String name,String email,String phone) async
  {
    
    notifyListeners();
  }
  Future<SenderInfo> getProfile(int userId) async
  {
    return profileService.getProfile(userId);
  }
}