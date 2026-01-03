import 'package:rela/Screen/account.dart';
import 'package:rela/model/message.dart';
import 'package:provider/provider.dart';
import 'package:rela/Screen/login.dart';
import 'package:rela/Service/profile_service.dart';
import 'package:rela/provider/theme_provider.dart';
import 'package:rela/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:rela/Service/socket_service.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _Profile();
}

class _Profile extends State<Profile> {
  String name = "";
  ProfileService profileService = ProfileService();
  late final int _userId;
  late Color color;
  @override
  void initState() {
    super.initState();
    color = context.read<ThemeProvider>().lightTheme;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _userId = context.read<UserProvider>().userId;
      loaddata();
    });
  }

  void loaddata() async {
    SenderInfo user = await profileService.getProfile(_userId);
    name = user.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color,
      body: Column(
        children: [
          SizedBox(
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                const CircleAvatar(
                  radius: 30,
                  backgroundImage:
                      AssetImage("assets/image/avatar_default.png"),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(name),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                const SizedBox(
                  height: 50,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 500),
                          pageBuilder: (_, __, ___) =>
                              const Account(friendId: 0),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) =>
                                  FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        ));
                  },
                  child: const Row(
                    children: [
                      IconButton(
                          onPressed: null,
                          icon: Icon(
                            Icons.person_2_rounded,
                            size: 20,
                            color: Colors.black,
                          )),
                      Text("Accounts"),
                    ],
                  ),
                ),
                const Divider(
                  color: Colors.black26,
                  thickness: 2,
                  height: 5,
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          context.read<ThemeProvider>().changeTheme();
                        },
                        icon: const Icon(
                          Icons.sunny,
                          size: 20,
                          color: Colors.black,
                        )),
                    const Text("Theme")
                  ],
                ),
                const Divider(
                  color: Colors.black26,
                  thickness: 2,
                  height: 5,
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          SocketService().disconnect();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ));
                        },
                        icon: const Icon(
                          Icons.logout,
                          size: 20,
                          color: Colors.black,
                        )),
                    const Text("Log Out")
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
