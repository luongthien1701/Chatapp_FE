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
      List<SearchDTO> data = await _searchService.getMessages(userId, like);
      _userlist.clear();
      _messlist.clear();
      _roomlist.clear();

      for (var _data in data) {
        switch (_data.type) {
          case "user":
            _userlist.add(UserSearch(
              id: _data.id,
              avatarUrl: _data.avatarUrl,
              displayname: _data.name,
            ));
            break;
          case "messager":
            _messlist.add(MessSearch(
              messid: _data.id,
              content: _data.content,
              groupid: _data.groupId,
              groupname: _data.groupName,
              sendername: _data.name,
            ));
            break;
          case "room":
            _roomlist.add(RoomSearch(
              groupid: _data.groupId,
              avatarUrl: _data.avatarUrl,
              groupname: _data.groupName,
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
