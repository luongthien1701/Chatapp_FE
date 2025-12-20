import 'package:chatapp/Screen/post.dart';
import 'package:chatapp/model/message.dart';
import 'package:chatapp/provider/comment_provider.dart';
import 'package:chatapp/provider/newsfeed_provider.dart';
import 'package:chatapp/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Newfeed extends StatefulWidget {
  const Newfeed({super.key});

  @override
  State<Newfeed> createState() => _NewfeedState();
}

class _NewfeedState extends State<Newfeed> {
  List<bool> isLike = []; // mỗi post có 1 trạng thái like riêng
  List<Newfeed> posts = [];
  late final int userId;
  late String name='';
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<NewsfeedProvider>(context, listen: false);
      userId = context.read<UserProvider>().userId;
      name=context.read<UserProvider>().getDisplayname;
      await provider.fetchNewsfeed(userId);

      setState(() {
        isLike = List.generate(provider.newsfeed.length, (_) => false);
      });
    });
  }

  String timeago(int milisec) {
    final now = DateTime.now();
    final postTime = DateTime.fromMillisecondsSinceEpoch(milisec);
    final difference = now.difference(postTime);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} giây trước';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else {
      return '${difference.inDays} ngày trước';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<NewsfeedProvider>(
        builder: (context, provider, _) {
          final posts = provider.newsfeed;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                backgroundColor: Colors.blueAccent,
                expandedHeight: 30,
                pinned: false,

                flexibleSpace: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 20,
                          backgroundImage: AssetImage(
                            "assets/image/avatar_default.png",
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: TextField(
                            readOnly: true,
                            onTap: () {
                              _openUpPostDialog(context);
                            },
                            decoration: InputDecoration(
                              hintText: "$name, What's on your mind?",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              if (posts.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: Text("Không có bài viết")),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final post = posts[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Avatar + name + time
                            Row(
                              children: [
                                const CircleAvatar(
                                  radius: 30,
                                  backgroundImage: AssetImage(
                                    "assets/image/avatar_default.png",
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      post.senderId.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      timeago(post.createdAt),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            Text(post.content),

                            const SizedBox(height: 12),

                            if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
                              Column(
                                children: post.imageUrl!.map((imageUrl) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Image.network("http://localhost:8080"+imageUrl),
                                  );
                                }).toList(),
                              ),

                            const SizedBox(height: 10),

                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      provider.updatelike(post.id);
                                      if (post.isFavorite) {
                                        provider.likePost(post.id, userId);
                                      } else {
                                        provider.unlikePost(post.id, userId);
                                      }
                                    });
                                  },
                                  icon: Icon(
                                    post.isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: post.isFavorite
                                        ? Colors.red
                                        : Colors.black,
                                  ),
                                ),
                                Text(post.favorite.toString()),

                                IconButton(
                                  onPressed: () => _openCommentDialog(
                                    context,
                                    postId: post.id,
                                  ),
                                  icon: const Icon(Icons.comment),
                                ),
                                Text(post.comments.toString()),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }, childCount: posts.length),
                ),
            ],
          );
        },
      ),
    );
  }

  void _openCommentDialog(BuildContext context, {required int postId}) {
    final commentProvider = Provider.of<CommentProvider>(
      context,
      listen: false,
    );
    commentProvider.fetchComments(postId);
    final TextEditingController commentController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SizedBox(
            height: 400,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    "Comments",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),

                Expanded(
                  child: Consumer<CommentProvider>(
                    builder: (_, provider, __) {
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return ListView.builder(
                        itemCount: provider.comments.length,
                        itemBuilder: (_, index) {
                          final comment = provider.comments[index];
                          return ListTile(
                            leading: const CircleAvatar(
                              backgroundImage: AssetImage(
                                "assets/image/avatar_default.png",
                              ),
                            ),
                            title: Text(comment.sender.name),
                            subtitle: Text(comment.content),
                          );
                        },
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: commentController,
                          decoration: InputDecoration(
                            hintText: "Write a comment...",
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          final content = commentController.text;
                          if (content.isNotEmpty) {
                            final sender = SenderInfo(
                              id: userId,
                              name: name,
                              avatarUrl: "",
                            );
                            commentProvider.addComment(
                              postId,
                              sender,
                              content,
                            );
                            commentController.clear();
                            context.read<NewsfeedProvider>().increaseComment(postId);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  void _openUpPostDialog(BuildContext context) 
  {
    showDialog(context: context, 
    builder: (_) 
    {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)
        ),
        child: Post(),
      );
    }
    );
  }
}
