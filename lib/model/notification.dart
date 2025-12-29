import 'package:chatapp/model/message.dart';

class NotiDTO {
  final String title;
  final bool status;
  final int createdAt;
  final SenderInfo senderId;
  final int receiverId;
  NotiDTO({
    required this.title,
    required this.status,
    required this.createdAt,
    required this.senderId,
    required this.receiverId,
  });

  factory NotiDTO.fromJson(Map<String, dynamic> json) {
    return NotiDTO(
      title: json['title'],
      status: json['status'],
      createdAt: json['createdAt'],
      senderId: SenderInfo.fromJson(json['sender']),
      receiverId: json['receiver'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'status': status,
      'createdAt': createdAt,
      'sender': {
        'id': senderId.id,
        'name': senderId.name,
        'avatarUrl': senderId.avatarUrl,
      },
      'receiver': receiverId,
    };
  }
}
