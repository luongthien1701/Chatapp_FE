import 'dart:convert';
import 'package:chatapp/model/search.dart';
import 'package:http/http.dart' as http;
class SearchService {
  final String baseUrl='http://192.168.200.1:8080/api';
  Future<List<SearchDTO>> getMessages(int userId,String like) async
  {
    final url=Uri.parse('$baseUrl/search/$userId/$like');
    final respon=await http.get(url);
    if (respon.statusCode==200)
    {
      final data=jsonDecode(utf8.decode(respon.bodyBytes)) as List;
      return data.map((json)=> SearchDTO(
        type: json['type'],
        id: json['id'],
        name: json['name'],
        avatarUrl: json['avatarUrl'],
        content: json['content'],
        groupId: json['groupId'],
        groupName: json['groupName'])
        ).toList();
    }
    else 
    {
      throw Exception("Không thể lấy tin nhắn");
    } 
  }
}