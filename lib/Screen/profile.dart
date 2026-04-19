import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rela/Screen/account.dart';
import 'package:rela/Screen/login.dart';
import 'package:rela/Service/profile_service.dart';
import 'package:rela/Service/socket_service.dart';
import 'package:rela/model/message.dart';
import 'package:rela/provider/locate_provider.dart';
import 'package:rela/provider/theme_provider.dart';
import 'package:rela/provider/user_provider.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _Profile();
}

class _Profile extends State<Profile> {
  String name = "";
  final ProfileService profileService = ProfileService();
  late final int _userId;
  late Color color;

  @override
  void initState() {
    super.initState();
    color = context.read<ThemeProvider>().lightTheme;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _userId = context.read<UserProvider>().userId;
      SenderInfo user = await profileService.getProfile(_userId);
      setState(() {
        name = user.name ?? "Ẩn danh";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color,
      body: Column(
        children: [
          const SizedBox(height: 20),
          const CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage("assets/image/avatar_default.png"),
          ),
          const SizedBox(height: 10),
          Text(name),

          const SizedBox(height: 40),

          _item(
            icon: Icons.person_2_rounded,
            text: "Accounts",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const Account(friendId: 0),
                ),
              );
            },
          ),

          _divider(),

          _item(
            icon: Icons.sunny,
            text: "Theme",
            onTap: () {
              context.read<ThemeProvider>().changeTheme();
            },
          ),

          _divider(),

          Consumer<LocateProvider>(
            builder: (_, locate, __) => Row(
              children: [
                Switch.adaptive(
                  value: locate.isFindme,
                  onChanged: (_) {
                    if (locate.isUpdating) {
                      const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    context.read<LocateProvider>().toggleFindMe(_userId);
                  },
                ),
                const Text("Find me"),
              ],
            ),
          ),

          _divider(),

          _item(
            icon: Icons.logout,
            text: "Log Out",
            onTap: () {
              SocketService().disconnect();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(color: Colors.black26, thickness: 2);

  Widget _item(
      {required IconData icon,
      required String text,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          IconButton(onPressed: null, icon: Icon(icon)),
          Text(text),
        ],
      ),
    );
  }
}
