import 'dart:io';

import 'package:rela/model/notification.dart';
import 'package:rela/provider/call_provider.dart';
import 'package:rela/provider/contact_provider.dart';
import 'package:rela/provider/notification_provider.dart';
import 'package:rela/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rela/model/message.dart';
import 'package:rela/provider/convervasion_provider.dart';

class Conversation extends StatefulWidget {
  final int convervationid;

  const Conversation({super.key, required this.convervationid});

  @override
  State<Conversation> createState() => _ConversationState();
}

class _ConversationState extends State<Conversation> {
  final TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final ConversationProvider provider;
  late final int userId;
  late final int friendId;
  File? file;
  final ImagePicker imagePicker = ImagePicker();
  @override
  void initState() {
    super.initState();
    provider = context.read<ConversationProvider>();
    userId = context.read<UserProvider>().userId;
    provider.loadRoomInfo(widget.convervationid);
    provider.loadMemberIds(widget.convervationid).then((_) {
      setState(() {
        friendId = provider.memberIds
            .firstWhere((id) => id != userId, orElse: () => 0);
      });
    });
    provider.loadMessages(userId, widget.convervationid).then((_) {
      Future.delayed(const Duration(seconds: 1));
      _scrollToBottom();
    });
    provider.joinRoom(userId, widget.convervationid);
    provider.listenMessages(
      userId,
      onNewMessage: _scrollToBottom, // ✅ thêm dòng này
    );
  }

  @override
  void dispose() {
    provider.leaveRoom(userId, widget.convervationid);
    messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final XFile? img = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (img != null) {
      setState(() {
        file = File(img.path);
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(seconds: 1),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = context.watch<ConversationProvider>().messages;
    final room = context.watch<ConversationProvider>().room;
    final call = context.watch<CallProvider>();
    final noti = context.read<NotificationProvider>();
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 6, 91, 238),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 6, 91, 238),
        leading: BackButton(
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await call.startCall(widget.convervationid, userId);
            },
            icon: const Icon(Icons.call, color: Colors.white),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.videocam, color: Colors.white),
          ),
          GestureDetector(
            onTapDown: (d) {
              final position = d.globalPosition;
              showMenu(
                  context: context,
                  position: RelativeRect.fromLTRB(
                      position.dx, position.dy + 30, position.dx, position.dy),
                  items: [
                    PopupMenuItem(
                      enabled: false,
                      child: SizedBox(
                        height: 100,
                        width: 130,
                        child: ListView(
                          children: [
                            ListTile(
                              leading: const Icon(
                                Icons.add,
                                color: Colors.black,
                              ),
                              title: const Text(
                                "ADD PERSON",
                                style: TextStyle(color: Colors.black),
                              ),
                              onTap: () {
                                _openlistfriend(context);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]);
            },
            child: IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onPressed: () {},
            ),
          ),
        ],
        title: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundImage: NetworkImage(
                room?.avatarUrl ??
                    "https://www.pngall.com/wp-content/uploads/5/User-Profile-PNG-High-Quality-Image.png",
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                _openChange(context);
              },
              child: Text(
                room?.name ?? "Chat",
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 124, 207, 245),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[messages.length - 1 - index];
                    return Align(
                      alignment: msg.isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: msg.isMe
                              ? const Color.fromARGB(255, 15, 84, 203)
                              : const Color.fromARGB(255, 93, 167, 227),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: msg.fileUrl != null
                            ? GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => Dialog(
                                      child: Hero(
                                        tag: msg.id,
                                        child: Image.network(
                                          "https://www.pngall.com/wp-content/uploads/5/User-Profile-PNG-High-Quality-Image.png",
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                child: Hero(
                                  tag: msg.id,
                                  child: Image.network(
                                    "https://www.pngall.com/wp-content/uploads/5/User-Profile-PNG-High-Quality-Image.png",
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            : Text(
                                msg.content,
                                style: const TextStyle(fontSize: 16),
                              ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Wrap(
              children: [
                if (file != null)
                  Stack(
                    children: [
                      Image.file(
                        file!,
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        right: -10,
                        top: -10,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              file = null;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            Container(
              color: const Color.fromARGB(255, 124, 207, 245),
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      decoration: InputDecoration(
                        hintText: "Nhập tin nhắn...",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: () {
                      pickImage();
                    },
                    icon: const Icon(Icons.photo),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () async {
                      String url = "";
                      if (file != null) {
                        url = await provider.upImageMessages(
                          file!,
                          widget.convervationid,
                        );
                      }
                      if (messageController.text.isEmpty && url.isNotEmpty) {
                        final msg = MessageSend(
                            chatRoomId: widget.convervationid,
                            senderId: userId,
                            content: messageController.text,
                            fileUrl: url,
                            type: MessageType.image);
                        debugPrint("Sending message: ${msg.toJson()}");
                        provider.sendMessage(msg);
                        messageController.clear();
                        setState(() {
                          file = null;
                        });
                        _scrollToBottom();
                      } else if (messageController.text.isNotEmpty &&
                          url.isEmpty) {
                        final msg = MessageSend(
                            chatRoomId: widget.convervationid,
                            senderId: userId,
                            content: messageController.text,
                            fileUrl: null,
                            type: MessageType.text);
                        debugPrint("Sending message: ${msg.toJson()}");
                        provider.sendMessage(msg);
                        NotiDTO notification = NotiDTO(
                            createdAt: 0,
                            receiverId: friendId,
                            senderId:
                                SenderInfo(id: userId, name: "", avatarUrl: ""),
                            status: false,
                            title: "",
                            type: "message");
                        noti.sendNotification(notification);
                        messageController.clear();
                        _scrollToBottom();
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
  }

  void _openChange(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: const SizedBox(
              height: 100,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      "Change name",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(hintText: "Nhập tên để đổi"),
                      ),
                    ),
                    IconButton(onPressed: null, icon: Icon(Icons.done, size: 30, fontWeight: FontWeight.bold,))
                  ])
                ],
              ),
            ),
          );
        });
  }

  void _openlistfriend(BuildContext context) {
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
                    "Add member",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Consumer2<FriendProvider, ConversationProvider>(
                    builder: (_, friendProvider, convoProvider, __) {
                      if (friendProvider.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (friendProvider.list.isEmpty)
                        friendProvider.fetchListFriend(userId);
                      final memberIdSet = convoProvider.memberIds.toSet();

                      final friendsNotInGroup = friendProvider.list
                          .where((fr) => !memberIdSet.contains(fr.id))
                          .toList();
                      if (friendsNotInGroup.isEmpty) {
                        return const Center(
                          child: Text("No friends to add"),
                        );
                      }

                      return ListView.builder(
                        itemCount: friendsNotInGroup.length,
                        itemBuilder: (_, index) {
                          final fr = friendsNotInGroup[index];
                          if (fr.friendId == userId) {
                            return const SizedBox.shrink();
                          }
                          return ListTile(
                            leading: const CircleAvatar(
                              backgroundImage: AssetImage(
                                "assets/image/avatar_default.png",
                              ),
                            ),
                            title: Text(fr.displayname),
                            trailing: IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                if (convoProvider.isLoading) return;
                                convoProvider.addUserInRoom(
                                    widget.convervationid, fr.friendId);
                                showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                          content:
                                              const Text("Added successfully"),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text("OK"),
                                            ),
                                          ],
                                        ));
                              },
                            ),
                          );
                        },
                      );
                    },
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
