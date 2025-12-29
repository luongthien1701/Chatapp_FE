import 'package:chatapp/model/message.dart';

class CommentDTO {
  int id;
  String content;
  SenderInfo sender;
  CommentDTO({
    required this.id,
    required this.content,
    required this.sender,
  });
  factory CommentDTO.fromJson(Map<String, dynamic> json) {
    return CommentDTO(
      id: json['id'],
      content: json['content'],
      sender: SenderInfo.fromJson(json['sender']),
    );
  }
  Map<String,dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'sender': sender.toJson(),
    };
  }
}