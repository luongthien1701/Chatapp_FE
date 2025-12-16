import 'package:chatapp/model/message.dart';
import 'package:flutter/foundation.dart';

class NewfeedDTO {
  final int Id;
  final SenderInfo senderId;
  final String content;
  final String? imageUrl;
  final int createdAt;
  final int favorite;
  final int comments;
  NewfeedDTO({
    required this.Id,
    required this.senderId,
    required this.content,
    required this.imageUrl,
    required this.createdAt,
    required this.favorite,
    required this.comments,
  });
  factory NewfeedDTO.fromJson(Map<String, dynamic> json) {
    return NewfeedDTO(
      Id: json['id'],
      senderId: SenderInfo.fromJson(json['sender']),
      content: json['content'],
      imageUrl: json['image'],
      createdAt: json['createAt'],
      favorite: json['favorite'],
      comments: json['comments'],
    );
  }
}
