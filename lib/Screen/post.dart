import 'dart:io';

import 'package:rela/model/message.dart';
import 'package:rela/provider/newsfeed_provider.dart';
import 'package:rela/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class Post extends StatefulWidget {
  const Post({super.key});

  @override
  State<Post> createState() => _Post();
}

class _Post extends State<Post> {
  late final int id;
  late final String name;
  late final String avatarUrl;
  TextEditingController content=TextEditingController();
  List<File> images = [];
  final ImagePicker _picker = ImagePicker();
  @override
  void initState() {
    super.initState();
    id = context.read<UserProvider>().userId;
    name = context.read<UserProvider>().getDisplayname;
    avatarUrl = context.read<UserProvider>().getAvatarUrl;
  }
  Future<void> _pickImg() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        print(pickedFile.path);
        images.add(File(pickedFile.path));
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    final provider = context.read<NewsfeedProvider>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // HEADER
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            "Create Post",
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),

        const Divider(),

        ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(avatarUrl),
          ),
          title: Text(name),
        ),

        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: content,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: "What's on your mind?",
              border: OutlineInputBorder(),
            ),
          ),
        ),

        Wrap(
          spacing: 10,
          children: images
              .map((img) => ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      img,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ))
              .toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(icon: const Icon(Icons.photo), onPressed: () {
              _pickImg();
            }),
            IconButton(icon: const Icon(Icons.tag_faces), onPressed: () {}),
          ],
        ),

        const SizedBox(height: 12),

        ElevatedButton(
          onPressed: () async {
            int postid= await provider.createPost(SenderInfo(id: id, name: name,avatarUrl: avatarUrl ), content.text);
            await provider.upLoadImagePost(images, postid);
            Navigator.pop(context);
          },
          child: const Text("Post"),
        ),

        const SizedBox(height: 16),
      ],
    );
  }
}
