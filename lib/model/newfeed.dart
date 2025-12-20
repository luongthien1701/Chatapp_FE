import 'package:chatapp/model/message.dart';

class NewfeedDTO {
  final int id;
  final SenderInfo senderId;
  final String content;
  final List<String>? imageUrl;
  final int createdAt;
  int favorite;
  int comments;
  bool isFavorite;
  NewfeedDTO({
    required this.id,
    required this.senderId,
    required this.content,
    required this.imageUrl,
    required this.createdAt,
    required this.favorite,
    required this.comments,
    required this.isFavorite,
  });
  factory NewfeedDTO.fromJson(Map<String, dynamic> json) {
    return NewfeedDTO(
      id: json['id'],
      senderId: SenderInfo.fromJson(json['sender']),
      content: json['content'],
      imageUrl: json['image'] != null ? List<String>.from(json['image']) : null,
      createdAt: json['createAt'],
      favorite: json['favorite'],
      comments: json['comments'],
      isFavorite: json['_liked'],
    );
  }
}
