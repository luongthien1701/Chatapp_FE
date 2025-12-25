import 'dart:convert';
import 'package:chatapp/Service/ip.dart';
import 'package:chatapp/model/image.dart';
import 'package:chatapp/model/message.dart';
import 'package:chatapp/model/newfeed.dart';
import 'package:http/http.dart' as http;
class NewsfeedService {
  String baseUrl = Ip().getIp();
  Future<List<NewfeedDTO>> getPost(int userId) async
  {
    final url=Uri.parse('$baseUrl/newsfeed/$userId');
    final response=await http.get(url);
    if (response.statusCode==200)
    {
      final data=jsonDecode(utf8.decode(response.bodyBytes)) as List;
      return data.map(  (e) => NewfeedDTO.fromJson(e)).toList();
    }
    else
    {
      throw Exception("Không thể tìm thấy người dùng");
    }
  }
  Future<List<NewfeedDTO>> getPostByUserId(int userId) async
  {
    final url=Uri.parse('$baseUrl/newsfeed/profile/$userId');
    final response=await http.get(url);
    if (response.statusCode==200)
    {
      final data=jsonDecode(utf8.decode(response.bodyBytes)) as List;
      return data.map(  (e) => NewfeedDTO.fromJson(e)).toList();
    }
    else
    {
      throw Exception("Không thể tìm thấy người dùng");
    }
  }

  Future<void> likePost(int postId, int userId) async
  {
    final url=Uri.parse('$baseUrl/newsfeed/addlike');
    final response=await http.put(url,
    headers: {'Content-Type':'application/json'},
    body: jsonEncode(
      {
        'postId':postId,
        'userId':userId,
      }
    )
    );
    if (response.statusCode==200)
    {
    }
    else
    {
      throw Exception("Like post thất bại");
    }
  }
  Future<void> unlikePost(int postId, int userId) async
  {
    final url=Uri.parse('$baseUrl/newsfeed/removelike');
    final response=await http.put(url,
    headers: {'Content-Type':'application/json'},
    body: jsonEncode(
      {
        'postId':postId,
        'userId':userId,
      }
    )
    );
    if (response.statusCode==200)
    {
    }
    else
    {
      throw Exception("Unlike post thất bại");
    }
  }
  Future<void> addPostImage(PostImage postImage) async
  {
    final url=Uri.parse('$baseUrl/newsfeed/image');
    final response=await http.post(url,
    headers: {'Content-Type':'application/json'},
    body: jsonEncode(
      {
        "id":0,
        'postId':postImage.postId,
        'imageUrl':postImage.imageUrl,
      }
    )
    );
    if (response.statusCode==200)
    {
    }
    else
    {
      throw Exception("Thêm ảnh vào bài viết thất bại");
    }
  }
  Future<int> createPost(SenderInfo senderInfo, String content) async
  {
    final url=Uri.parse('$baseUrl/newsfeed');
    final response=await http.post(url,
    headers: {'Content-Type':'application/json'},
    body: jsonEncode(
      {
        'id':0,
        'sender':senderInfo.toJson(),
        'content':content,
      }
    )
    );
    if (response.statusCode==200)
    {
      final data=jsonDecode(utf8.decode(response.bodyBytes));
      return data['id'];
    }
    else
    {
      throw Exception("Tạo bài viết thất bại");
    }
  }
  Future<void> deletePost(int postId) async
  {
    final url=Uri.parse('$baseUrl/newsfeed/$postId');
    final response=await http.delete(url);
    if (response.statusCode==200)
    {
    }
    else
    {
      throw Exception("Xóa bài viết thất bại");
    }
  }
}