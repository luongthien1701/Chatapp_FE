import 'dart:convert';
import 'package:flutter/material.dart';
import '../model/chatroomdto.dart';
import '../Service/chatroom_service.dart';
import '../Service/socket_service.dart';

class ChatroomProvider extends ChangeNotifier {
  final ChatroomService _chatroomService = ChatroomService();
  final SocketService _socketService = SocketService();
  List<RoomDTO> rooms = [];

  Future<void> fetchChatrooms(int userId) async {
    try {
      rooms = await _chatroomService.getChatrooms(userId);
      rooms.sort((a, b) {
        final timeA = a.sendTimestamp ?? 0;
        final timeB = b.sendTimestamp ?? 0;
        return timeB.compareTo(timeA); // Tin mới nhất lên đầu
    });

      notifyListeners();
    } catch (e) {
      debugPrint("Fetch chatrooms error: $e");
    }
  }

  void startListening() {
    _socketService.messages.listen((data) {
      final msg = jsonDecode(data);
      final event = msg['event'];
      final payload = msg['data'];

      if (event == "new_message") {
        final id = payload['id'];

        rooms.removeWhere((room) => room.id == id);

        final room = RoomDTO(
          id: payload['id'],
          name: payload['name'],
          lastMessage: payload['lastMessage'],
          time: payload['time'],
          avatarUrl: payload['avatarUrl'],
          group: payload['group'],
        );
        rooms.insert(0, room);
        notifyListeners();
      }
    });
  }
}
