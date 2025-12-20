import 'package:chatapp/Service/comment_service.dart';
import 'package:chatapp/model/comment.dart';
import 'package:chatapp/model/message.dart';
import 'package:flutter/material.dart';

class CommentProvider extends ChangeNotifier {
  CommentService commentService = CommentService();
  List<CommentDTO> comments = [];
  bool isLoading = false;
  Future<void> fetchComments(int postId) async {
    try {
      isLoading = true;
      comments = await commentService.getComments(postId);
      isLoading = false;
      notifyListeners();
    } catch (e) {
      print("❌ Lỗi khi tải bình luận: $e");
    }
  }
  Future<void> addComment(int postId, SenderInfo sender, String content) async
  {
    try {
      int id=await commentService.addComment(postId, sender, content);
      comments.insert(
      0,
      CommentDTO(
        id: id,
        content: content,
        sender: sender,
      ),
      );
      notifyListeners();
    } catch (e) {
      print("❌ Lỗi khi thêm bình luận: $e");
    }
  }
  Future<void> deleteComment(int commentId) async
  {
    try {
      await commentService.deleteComment(commentId);
    } catch (e) {
      print("❌ Lỗi khi xóa bình luận: $e");
    }
  }
  Future<void> editComment(int postId, SenderInfo sender, String content) async
  {
    try {
      await commentService.editComment(postId, sender, content);
    } catch (e) {
      print("❌ Lỗi khi sửa bình luận: $e");
    }
  }
}