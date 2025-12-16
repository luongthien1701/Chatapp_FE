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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<NewsfeedProvider>(context, listen: false);
      userId=context.read<UserProvider>().userId;
      await provider.fetchNewsfeed(userId);

      setState(() {
        isLike = List.generate(provider.newsfeed.length, (_) => false);
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<NewsfeedProvider>(
        builder: (context, provider, _)
        {
        final posts = provider.newsfeed;
        print(posts.length);
        return  Center(
          child: ListView.builder(
            itemCount: posts.length,
            itemBuilder: (_, index)
            { 
              return Card(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    const SizedBox(height: 20),
        
                    // Avatar + Name + Time
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 1),
                            shape: BoxShape.circle,
                          ),
                          child: const CircleAvatar(
                            radius: 30,
                            backgroundImage:
                                AssetImage("assets/image/avatar_default.png"),
                          ),
                        ),
                        const SizedBox(width: 10),
        
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              posts[index].senderId.name,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              DateTime.fromMillisecondsSinceEpoch(posts[index].createdAt).toString().substring(10,16),
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
        
                    const SizedBox(height: 12),
        
                   Text(
                      posts[index].content,
                      style: TextStyle(fontSize: 16),
                    ),
        
                    const SizedBox(height: 12),
        
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30.0),
                      child: Image.asset(
                        "assets/image/demo_backrgound.jpg",
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
        
                    const SizedBox(height: 10),
        
                    // Like + Comment Actions
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              isLike[index] = !isLike[index];
                            });
                          },
                          icon: Icon(
                            isLike[index]
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isLike[index] ? Colors.red : Colors.black,
                          ),
                        ),
                        Text(posts[index].favorite.toString()),
        
                        IconButton(
                          onPressed: () => _openCommentDialog(context,postId:posts[index].Id),
                          icon: const Icon(Icons.comment),
                        ),
                        Text(posts[index].comments.toString()),
                      ],
                    ),
                  ],
                ),
              ),
            );
            }
          ),
        );
        }
      ),
    );
  }

  void _openCommentDialog(BuildContext context, {required int postId}) {
  final commentProvider =
      Provider.of<CommentProvider>(context, listen: false);

  commentProvider.fetchComments(postId);

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
                  style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              Expanded(
                child: Consumer<CommentProvider>(
                  builder: (_, provider, __) {
                    if (provider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    return ListView.builder(
                      itemCount: provider.comments.length,
                      itemBuilder: (_, index) {
                        final comment = provider.comments[index];
                        return ListTile(
                          leading: const CircleAvatar(
                            backgroundImage: AssetImage(
                                "assets/image/avatar_default.png"),
                          ),
                          title: Text(comment.sender.name),
                          subtitle: Text(comment.content),
                        );
                      },
                    );
                  },
                ),
              ),

              // Input comment
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    const Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Write a comment...",
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      );
    },
  );
}


}
