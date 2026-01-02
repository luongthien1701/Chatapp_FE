class RoomDTO {
  final int id;
  final String name;
  final String? avatarUrl;
  final String? lastMessage;
  final String? group;
  final String? time;           
  final int? sendTimestamp;     

  RoomDTO({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.lastMessage,
    required this.group,
    this.time,
    this.sendTimestamp,
  });

  factory RoomDTO.fromJson(Map<String, dynamic> json) {
    String? formattedTime;
    int? millis = json['sendTime'];

    if (millis != null) {
      try {
        final dateTime = DateTime.fromMillisecondsSinceEpoch(millis);
        formattedTime =
            '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      } catch (e) {
        formattedTime = null;
      }
    }

    return RoomDTO(
      id: json['id'],
      name: json['name'],
      avatarUrl: json['avatarUrl'],
      lastMessage: json['lastMessage'],
      group: json['group'] ?? "",
      time: formattedTime,
      sendTimestamp: millis,
    );
  }
}
