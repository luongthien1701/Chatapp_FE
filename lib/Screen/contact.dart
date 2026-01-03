import 'package:rela/Screen/account.dart';
import 'package:rela/provider/contact_provider.dart';
import 'package:rela/provider/theme_provider.dart';
import 'package:rela/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Contact extends StatefulWidget {
  const Contact({super.key});

  @override
  State<Contact> createState() => _Contact();
}

class _Contact extends State<Contact> {
  late final int userId;
  late Color color;
  @override
  void initState() {
    super.initState();
    userId=context.read<UserProvider>().userId;
    color=context.read<ThemeProvider>().lightTheme;
    Future.microtask(() =>
        context.read<FriendProvider>().fetchListFriend(userId));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FriendProvider>();
    final list = provider.list;

    return Scaffold(
      backgroundColor: color,
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.person_2),
                  title: Text(list[index].displayname),
                  trailing: Text(list[index].status),
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => Account(
                          friendId: list[index].friendId,
                        ),
                        transitionDuration: const Duration(milliseconds: 500),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
