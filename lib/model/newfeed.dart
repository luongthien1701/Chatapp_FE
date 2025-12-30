import 'package:rela/model/message.dart';

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
    this.imageUrl,
    required this.createdAt,
    required this.favorite,
    required this.comments,
    required this.isFavorite,
  });
  factory NewfeedDTO.fromJson(Map<String, dynamic> json) {
    final images = json['image'];
    return NewfeedDTO(
      id: json['id'],
      senderId: SenderInfo.fromJson(json['sender']),
      content: json['content'],
      imageUrl: images == null
          ? null
          : (images is List
                ? images.map((e) => "http://192.168.1.13:8080$e").toList()
                : ["http://192.168.1.13:8080$images"]),
      createdAt: json['createAt'],
      favorite: json['favorite'],
      comments: json['comments'],
      isFavorite: json['_liked'],
    );
  }
}
