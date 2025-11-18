import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/mess_list_provider.dart';
import 'conversation.dart';

class MessList extends StatefulWidget {
  final int userId;
  const MessList({super.key, required this.userId});

  @override
  State<MessList> createState() => _MessList();
}

class _MessList extends State<MessList> {
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ChatroomProvider>(context, listen: false);
    provider.fetchChatrooms(widget.userId);
    provider.startListening();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 152, 209, 255),
      body: Consumer<ChatroomProvider>(
        builder: (context, provider, _) {
          final rooms = provider.rooms;

          if (rooms.isEmpty) {
            return const Center(child: Text("Chưa có cuộc trò chuyện nào"));
          }

          return ListView.builder(
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: room.avatarUrl != null
                      ? NetworkImage(room.avatarUrl!)
                      : null,
                  child: room.avatarUrl == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text(room.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(room.lastMessage ?? "Chưa có tin nhắn"),
                trailing: Text(room.time ?? "", style: const TextStyle(fontSize: 12)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Conversation(
                        userId: widget.userId,
                        convervationid: room.id,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
