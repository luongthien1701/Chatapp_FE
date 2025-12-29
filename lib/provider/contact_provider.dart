import 'package:flutter/material.dart';
import '../model/friend.dart';
import '../service/friend_service.dart';

class FriendProvider extends ChangeNotifier {
  final FriendService _friendService = FriendService();
  List<FriendDTO> _list = [];
  bool _isLoading = false;

  List<FriendDTO> get list => _list;
  bool get isLoading => _isLoading;

  Future<void> fetchListFriend(int userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _list = await _friendService.getChatrooms(userId);
    } catch (e) {
      print("❌ Không thể lấy danh sách bạn bè: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
