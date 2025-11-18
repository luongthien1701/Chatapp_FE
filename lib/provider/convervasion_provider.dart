import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:chatapp/Service/chatroom_service.dart';
import 'package:chatapp/Service/message_service.dart';
import 'package:chatapp/Service/socket_service.dart';
import 'package:chatapp/model/chatroomdto.dart';
import 'package:chatapp/model/message.dart';

class ConversationProvider with ChangeNotifier {
  final ChatroomService _chatroomService = ChatroomService();
  final MessageService _messageService = MessageService();

  RoomDTO? room;
  List<MessageDTO> messages = [];

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

  Future<void> loadMessages(int userId, int roomId) async {
    try {
      messages = await _messageService.getMessages(userId, roomId);
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Lỗi loadMessages: $e");
    }
  }

  void joinRoom(int userId, int roomId) {
    final payload = {
      "event": "join_room",
      "data": {"userId": userId, "roomId": roomId}
    };
    SocketService().sendMessage(payload);
  }

  void listenMessages(int userId) {
    SocketService().messages.listen((data) {
      print(data);
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
          sentAt: payload['sentAt'] as int,
          editedAt: payload['editedAt'] != null
              ? payload['editedAt'] as int
              : null,
        ));
        notifyListeners();
      }
    });
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
