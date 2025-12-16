import 'dart:convert';
import 'package:chatapp/Service/ip.dart';
import 'package:chatapp/model/notification.dart';
import 'package:chatapp/model/message.dart';
import 'package:http/http.dart' as http;
class NotificationService {
  String baseUrl = Ip().getIp();
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
      )).toList();
    }
    else 
    {
      throw Exception("Không thể lấy tin nhắn");
    } 
  }
}