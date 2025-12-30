import 'dart:convert';
import 'package:rela/Service/ip.dart';
import 'package:rela/model/friend.dart';
import 'package:http/http.dart' as http;
class FriendService {
  String baseUrl = Ip().getIp();
  Future<List<FriendDTO>> getChatrooms(int userId) async
  {
    final url=Uri.parse('$baseUrl/friend/$userId');
    final respon=await http.get(url);
    if (respon.statusCode==200)
    {
      final data=jsonDecode(utf8.decode(respon.bodyBytes));
      return (data as List).map((e) => FriendDTO.fromJson(e)).toList();
    }
    else 
    {
      throw Exception("Không thể lấy danh sách phòng chat");
    } 
  }
  Future<void> addFriend(int userId,int friendId) async
  {
    final url=Uri.parse('$baseUrl/friend');
    final respon=await http.post(
      url,
      headers: {'Content-Type':'application/json'},
      body: jsonEncode({
        'senderId':userId,
        'receiverId':friendId,
      }),
    );
    if (respon.statusCode==200)
    {
      print("Đã gửi lời mời kết bạn");
    }
    else 
    {
      throw Exception("Không thể gửi lời mời kết bạn");
    } 
  }
  Future<void> deleteFriend(int userId,int friendId) async
  {
    final url=Uri.parse('$baseUrl/friend');
    final respon=await http.delete(
      url,
      headers: {'Content-Type':'application/json'},
      body: jsonEncode({
        'senderId':userId,
        'receiverId':friendId,
      }),
    );
    if (respon.statusCode==200)
    {
      print("Đã gửi lời mời kết bạn");
    }
    else 
    {
      throw Exception("Không thể gửi lời mời kết bạn");
    } 
  }
  Future<void> acceptFriend(int userId,int friendId) async
  {
    final url=Uri.parse('$baseUrl/friend');
    final respon=await http.patch(
      url,
      headers: {'Content-Type':'application/json'},
      body: jsonEncode({
        'senderId':userId,
        'receiverId':friendId,
      }),
    );
    if (respon.statusCode==200)
    {
      print("Đã gửi lời mời kết bạn");
    }
    else 
    {
      throw Exception("Không thể gửi lời mời kết bạn");
    } 
  }
}