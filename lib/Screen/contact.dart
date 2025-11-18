import 'package:chatapp/Screen/account.dart';
import 'package:chatapp/provider/contact_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Contact extends StatefulWidget {
  final int userId;
  const Contact({super.key, required this.userId});

  @override
  State<Contact> createState() => _Contact();
}

class _Contact extends State<Contact> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        context.read<FriendProvider>().fetchListFriend(widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FriendProvider>();
    final list = provider.list;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 152, 209, 255),
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
                      MaterialPageRoute(
                        builder: (context) => Account(
                          userId: widget.userId,
                          friendId: list[index].friendId,
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
