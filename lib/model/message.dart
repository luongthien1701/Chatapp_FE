enum MessageType { TEXT, IMAGE, VIDEO }

class SenderInfo {
  final int id;
  final String name;
  final String? avatarUrl;

  SenderInfo({
    required this.id,
    required this.name,
    this.avatarUrl,
  });

  factory SenderInfo.fromJson(Map<String, dynamic> json) {
    return SenderInfo(
      id: json['id'],
      name: json['name'],
      avatarUrl: json['avatarUrl'],
    );
  }
}

class MessageDTO {
  final int id;
  final String content;
  final String? fileUrl;
  final String type;
  final String status;
  final int sentAt; // timestamp
  final int? editedAt; // timestamp
  final SenderInfo sender;
  final bool isMe;

  MessageDTO({
    required this.id,
    required this.content,
    this.fileUrl,
    required this.type,
    required this.status,
    required this.sentAt,
    this.editedAt,
    required this.sender,
    required this.isMe,
  });

  factory MessageDTO.fromJson(Map<String, dynamic> json, int myId) {
    return MessageDTO(
      id: json['id'],
      content: json['content'],
      fileUrl: json['fileUrl'],
      type: json['type'],
      status: json['status'],
      sentAt: json['sentAt'],
      editedAt: json['editedAt'],
      sender: SenderInfo.fromJson(json['sender']),
      isMe: json['sender']['id'] == myId,
    );
  }
}

class MessageSend {
  final int chatRoomId;
  final int senderId;
  final String content;
  final String? fileUrl;
  final MessageType type;

  MessageSend({
    required this.chatRoomId,
    required this.senderId,
    required this.content,
    this.fileUrl,
    this.type = MessageType.TEXT,
  });

  Map<String, dynamic> toJson() {
    return {
      'chatRoomId': chatRoomId,
      'senderId': senderId,
      'content': content,
      'fileUrl': fileUrl,
      'type': MessageType.TEXT.name,
    };
  }
}
