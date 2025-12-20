import 'package:chatapp/Screen/newfeed.dart';
import 'package:chatapp/Service/socket_service.dart';
import 'package:chatapp/provider/newsfeed_provider.dart';
import 'package:chatapp/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/notification_provider.dart';
import '../Screen/account.dart';
import '../Screen/contact.dart';
import '../Screen/mess_list.dart';
import '../Screen/profile.dart';
import '../Screen/search.dart';

class Hub extends StatefulWidget {
  const Hub({super.key});

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
    final userId=context.read<UserProvider>().userId;
    SocketService().connect(userId);
    _pages = [
      MessList(),
      Contact(),
      Profile(),
      Newfeed(),
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
        title: Text(_state, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 27, 92, 203),
        actions: [
          if (_index != 2 && _index != 3)
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Check(),
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

      body: IndexedStack(index: _index, children: _pages),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        height: 70,
        backgroundColor: const Color.fromARGB(255, 27, 123, 202),
        indicatorColor: Colors.white.withOpacity(0.3),
        onDestinationSelected: (i) async {
          setState(() {
            _index = i;
            _state = ["Messages", "Friends", "Profile", "News Feed"][i];
          });
           if (i == 3) {
          final userId = context.read<UserProvider>().userId;
          await context.read<NewsfeedProvider>().fetchNewsfeed(userId);
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.message_outlined),
            selectedIcon: Icon(Icons.message, color: Colors.white),
            label: "Messages",
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people, color: Colors.white),
            label: "Friends",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: Colors.white),
            label: "Profile",
          ),
          NavigationDestination(
            icon: Icon(Icons.newspaper_outlined),
            selectedIcon: Icon(Icons.newspaper, color: Colors.white),
            label: "News Feed",
          ),
        ],
      ),
    );
  }
}
