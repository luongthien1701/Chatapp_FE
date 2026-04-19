import 'package:flutter/material.dart';
import '../service/search_service.dart';
import '../model/search.dart';

class SearchProvider extends ChangeNotifier {
  final SearchService _searchService = SearchService();

  final List<UserSearch> _userlist = [];
  final List<MessSearch> _messlist = [];
  final List<RoomSearch> _roomlist = [];
  bool _loading = false;

  List<UserSearch> get userlist => _userlist;
  List<MessSearch> get messlist => _messlist;
  List<RoomSearch> get roomlist => _roomlist;
  bool get loading => _loading;

  Future<void> loaddata(int userId, String like) async {
    _loading = true;
    notifyListeners();
    try {
      List<SearchDTO> datas = await _searchService.getMessages(userId, like);
      _userlist.clear();
      _messlist.clear();
      _roomlist.clear();

      for (var data in datas) {
        switch (data.type) {
          case "user":
            _userlist.add(UserSearch(
              id: data.id,
              avatarUrl: data.avatarUrl,
              displayname: data.name,
            ));
            break;
          case "messager":
            _messlist.add(MessSearch(
              messid: data.id,
              content: data.content,
              groupid: data.groupId,
              groupname: data.groupName,
              sendername: data.name,
            ));
            break;
          case "room":
            _roomlist.add(RoomSearch(
              groupid: data.groupId,
              avatarUrl: data.avatarUrl,
              groupname: data.groupName,
            ));
            break;
        }
      }
    } catch (e) {
      debugPrint("loaddata error: $e");
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
