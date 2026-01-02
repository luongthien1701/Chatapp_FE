import 'dart:convert';
import 'dart:io';
import 'package:rela/Service/upload_service.dart';
import 'package:flutter/material.dart';
import 'package:rela/Service/chatroom_service.dart';
import 'package:rela/Service/message_service.dart';
import 'package:rela/Service/socket_service.dart';
import 'package:rela/model/chatroomdto.dart';
import 'package:rela/model/message.dart';

class ConversationProvider with ChangeNotifier {
  final ChatroomService _chatroomService = ChatroomService();
  final MessageService _messageService = MessageService();
  final UploadService _uploadService = UploadService();
  RoomDTO? room;
  List<MessageDTO> messages = [];
  List<int> memberIds = [];
  bool isLoading = false;

  Future<void> loadRoomInfo(int roomId) async {
    try {
      isLoading = true;
      room = await _chatroomService.getRoom(roomId);
    } catch (e) {
      debugPrint("❌ Lỗi loadRoomInfo: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  Future<void> loadMemberIds(int roomId) async {
    try {
      memberIds = await _chatroomService.getMemberIds(roomId);
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Lỗi loadMemberIds: $e");
    }
  }

  Future<void> loadMessages(int userId, int roomId) async {
    try {
      messages = await _messageService.getMessages(userId, roomId);
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Lỗi loadMessages: $e");
    }
  }

  Future<String> upImageMessages(File img,int roomId) async
  {
    try{
      String url=await _uploadService.uploadimage(img,"chat", roomId);
      return url;
    } 
    catch (e) 
    {
      debugPrint("Đã xảy ra lỗi khi gửi tin nhắn ảnh");
    }
    return "";
  }

  void joinRoom(int userId, int roomId) {
    final payload = {
      "event": "join_room",
      "data": {"userId": userId, "roomId": roomId}
    };
    SocketService().sendMessage(payload);
  }

  Future<void> listenMessages(
  int userId, {
  VoidCallback? onNewMessage,
}) {
  SocketService().messages.listen((data) {
    final msg = jsonDecode(data);

    if (msg["event"] == "message") {
      final payload = msg["data"];

      messages.add(MessageDTO(
        id: int.parse(payload['id'].toString()),
        content: payload['content'],
        sender: SenderInfo(
          id: int.parse(payload['sender']['id'].toString()),
          name: payload['sender']['name'],
          avatarUrl: payload['sender']['avatarUrl'],
        ),
        isMe: payload['sender']['id'] == userId,
        fileUrl: payload['fileUrl'],
        type: payload['type'],
        status: payload['status'],
        sentAt: payload['sentAt'],
        editedAt: payload['editedAt'],
      ));

      notifyListeners();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        onNewMessage?.call();
      });
    }
  });

  return Future.value();
}
  void sendMessage(MessageSend msg) {
    final payload = {"event": "message", "data": msg.toJson()};
    SocketService().sendMessage(payload);
  }

  void leaveRoom(int userId, int roomId) {
    print("leave in provider");
    final payload = {
      "event": "leave_room",
      "data": {"userId": userId, "roomId": roomId}
    };
    SocketService().sendMessage(payload);
  }
  
}
