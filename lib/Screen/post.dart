import 'package:chatapp/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
class Post extends StatefulWidget {
  const Post({super.key});

  @override
  State<Post> createState() => _Post();
}

class _Post extends State<Post> {
  late final String name;
  late final String avatarUrl;
  @override
  void initState() {
    super.initState();
    name = context.read<UserProvider>().getDisplayname;
    avatarUrl = context.read<UserProvider>().getAvatarUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post',textAlign: TextAlign.center, ),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(avatarUrl),
            ),
            title: Text(name),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              maxLines: 10,
              decoration: InputDecoration(
                hintText: 'What\'s on your mind?',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.photo),
                onPressed: () {
                  // Handle photo upload
                },
              ),
              IconButton(
                icon: const Icon(Icons.tag_faces),
                onPressed: () {
                  // Handle adding emojis
                },
              ),
            ],
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Handle post submission logic here
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }
}
