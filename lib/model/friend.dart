class FriendDTO
{
  int id;
  int friendId;
  String displayname;
  String? avtUrl;
  String status;
  String? lastlogin;
  FriendDTO({required this.id,required this.friendId,required this.displayname,required this.avtUrl,required this.status,required this.lastlogin});
  factory FriendDTO.fromJson(Map<String, dynamic> json)
  {
    return FriendDTO(
      id:json['id'],
      friendId: json['friendId'],
      displayname: json['displayName'],
      avtUrl: json['avatarUrl'], 
      status: json['status'], 
      lastlogin: json['lastLogin']);
  }
}