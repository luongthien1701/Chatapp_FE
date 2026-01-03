import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:rela/Screen/newfeed.dart';
import 'package:rela/Service/notification_service.dart';
import 'package:rela/Service/socket_service.dart';
import 'package:rela/provider/call_provider.dart';
import 'package:rela/provider/contact_provider.dart';
import 'package:rela/provider/newsfeed_provider.dart';
import 'package:rela/provider/theme_provider.dart';
import 'package:rela/provider/user_provider.dart';
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

  String _state = "News Feed";
  late List<Widget> _pages;
  late int userId;
  @override
  void initState() {
    super.initState();
    userId = context.read<UserProvider>().userId;
    _initFCM();
    final socket = SocketService();
    socket.connect(userId);

    socket.messages.listen((data) {
      final msg = jsonDecode(data);

      switch (msg['event']) {
        case 'notification':
          context.read<NotificationProvider>().onReceive(msg);
          break;

        case 'call_comming':
          context.read<CallProvider>().onReceived(msg);
          break;

        // sau này thêm:
        // case 'chat_message':
        //   context.read<MessageProvider>().onReceive(msg);
        //   break;
      }
    });

    _pages = const [
      Newfeed(),
      MessList(),
      Contact(),
      Profile(),
    ];
  }

  @override
  void dispose() {
    SocketService().disconnect();
    super.dispose();
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

  Future<void> _initFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();
    if (token != null) {
      await NotificationService.sendTokenToServer(userId, token);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.watch<ThemeProvider>().currentTheme,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(_state, style: const TextStyle(color: Colors.white)),
        backgroundColor: context.watch<ThemeProvider>().currentTheme,
        actions: [
          if (_index != 0 && _index != 3)
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => const Check(),
                        transitionDuration: const Duration(milliseconds: 500),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
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
                        if (context.watch<NotificationProvider>().hasNew)
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
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOut),
            ),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        child: _pages[_index],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        height: 70,
        backgroundColor: context.watch<ThemeProvider>().currentTheme,
        indicatorColor: Colors.white.withValues(alpha: 0.3),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
        ),
        onDestinationSelected: (i) {
          setState(() {
            _index = i;
            _state = ["News Feed", "Messages", "Friends", "Profile"][i];
          });
          if (i == 0) {
            context.read<NewsfeedProvider>().fetchNewsfeed(userId);
          }
          if (i == 2) {
            context.read<FriendProvider>().fetchListFriend(userId);
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.newspaper_outlined),
            selectedIcon: Icon(Icons.newspaper, color: Colors.white),
            label: "News Feed",
          ),
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
        ],
      ),
    );
  }
}
