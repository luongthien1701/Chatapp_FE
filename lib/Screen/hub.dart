import 'package:chatapp/Screen/newfeed.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/notification_provider.dart';
import '../Screen/account.dart';
import '../Screen/contact.dart';
import '../Screen/mess_list.dart';
import '../Screen/profile.dart';
import '../Screen/search.dart';

class Hub extends StatefulWidget {
  final int userId;
  const Hub({super.key, required this.userId});

  @override
  State<Hub> createState() => _HubState();
}

class _HubState extends State<Hub> {
  int _index = 0;
  String _state = "Messages";
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      MessList(userId: widget.userId),
      Contact(userId: widget.userId),
      Profile(userId: widget.userId),
      Newfeed(userId: widget.userId),
    ];
  }

  void _showNotificationsMenu(BuildContext context, TapDownDetails details) {
    final provider = context.read<NotificationProvider>();
    final position = details.globalPosition;
    provider.clearNewFlag();

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
          position.dx, position.dy + 30, position.dx, position.dy),
      items: [
        PopupMenuItem(
          enabled: false,
          child: SizedBox(
            height: 200,
            width: 200,
            child: provider.notifications.isEmpty
                ? const Center(child: Text("Không có thông báo"))
                : ListView.builder(
                    itemCount: provider.notifications.length,
                    itemBuilder: (context, index) {
                      final n = provider.notifications[index];
                      return ListTile(
                        leading: const Icon(Icons.notifications),
                        title: Text(n.senderId.name),
                        subtitle: Text(n.title),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Account(
                                userId: widget.userId,
                                friendId: n.senderId.id,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final noti = context.watch<NotificationProvider>();
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 27, 92, 203),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(_state),
        backgroundColor: const Color.fromARGB(255, 27, 92, 203),
        actions: [
          if (_index != 2&&_index!=3)
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Check(userId: widget.userId),
                      ),
                    );
                  },
                  icon: const Icon(Icons.search, color: Colors.white),
                ),
                GestureDetector(
                  onTapDown: (d) => _showNotificationsMenu(context, d),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Stack(
                      children: [
                        const Icon(Icons.notifications, color: Colors.white),
                        if (noti.hasNew)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 96, 137, 208),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: IndexedStack(index: _index, children: _pages),
      ),
      bottomNavigationBar: Container(
        height: 70,
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 27, 123, 202),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildBottomIcon(Icons.message, "Messages", 0),
            const SizedBox(width: 30),
            _buildBottomIcon(Icons.people, "Friends", 1),
            const SizedBox(width: 30),
            _buildBottomIcon(Icons.person, "Profile", 2),
            const SizedBox(width: 30),
            _buildBottomIcon(Icons.newspaper, "News Feed", 3),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomIcon(IconData icon, String label, int index) {
    final bool isSelected = _index == index;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          style: IconButton.styleFrom(
            backgroundColor:
                isSelected ? Colors.blueAccent : Colors.transparent,
          ),
          onPressed: () {
            setState(() {
              _index = index;
              _state = label;
            });
          },
          icon: Icon(icon, color: Colors.white),
        ),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}
