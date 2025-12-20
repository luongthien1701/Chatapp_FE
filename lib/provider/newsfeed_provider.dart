import 'package:chatapp/Service/newsfeed_service.dart';
import 'package:chatapp/model/newfeed.dart';
import 'package:flutter/material.dart';

class NewsfeedProvider extends ChangeNotifier {
  NewsfeedService newsfeedService = NewsfeedService();
  List<NewfeedDTO> newsfeed = [];
  Future<void> fetchNewsfeed(int userId) async {
    try {
      newsfeed = await newsfeedService.getPost(userId);
      notifyListeners();
    } catch (e) {
      print("❌ Lỗi khi tải newsfeed: $e");
    }
  }
  void updatelike(int postId) 
  {
    final index = newsfeed.indexWhere((post) => post.id == postId);
    if (index != -1) {
      final post = newsfeed[index];
      if (post.isFavorite) {
        post.isFavorite = false;
        post.favorite -= 1;
      } else {
        post.isFavorite = true;
        post.favorite += 1;
      }
      notifyListeners();
    }
  }
  Future<void> likePost(int postId, int userId) async
  {
    try {
      await newsfeedService.likePost(postId, userId);
    } catch (e) {
      print("❌ Lỗi khi like bài viết: $e");
    }
  }
  Future<void> unlikePost(int postId, int userId) async
  {
    try {
      await newsfeedService.unlikePost(postId, userId);
    } catch (e) {
      print("❌ Lỗi khi unlike bài viết: $e");
    }
  }
}