import 'package:flutter/material.dart';
import 'package:rela/Service/socket_service.dart';
import 'package:rela/model/message.dart';
import 'package:rela/model/notification.dart';
import 'package:rela/model/userdto.dart';
import 'package:rela/Service/profile_service.dart';
import 'package:rela/Service/friend_service.dart';
import 'package:rela/Service/chatroom_service.dart';

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
    NotiDTO noti = NotiDTO(
      title: "",
      status: false,
      createdAt: 0,
      senderId: SenderInfo(
        id: userId,
        name: "",
        avatarUrl: "",
      ),
      receiverId: friendId,
      type: "add_friend",
    );
    final payload = {"event": "notification", "data": noti.toJson()};
    SocketService().sendMessage(payload);
    notifyListeners();
  }

  Future<void> acceptFriend(int userId, int friendId) async {
    await _friendService.acceptFriend(userId, friendId);
    status = "ACCEPTED";
    NotiDTO noti = NotiDTO(
      title: "",
      status: false,
      createdAt: 0,
      senderId: SenderInfo(
        id: userId,
        name: "",
        avatarUrl: "",
      ),
      receiverId: friendId,
      type: "accept_friend",
    );
    final payload = {"event": "notification", "data": noti.toJson()};

    SocketService().sendMessage(payload);
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
