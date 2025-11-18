import 'package:flutter/material.dart';
import 'package:chatapp/model/userdto.dart';
import 'package:chatapp/Service/profile_service.dart';
import 'package:chatapp/Service/friend_service.dart';
import 'package:chatapp/Service/chatroom_service.dart';

class AccountProvider extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();
  final FriendService _friendService = FriendService();
  final ChatroomService _chatroomService = ChatroomService();

  bool isMe = false;
  bool isLoading = true;
  String status = "";
  String displayname = "";
  UserProfile? profile;

  Future<void> loadProfile(int userId, int friendId) async {
    isLoading = true;
    notifyListeners();
    try {
      if (friendId == 0) {
        isMe = true;
        profile = await _profileService.getUserProfile(userId);
      } else {
        isMe = false;
        status = await _profileService.checkFriend(userId, friendId);
        profile = await _profileService.getUserProfile(friendId);
      }
      displayname = profile?.displayName ?? "";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addFriend(int userId, int friendId) async {
    await _friendService.addFriend(userId, friendId);
    status = "PENDING";
    notifyListeners();
  }

  Future<void> acceptFriend(int userId, int friendId) async {
    await _friendService.acceptFriend(userId, friendId);
    status = "ACCEPTED";
    notifyListeners();
  }

  Future<void> deleteFriend(int userId, int friendId) async {
    await _friendService.deleteFriend(userId, friendId);
    status = "NONE";
    notifyListeners();
  }

  Future<int> findRoom(int userId, int friendId) async {
    return await _chatroomService.findRoom(userId, friendId);
  }
}
