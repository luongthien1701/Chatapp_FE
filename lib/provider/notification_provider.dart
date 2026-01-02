import 'package:rela/Service/notification_service.dart';
import 'package:rela/Service/socket_service.dart';
import 'package:rela/model/message.dart';
import 'package:flutter/foundation.dart';
import '../model/notification.dart';

class NotificationProvider extends ChangeNotifier {
  List<NotiDTO> notifications = [];
  bool hasNew = false;

  Future<void> loadInitial(List<NotiDTO> initNoti) async {
    notifications = initNoti;
    notifyListeners();
  }
  Future<void> sendToken(int userId, String token) async {
    await NotificationService.sendTokenToServer(userId, token);
  }
  /// Nhận event từ Hub
  void onReceive(Map<String, dynamic> msg) {
    if (msg['event'] != 'notification') return;

    final payload = msg['data'];

    notifications.add(
      NotiDTO(
        title: payload['title'] ?? '',
        senderId: SenderInfo(
          id: payload['sender']['id'],
          name: payload['sender']['name'] ?? '',
          avatarUrl: payload['sender']['avatarUrl'] ?? '',
        ),
        receiverId: payload['receiver'],
        status: payload['status'] ?? false,
        createdAt: payload['createdAt'],
        type: payload['type'] ?? '',
      ),
    );

    hasNew = true;
    notifyListeners();
  }
  void sendNotification(NotiDTO noti) {
    final payload = {"event": "notification", "data": noti.toJson()};
    SocketService().sendMessage(payload);
  }
  void clearNewFlag() {
    hasNew = false;
    notifyListeners();
  }
}
