import 'dart:convert';
import 'package:chatapp/Service/ip.dart';
import 'package:chatapp/model/comment.dart';
import 'package:http/http.dart' as http;
class CommentService {
  String baseUrl = Ip().getIp();
  Future<List<CommentDTO>> getComments(int postId) async
  {
    final url=Uri.parse('$baseUrl/comment/$postId');
    final response=await http.get(url);
    if (response.statusCode==200)
    {
      final data=jsonDecode(utf8.decode(response.bodyBytes)) as List;
      print(data);
      return data.map(  (e) => CommentDTO.fromJson(e)).toList();
    }
    else
    {
      throw Exception("Không thể tìm thấy bình luận");
    }
  }
  Future<void> addComment(int postId, int userId, String content) async
  {
    final url=Uri.parse('$baseUrl/comment/add');
    final response=await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'postId': postId,
        'userId': userId,
        'content': content,
      }),
    );
    if (response.statusCode!=200)
    {
      throw Exception("Không thể thêm bình luận");
    }
  }
  Future<void> deleteComment(int commentId) async
  {
    final url=Uri.parse('$baseUrl/comment/delete/$commentId');
    final response=await http.delete(url);
    if (response.statusCode!=200)
    {
      throw Exception("Không thể xóa bình luận");
    }
  }
}