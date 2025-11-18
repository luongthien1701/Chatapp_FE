import 'dart:convert';
import 'package:flutter/material.dart';
import '../Service/socket_service.dart';
import '../Service/notification_service.dart';
import '../model/notification.dart';
import '../model/message.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  final SocketService _socket = SocketService();

  List<NotiDTO> notifications = [];
  bool hasNew = false;
  int _userId = 0;
  bool _initialized = false;

  Future<void> init(int userId) async {
    if (_initialized) return; // tránh init lại
    _initialized = true;
    _userId = userId;

    await _loadNoti();

    _socket.connect(userId);
    _socket.messages.listen((data) {
      try {
        final Map<String, dynamic> msg = jsonDecode(data);
        if (msg['event'] != "notification") return;

        final payload = msg['data'];
        final noti = NotiDTO(
          title: payload['title'] ?? '',
          senderId: SenderInfo(
            id: payload['sender']['id'],
            name: payload['sender']['name'] ?? '',
            avatarUrl: payload['sender']['avatarUrl'] ?? '',
          ),
          receiverId: payload['receiver'],
          status: payload['status'] ?? false,
          createdAt: payload['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
        );

        notifications.add(noti);
        hasNew = true;
        notifyListeners();
      } catch (e) {
        debugPrint("Lỗi parse thông báo: $e");
      }
    });
  }

  Future<void> _loadNoti() async {
    if (_userId == 0) return;
    notifications = await _notificationService.getMessages(_userId);
    notifyListeners();
  }

  void clearNewFlag() {
    hasNew = false;
    notifyListeners();
  }
}
