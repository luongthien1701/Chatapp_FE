import 'package:rela/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/mess_list_provider.dart';
import 'conversation.dart';

class MessList extends StatefulWidget {
  const MessList({super.key});

  @override
  State<MessList> createState() => _MessList();
}

class _MessList extends State<MessList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ChatroomProvider>();
      final userId = context.read<UserProvider>().userId;
      provider.fetchChatrooms(userId);
      provider.startListening();
    });
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
                title: Text(
                  room.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  room.lastMessage == null
                      ? "Chưa có tin nhắn"
                      : room.lastMessage!.isNotEmpty
                      ? room.lastMessage!
                      : "[Ảnh]",
                ),

                trailing: Text(
                  room.time ?? "",
                  style: const TextStyle(fontSize: 12),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Conversation(convervationid: room.id),
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
