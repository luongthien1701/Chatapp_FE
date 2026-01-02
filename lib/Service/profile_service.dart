import 'dart:convert';
import 'package:rela/Service/ip.dart';
import 'package:rela/model/message.dart';
import 'package:rela/model/userdto.dart';
import 'package:http/http.dart' as http;
class ProfileService {
  String baseUrl = Ip().getIp();
  Future<SenderInfo> getProfile(int userId) async
  {
    final url=Uri.parse('$baseUrl/user/$userId');
    final response=await http.get(url);
    if (response.statusCode==200)
    {
      final data=jsonDecode(utf8.decode(response.bodyBytes));
      return SenderInfo(id: data['id'], name: data['name'],avatarUrl: data['avatarUrl']);
    }
    else
    {
      throw Exception("Không thể tìm thấy người dùng");
    }
  }
  Future<UserProfile> getUserProfile(int userId) async
  {
    final url=Uri.parse('$baseUrl/user/profile/$userId');
    final response=await http.get(url);
    if (response.statusCode==200)
    {
      final data=jsonDecode(utf8.decode(response.bodyBytes));
      return UserProfile(id: data['id']??"", displayName: data['displayName']??"", email: data['email']??"", password: data['password']??"", phone: data['phone']??"");
    }
    else
    {
      throw Exception("Không thể tìm thấy người dùng");
    }
  }
  Future<String> checkFriend(int userId,int friendId) async
  {
    final url=Uri.parse('$baseUrl/friend/$userId/$friendId');
    final response=await http.get(url);
    if (response.statusCode==200)
    {
      final data=jsonDecode(response.body);
      print(data['check']);
      return data['status'];
    }
    else 
    {
      throw Exception("Không thể kiểm tra"); 
    }

  }
  Future<void> changeAvatar(int userId, String avatarUrl) async
  {
    final url=Uri.parse('$baseUrl/user/changeavatar');
    final response=await http.put(url,
    headers: {'Content-Type':'application/json'},
    body: jsonEncode(
      {
        'id':userId,
        'url':avatarUrl,
      }
    )
    );
    if (response.statusCode==200)
    {
    }
    else
    {
      throw Exception("Cập nhật avatar thất bại");
    }
  }
  Future<void> updateProfile(int userId, String displayName,String email, String phone) async
  {
    final url=Uri.parse('$baseUrl/user/updateprofile');
    final response=await http.put(url,
    headers: {'Content-Type':'application/json'},
    body: jsonEncode(
      {
        'id':userId,
        'displayName':displayName,
        'email':email,
        'phone':phone,
      }
    )
    );
    if (response.statusCode==200)
    {
    }
    else
    {
      throw Exception("Cập nhật profile thất bại");
    }
  }
}