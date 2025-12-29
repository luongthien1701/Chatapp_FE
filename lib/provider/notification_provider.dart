import 'package:chatapp/model/message.dart';
import 'package:flutter/foundation.dart';
import '../model/notification.dart';

class NotificationProvider extends ChangeNotifier {
  List<NotiDTO> notifications = [];
  bool hasNew = false;

  Future<void> loadInitial(List<NotiDTO> initNoti) async {
    notifications = initNoti;
    notifyListeners();
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
      ),
    );

    hasNew = true;
    notifyListeners();
  }

  void clearNewFlag() {
    hasNew = false;
    notifyListeners();
  }
}
