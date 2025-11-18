import 'package:chatapp/Screen/account.dart';
import 'package:chatapp/provider/search_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/search.dart';

class Check extends StatefulWidget {
  final int userId;
  const Check({super.key, required this.userId});

  @override
  State<Check> createState() => _Check();
}

class _Check extends State<Check> {
  int _index = 0;
  final TextEditingController like = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SearchProvider>();
    final pages = <Widget>[
      _ContactPage(userId: widget.userId, userlist: provider.userlist),
      _MessagePage(messlist: provider.messlist),
      _RoomPage(roomlist: provider.roomlist),
    ];

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 152, 209, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 213, 221, 227),
        title: TextField(
          controller: like,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            hintText: "Nhập dữ liệu",
          ),
          onChanged: (value) {
            context.read<SearchProvider>().loaddata(widget.userId, like.text);
          },
        ),
        actions: const [Icon(Icons.search)],
      ),
      body: Column(
        children: [
          Row(
            children: [
              const SizedBox(height: 50),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _index = 0),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        border: Border.all(width: 1),
                        borderRadius: const BorderRadius.all(Radius.circular(8))),
                    child: const Text("Contact"),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _index = 1),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        border: Border.all(width: 1),
                        borderRadius: const BorderRadius.all(Radius.circular(8))),
                    child: const Text("Messages"),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _index = 2),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        border: Border.all(width: 1),
                        borderRadius: const BorderRadius.all(Radius.circular(8))),
                    child: const Text("Chat Room"),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: provider.loading
                ? const Center(child: CircularProgressIndicator())
                : IndexedStack(index: _index, children: pages),
          ),
        ],
      ),
    );
  }
}


class _ContactPage extends StatelessWidget {
  final List<UserSearch> userlist;
  final int userId;
  const _ContactPage({required this.userId ,required this.userlist});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView.builder(
        itemCount: userlist.length,
        itemBuilder: (context, index) {
          final user = userlist[index];
          return ListTile(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=> Account(userId: userId, friendId: user.id??0)));
            },
            leading: CircleAvatar(
              backgroundImage: (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
                  ? NetworkImage(user.avatarUrl!)
                  : const AssetImage('assets/image/avatar_default.png') as ImageProvider,
            ),
            title: Text(user.displayname ?? "Không tên"),
          );
        },
      ),
    );
  }
}

class _MessagePage extends StatelessWidget {
  final List<MessSearch> messlist;
  const _MessagePage({required this.messlist});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView.builder(
        itemCount: messlist.length,
        itemBuilder: (context, index) {
          final mess = messlist[index];
          return ListTile(
            title: Text(mess.content ?? ""),
            subtitle: Text("Nhóm: ${mess.groupname ?? "Không rõ"} - Người gửi: ${mess.sendername ?? "Ẩn danh"}"),
          );
        },
      ),
    );
  }
}

class _RoomPage extends StatelessWidget {
  final List<RoomSearch> roomlist;
  const _RoomPage({required this.roomlist});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView.builder(
        itemCount: roomlist.length,
        itemBuilder: (context, index) {
          final room = roomlist[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: (room.avatarUrl != null && room.avatarUrl!.isNotEmpty)
                  ? NetworkImage(room.avatarUrl!)
                  : const AssetImage('assets/image/avatar_default.png') as ImageProvider,
            ),
            title: Text(room.groupname ?? "Không rõ tên nhóm"),
          );
        },
      ),
    );
  }
}
