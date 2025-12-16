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
}