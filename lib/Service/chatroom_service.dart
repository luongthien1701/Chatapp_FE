import 'dart:convert';
import 'package:chatapp/model/chatroomdto.dart';
import 'package:http/http.dart' as http;
class ChatroomService {
  final String baseUrl='http://192.168.200.1:8080/api';
  Future<List<RoomDTO>> getChatrooms(int userId) async
  {
    final url=Uri.parse('$baseUrl/room/$userId');
    final respon=await http.get(url);
    if (respon.statusCode==200)
    {
      final data=jsonDecode(utf8.decode(respon.bodyBytes));
      return (data as List).map((e) => RoomDTO.fromJson(e)).toList();
    }
    else 
    {
      throw Exception("Không thể lấy danh sách phòng chat");
    } 
  }
  Future<RoomDTO> getRoom(int roomId) async
  {
    final url=Uri.parse('$baseUrl/room/infomation/$roomId');
    final respon=await http.get(url);
    if (respon.statusCode==200)
    {
      final data=jsonDecode(utf8.decode(respon.bodyBytes));
      print(data);
      return RoomDTO.fromJson(data);
    }
    else 
    {
      throw Exception("Không thể lấy phòng chat");
    } 
  }
  Future<int> findRoom(int userId,int friendId) async
  {
    final url=Uri.parse('$baseUrl/room/find/$userId/$friendId');
    final respon=await http.get(url);
    if (respon.statusCode==200)
    {
      final data=jsonDecode(utf8.decode(respon.bodyBytes));
      return data['roomId'];
    }
    else 
    {
      throw Exception("Không thể lấy phòng chat");
    } 
  }
}