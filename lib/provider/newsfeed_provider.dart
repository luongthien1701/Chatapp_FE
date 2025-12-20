import 'dart:io';

import 'package:chatapp/Service/newsfeed_service.dart';
import 'package:chatapp/Service/upload_service.dart';
import 'package:chatapp/model/image.dart';
import 'package:chatapp/model/message.dart';
import 'package:chatapp/model/newfeed.dart';
import 'package:flutter/material.dart';

class NewsfeedProvider extends ChangeNotifier {
  NewsfeedService newsfeedService = NewsfeedService();
  UploadService uploadService = UploadService();
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
  void increaseComment(int postId) 
  {
    final index = newsfeed.indexWhere((post) => post.id == postId);
    if (index != -1) {
      final post = newsfeed[index];
      post.comments += 1;
      notifyListeners();
    }
  }
  void decreaseComment(int postId) 
  {
    final index = newsfeed.indexWhere((post) => post.id == postId);
    if (index != -1) {
      final post = newsfeed[index];
      post.comments -= 1;
      notifyListeners();
    }
  }
  Future<void> upLoadImagePost(List<File> image,int postId) async
  {
    List<String> imageUrl=[];
    try {
      for (var element in image) {
        String url = await uploadService.uploadimage(element, "post", postId);
        imageUrl.add(url);
        await newsfeedService.addPostImage(PostImage(id: 0, postId: postId, imageUrl: url));
      }
    } catch (e) {
      print("❌ Lỗi khi tải ảnh lên bài viết: $e");
    }
  }
  Future<int> createPost(SenderInfo senderInfo, String content) async
  {
    try {
      int id=await newsfeedService.createPost(senderInfo, content);
      return id;
    } catch (e) {
      print("❌ Lỗi khi tạo bài viết: $e");
      return -1;
    }
  }
}