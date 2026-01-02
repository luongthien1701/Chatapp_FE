import 'dart:convert';
import 'package:rela/Service/ip.dart';
import 'package:rela/model/comment.dart';
import 'package:rela/model/message.dart';
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
  Future<int> addComment(int postId, SenderInfo sender, String content) async
  {
    final url=Uri.parse('$baseUrl/comment');
    final response=await http.post(url,
    headers: {'Content-Type':'application/json'},
    body: jsonEncode(
      {
        'id':0,
        'postId':postId,
        'sender':sender.toJson(),
        'content':content,
      }
    )
    );
    if (response.statusCode==200)
    {
      print("Thêm bình luận thành công");
      final data=jsonDecode(utf8.decode(response.bodyBytes));
      return data['id'];      
    }
    else
    {
      throw Exception("Thêm bình luận thất bại");
    }
  }
  Future<void> deleteComment(int commentId) async
  {
    final url=Uri.parse('$baseUrl/comment/$commentId');
    final response=await http.delete(url);
    if (response.statusCode!=200)
    {
      throw Exception("Không thể xóa bình luận");
    }
  }
  Future<void> editComment(int postId, SenderInfo sender, String content) async
  {
    final url=Uri.parse('$baseUrl/comment');
    final response=await http.put(url,
    headers: {'Content-Type':'application/json'},
    body: jsonEncode(
      {
        'id':0,
        'postId':postId,
        'sender':sender.toJson(),
        'content':content,
      }
    )
    );
    if (response.statusCode!=200)
    {
      throw Exception("Không thể sửa bình luận");
    }
  }
}