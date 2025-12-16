import 'dart:io';
import 'package:chatapp/Screen/conversation.dart';
import 'package:chatapp/Service/socket_service.dart';
import 'package:chatapp/model/notification.dart';
import 'package:chatapp/model/message.dart';
import 'package:chatapp/provider/account_provider.dart';
import 'package:chatapp/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';


class Account extends StatefulWidget {
  final int friendId;
  const Account({super.key, required this.friendId});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  final TextEditingController _displayname = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _oldpassword = TextEditingController();
  final TextEditingController _newpassword = TextEditingController();
  final TextEditingController _repassword = TextEditingController();

  final payload = {"event": "", "data": {}};
  final ImagePicker _picker = ImagePicker();
  File? _image;
  bool check = false;
  bool changepassword = false;
  bool _initialized = false;
  late final int userId;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        userId=context.read<UserProvider>().userId;
        context.read<AccountProvider>().loadProfile(userId, widget.friendId);
      });
      _initialized = true;
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AccountProvider>();

    if (provider.isLoading) {
      return const Scaffold(
        backgroundColor: Color.fromARGB(255, 152, 209, 255),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 152, 209, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 152, 209, 255),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {
              showMenu(
                context: context,
                position: const RelativeRect.fromLTRB(200, 40, 0, 0),
                items: [
                  PopupMenuItem(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            // TODO: chặn người dùng
                          },
                          child: SizedBox(
                            width: 150,
                            child: Row(
                              children: const [
                                Icon(Icons.block, size: 16),
                                SizedBox(width: 10),
                                Flexible(child: Text("Chặn người dùng")),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Visibility(
                          visible: provider.status == "ACCEPTED",
                          child: GestureDetector(
                            onTap: () {
                              provider.deleteFriend(userId, widget.friendId);
                            },
                            child: SizedBox(
                              width: 150,
                              child: Row(
                                children: const [
                                  Icon(Icons.person, size: 16),
                                  SizedBox(width: 10),
                                  Flexible(child: Text("Xóa kết bạn")),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              );
            },
          ),
        ],
      ),
      body: provider.isMe ? _buildOwner(provider) : _buildGuest(provider),
    );
  }

  // --------------------------- OWNER PROFILE ---------------------------
  Widget _buildOwner(AccountProvider provider) {
    _displayname.text = provider.profile?.displayName ?? "";
    _email.text = provider.profile?.email ?? "";
    _phone.text = provider.profile?.phone ?? "";

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 30),
          GestureDetector(
            onTap: _pickImage,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: _image != null
                      ? FileImage(_image!)
                      : const AssetImage("assets/image/avatar_default.png")
                          as ImageProvider,
                ),
                const Icon(Icons.camera_alt, size: 50, color: Color.fromARGB(255, 197, 192, 192)),
              ],
            ),
          ),
          Text(provider.displayname, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 50),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: check ? Colors.blue : Colors.white),
                onPressed: () {
                  setState(() {
                    check = !check;
                    changepassword = false;
                  });
                },
                child: const Text("Cập nhật"),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: changepassword ? Colors.blue : Colors.white),
                onPressed: () {
                  setState(() {
                    changepassword = !changepassword;
                    check = false;
                  });
                },
                child: const Text("Đổi mật khẩu"),
              ),
            ],
          ),
          const SizedBox(height: 30),

          Expanded(
            child: Stack(
              children: [
                AnimatedOpacity(
                  opacity: changepassword ? 0 : 1,
                  duration: const Duration(milliseconds: 500),
                  child: Visibility(visible: !changepassword, child: _buildInfoForm()),
                ),
                AnimatedOpacity(
                  opacity: changepassword ? 1 : 0,
                  duration: const Duration(milliseconds: 500),
                  child: Visibility(visible: changepassword, child: _buildChangePasswordForm()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoForm() {
    return Column(
      children: [
        _textField("Username", _displayname, readOnly: !check),
        _divider(),
        _textField("Email", _email, readOnly: !check),
        _divider(),
        _textField("Phone", _phone, readOnly: !check),
        AnimatedOpacity(
          opacity: check ? 1 : 0,
          duration: const Duration(milliseconds: 400),
          child: ElevatedButton(
            onPressed: () {
              // TODO: gọi API cập nhật thông tin
            },
            child: const Text("Xác nhận"),
          ),
        ),
      ],
    );
  }

  Widget _buildChangePasswordForm() {
    return Column(
      children: [
        _textField("Mật khẩu cũ", _oldpassword, obscure: true),
        _divider(),
        _textField("Mật khẩu mới", _newpassword, obscure: true),
        _divider(),
        _textField("Nhập lại mật khẩu", _repassword, obscure: true),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () {
            // TODO: gọi API đổi mật khẩu
          },
          child: const Text("Xác nhận đổi mật khẩu"),
        ),
      ],
    );
  }

  Widget _textField(String label, TextEditingController controller, {bool readOnly = false, bool obscure = false}) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }

  Widget _divider() => const Divider(color: Colors.black38, thickness: 2);

  // --------------------------- FRIEND PROFILE ---------------------------
  Widget _buildGuest(AccountProvider provider) {
    return Column(
      children: [
        const SizedBox(height: 30),
        const CircleAvatar(
          radius: 40,
          backgroundImage: AssetImage("assets/image/avatar_default.png"),
        ),
        const SizedBox(height: 20),
        Text(provider.displayname, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (provider.status == "NONE")
              ElevatedButton(
                onPressed: () {
                  provider.addFriend(userId, widget.friendId);
                  final notification = NotiDTO(
                    title: "đã gửi lời mời kết bạn",
                    senderId: SenderInfo(id: userId, name: provider.displayname, avatarUrl: ""),
                    receiverId: widget.friendId,
                    status: false,
                    createdAt: DateTime.now().millisecondsSinceEpoch,
                  );
                  payload["event"] = "notification";
                  payload["data"] = notification.toJson();
                  SocketService().sendMessage(payload);
                },
                child: const Text("Kết bạn"),
              ),
            if (provider.status == "PENDING")
              ElevatedButton(
                onPressed: () => provider.deleteFriend(userId, widget.friendId),
                child: const Text("Đã gửi lời mời"),
              ),
            if (provider.status == "RECEIVED")
              ElevatedButton(
                onPressed: () => provider.acceptFriend(userId, widget.friendId),
                child: const Text("Chấp nhận"),
              ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () async {
                final id = await provider.findRoom(userId, widget.friendId);
                if (!mounted) return;
                Navigator.push(context, MaterialPageRoute(builder: (context) => Conversation(convervationid: id)));
              },
              child: const Text("Gửi tin nhắn"),
            ),
          ],
        ),
      ],
    );
  }
}
