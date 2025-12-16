import 'dart:convert';
import 'package:chatapp/Service/ip.dart';
import 'package:chatapp/model/userdto.dart';
import 'package:http/http.dart' as http;
class ProfileService {
  String baseUrl = Ip().getIp();
  Future<UserDTO> getProfile(int userId) async
  {
    final url=Uri.parse('$baseUrl/user/$userId');
    final response=await http.get(url);
    if (response.statusCode==200)
    {
      final data=jsonDecode(utf8.decode(response.bodyBytes));
      return UserDTO(id: data['id'], displayName: data['displayName']);
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
}