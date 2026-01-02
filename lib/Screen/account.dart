import 'dart:io';
import 'package:rela/model/message.dart';
import 'package:rela/model/newfeed.dart';
import 'package:rela/provider/account_provider.dart';
import 'package:rela/provider/comment_provider.dart';
import 'package:rela/provider/newsfeed_provider.dart';
import 'package:rela/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

enum AccountAction { none, updateInfo, changePassword }

class Account extends StatefulWidget {
  final int friendId; // 0 = profile của mình
  const Account({super.key, required this.friendId});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  final ImagePicker _picker = ImagePicker();
  File? _image;

  AccountAction _currentAction = AccountAction.none;
  late int userId;
  late String name;

  // ===== Controllers =====
  final _displayNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  final _oldPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _rePasswordCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      userId = context.read<UserProvider>().userId;
      name = context.read<UserProvider>().getDisplayname;
      await context.read<AccountProvider>().loadProfile(
        userId,
        widget.friendId,
      );

      await context.read<NewsfeedProvider>().fetchNewsfeedByUserId(
        widget.friendId == 0 ? userId : widget.friendId,
      );

      final profile = context.read<AccountProvider>().profile;
      _displayNameCtrl.text = profile?.displayName ?? "";
      _emailCtrl.text = profile?.email ?? "";
      _phoneCtrl.text = profile?.phone ?? "";
    });
  }

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  String timeago(int milisec) {
    final now = DateTime.now();
    final postTime = DateTime.fromMillisecondsSinceEpoch(milisec);
    final diff = now.difference(postTime);
    if (diff.inMinutes < 1) return "${diff.inSeconds} giây trước";
    if (diff.inHours < 1) return "${diff.inMinutes} phút trước";
    if (diff.inDays < 1) return "${diff.inHours} giờ trước";
    return "${diff.inDays} ngày trước";
  }

  @override
  Widget build(BuildContext context) {
    final accountProvider = context.watch<AccountProvider>();

    if (accountProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: CustomScrollView(
        slivers: [
          /// ===== PROFILE HEADER =====
          SliverToBoxAdapter(child: _buildProfileHeader(accountProvider)),

          /// ===== POSTS =====
          Consumer<NewsfeedProvider>(
            builder: (_, feedProvider, __) {
              final posts = feedProvider.newsfeed;

              if (posts.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text("Chưa có bài viết")),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return _buildPostCard(posts[index]);
                }, childCount: posts.length),
              );
            },
          ),
        ],
      ),
    );
  }

  // ================= PROFILE HEADER =================

  Widget _buildProfileHeader(AccountProvider provider) {
    return Column(
      children: [
        const SizedBox(height: 20),

        GestureDetector(
          onTap: provider.isMe
              ? () async {
                  await _pickImage();
                  await context.read<UserProvider>().updateAvatar(_image!);
                }
              : null,
          child: CircleAvatar(
            radius: 45,
            backgroundImage: _image != null
                ? FileImage(_image!)
                : const AssetImage("assets/image/avatar_default.png")
                      as ImageProvider,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          provider.displayname,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        /// ===== ACTION BUTTONS (CHỈ OWNER) =====
        if (provider.isMe)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _actionButton("Cập nhật", AccountAction.updateInfo),
              const SizedBox(width: 10),
              _actionButton("Đổi mật khẩu", AccountAction.changePassword),
            ],
          ),

        const SizedBox(height: 10),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildActionForm(),
        ),

        const Divider(thickness: 2),
      ],
    );
  }

  Widget _actionButton(String title, AccountAction action) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _currentAction = _currentAction == action
              ? AccountAction.none
              : action;
        });
      },
      child: Text(title),
    );
  }

  // ================= FORMS =================

  Widget _buildActionForm() {
    switch (_currentAction) {
      case AccountAction.updateInfo:
        return _buildUpdateInfoForm();
      case AccountAction.changePassword:
        return _buildChangePasswordForm();
      default:
        return const SizedBox();
    }
  }

  Widget _buildUpdateInfoForm() {
    return Column(
      key: const ValueKey("updateInfo"),
      children: [
        _textField("Tên hiển thị", _displayNameCtrl),
        _textField("Email", _emailCtrl),
        _textField("Số điện thoại", _phoneCtrl),
        ElevatedButton(
          onPressed: () {
            // TODO: gọi API update info
          },
          child: const Text("Lưu thay đổi"),
        ),
      ],
    );
  }

  Widget _buildChangePasswordForm() {
    return Column(
      key: const ValueKey("changePassword"),
      children: [
        _textField("Mật khẩu cũ", _oldPasswordCtrl, obscure: true),
        _textField("Mật khẩu mới", _newPasswordCtrl, obscure: true),
        _textField("Nhập lại mật khẩu", _rePasswordCtrl, obscure: true),
        ElevatedButton(
          onPressed: () {
            // TODO: gọi API đổi mật khẩu
          },
          child: const Text("Đổi mật khẩu"),
        ),
      ],
    );
  }

  Widget _textField(
    String label,
    TextEditingController controller, {
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  // ================= POST CARD =================

  Widget _buildPostCard(NewfeedDTO post) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 25,
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
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      timeago(post.createdAt),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                Spacer(),
                Visibility(
                  visible: widget.friendId == 0,
                  child: IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Xác nhận xóa bài viết"),
                          content: const Text(
                            "Bạn có chắc chắn muốn xóa bài viết này không?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Hủy"),
                            ),
                            TextButton(
                              onPressed: () {
                                context.read<NewsfeedProvider>().deletePost(
                                  post.id,
                                );
                                Navigator.pop(context);
                              },
                              child: const Text("Xóa"),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: Icon(Icons.delete),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(post.content),

            const SizedBox(height: 12),

            if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
              Column(
                children: post.imageUrl!.map((imageUrl) {
                  return GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          child: Hero(
                            tag: post.id,
                            child: Image.network(imageUrl),
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Hero(tag: post.id, child: Image.network(imageUrl)),
                    ),
                  );
                }).toList(),
              ),
            Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    post.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: post.isFavorite ? Colors.red : Colors.black,
                  ),
                ),
                Text(post.favorite.toString()),

                IconButton(
                  onPressed: () => _openCommentDialog(context, postId: post.id),
                  icon: const Icon(Icons.comment),
                ),
                Text(post.comments.toString()),
              ],
            ),
          ],
        ),
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
                              avatarUrl: "",
                              id: userId,
                              name: name,
                            );
                            commentProvider.addComment(postId, sender, content);
                            commentController.clear();
                            context.read<NewsfeedProvider>().increaseComment(
                              postId,
                            );
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
}
