import 'dart:io';

import 'package:chatapp/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:chatapp/model/message.dart';
import 'package:chatapp/provider/convervasion_provider.dart';

class Conversation extends StatefulWidget {
  final int convervationid;

  const Conversation({
    super.key,
    required this.convervationid,
  });

  @override
  State<Conversation> createState() => _ConversationState();
}

class _ConversationState extends State<Conversation> {
  final TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final ConversationProvider provider;
  late final int userId;
  File? file;
  final ImagePicker imagePicker=ImagePicker();
  @override
  void initState() {
    super.initState();
    provider = context.read<ConversationProvider>();
    userId=context.read<UserProvider>().userId;
    provider.loadRoomInfo(widget.convervationid);
    provider.loadMessages(userId, widget.convervationid).then((_) {
      _scrollToBottom();
    });
    provider.joinRoom(userId, widget.convervationid);
    provider.listenMessages(userId);
  }

  @override
  void dispose() {
    provider.leaveRoom(userId, widget.convervationid); 
    super.dispose();
  }
  Future<void> pickImage() async
  {
    final XFile? img=await imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (img!=null)
    {
      setState(() {
        file=File(img.path);
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = context.watch<ConversationProvider>().messages;
    final room = context.watch<ConversationProvider>().room;

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
            Text(
              room?.name ?? "Chat",
              style: const TextStyle(color: Colors.white, fontSize: 18),
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
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
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
                        child: msg.fileUrl!=null ? 
                        GestureDetector(
                          onTap: () {
                            showDialog(context: context,
                             builder: (context) => Dialog(
                              child: Hero(
                                tag: msg.id,
                                child: Image.network(
                                  "http://localhost:8080"+msg.fileUrl!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                             ),
                          );
                          },
                          child: Hero(
                            tag: msg.id,
                            child: Image.network(
                              "http://localhost:8080"+msg.fileUrl!,
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )   
                        : 
                        Text(
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
                  IconButton(onPressed: () {
                    pickImage();
                  }, 
                  icon: Icon(Icons.photo)),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: ()  async {
                      String url=await provider.upImageMessages(file!, widget.convervationid);
                      if (messageController.text.trim().isEmpty && (url.isEmpty && file != null)) return;
                      final msg = MessageSend(
                        chatRoomId: widget.convervationid,
                        senderId: userId,
                        content: messageController.text,
                        fileUrl: url,
                        type: url.isNotEmpty ? MessageType.IMAGE : MessageType.TEXT
                      );
                      debugPrint("Sending message: ${msg.toJson()}");
                      provider.sendMessage(msg);
                      messageController.clear();
                      _scrollToBottom();
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
}
