import 'dart:convert';
import 'package:chatapp/Service/ip.dart';
import 'package:http/http.dart' as http;
import 'package:chatapp/model/message.dart';
class MessageService {
  String baseUrl = Ip().getIp();
  Future<List<MessageDTO>> getMessages(int userId, int conversationId) async
  {
    final url=Uri.parse('$baseUrl/messager/$conversationId');
    final respon=await http.get(url);
    if (respon.statusCode==200)
    {
      final data=jsonDecode(utf8.decode(respon.bodyBytes)) as List;
      return data.map((messageJson) => MessageDTO(
        id: messageJson['id'],
        content: messageJson['content'],
        fileUrl: messageJson['fileUrl'],
        type: messageJson['type'],
        status: messageJson['status'],
        sentAt: messageJson['sentAt'],
        editedAt: messageJson['editedAt'],
        sender: SenderInfo(
          id: messageJson['sender']['id'],
          name: messageJson['sender']['name'],
          avatarUrl: messageJson['sender']['avatarUrl'],
        ),
        isMe: userId==messageJson['sender']['id'], // This field can be set later based on the current user ID
      )).toList();
    }
    else 
    {
      throw Exception("Không thể lấy tin nhắn");
    } 
  }
}