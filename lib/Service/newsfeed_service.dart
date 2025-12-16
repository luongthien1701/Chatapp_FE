import 'dart:convert';
import 'package:chatapp/model/comment.dart';
import 'package:chatapp/model/newfeed.dart';
import 'package:chatapp/model/userdto.dart';
import 'package:http/http.dart' as http;
class NewsfeedService {
  final String baseUrl='http://192.168.200.1:8080/api';
  Future<List<NewfeedDTO>> getPost(int userId) async
  {
    final url=Uri.parse('$baseUrl/newsfeed/$userId');
    final response=await http.get(url);
    if (response.statusCode==200)
    {
      final data=jsonDecode(utf8.decode(response.bodyBytes)) as List;
      print(data);
      return data.map(  (e) => NewfeedDTO.fromJson(e)).toList();
    }
    else
    {
      throw Exception("Không thể tìm thấy người dùng");
    }
  }
}