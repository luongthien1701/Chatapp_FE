class SearchDTO
{
    final String type;
    final int? id;
    final String? name;
    final String? avatarUrl;
    final String? content;
    final int? groupId;
    final String? groupName;
    SearchDTO({required this.type,required this.id,required this.name,required this.avatarUrl,required this.content,required this.groupId,required this.groupName});
}
class UserSearch
{
  final int? id;
  final String? avatarUrl;
  final String? displayname;
  UserSearch({required this.id,required this.avatarUrl,required this.displayname});
}
class RoomSearch
{
  final int? groupid;
  final String? avatarUrl;
  final String? groupname;
  RoomSearch({required this.groupid,required this.avatarUrl,required this.groupname});
}
class MessSearch
{
  final int? messid;
  final String? content;
  final int? groupid;
  final String? groupname;
  final String? sendername;
  MessSearch({required this.messid,required this.content,required this.groupid,required this.groupname,required this.sendername});
}