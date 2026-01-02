import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rela/Service/ip.dart';
import 'package:rela/model/notification.dart';
import 'package:rela/model/message.dart';
import 'package:http/http.dart' as http;
class NotificationService {
  String baseUrl = Ip().getIp();
  static final _plugin=FlutterLocalNotificationsPlugin();
  Future<List<NotiDTO>> getMessages(int userId) async
  {
    final url=Uri.parse('$baseUrl/notification/$userId');
    final respon=await http.get(url);
    if (respon.statusCode==200)
    {
      final data=jsonDecode(utf8.decode(respon.bodyBytes)) as List;
      return data.map((messageJson) => NotiDTO(
        title: messageJson['title'],
        status: messageJson['status'],
        createdAt: messageJson['createdAt'],
        senderId: SenderInfo(
          id: messageJson['sender']['id'],
          name: messageJson['sender']['name'],
          avatarUrl: messageJson['sender']['avatarUrl'],
        ),
        receiverId: messageJson['receiver'],
        type: messageJson['type'],
      )).toList();
    }
    else 
    {
      throw Exception("Không thể lấy tin nhắn");
    } 
  }
  static Future init() async {
    const androidSettings=AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings=InitializationSettings(
      android: androidSettings,
    );
    await _plugin.initialize(settings);
  }
  static Future showNotification(
    int id,
    String title,
    String body,
  ) async {
    const androidDetails=AndroidNotificationDetails(
      'channelId',
      'channelName',
      channelDescription: 'description',
      importance: Importance.max,
      priority: Priority.high,
    );
    const notificationDetails=NotificationDetails(
      android: androidDetails,
    );
    await _plugin.show(
      0,
      title,
      body,
      notificationDetails,
    );
  }

  static Future<void> sendTokenToServer(int userId, String token) async {
    String baseUrl = Ip().getIp();
    final url = Uri.parse('$baseUrl/notification/token');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'token': token}),
    );
    if (response.statusCode != 200) {
      throw Exception("Không thể gửi token đến server");
    }
  }
}