import 'package:chatapp/Service/comment_service.dart';
import 'package:chatapp/Service/newsfeed_service.dart';
import 'package:chatapp/model/comment.dart';
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
}