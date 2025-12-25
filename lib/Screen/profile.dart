import 'package:chatapp/Screen/account.dart';
import 'package:chatapp/model/message.dart';
import 'package:provider/provider.dart';
import 'package:chatapp/Screen/login.dart';
import 'package:chatapp/Service/profile_service.dart';
import 'package:chatapp/provider/user_provider.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _Profile();
}

class _Profile extends State<Profile> {
  String name="";
  ProfileService profileService =ProfileService();
  late final int _userId;
  @override
  void initState()
  {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
    _userId=context.read<UserProvider>().userId;
    loaddata();
    });
  }
  void loaddata() async
  {
    SenderInfo user=await profileService.getProfile(_userId);
    name=user.name;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 152, 209, 255),
       body: Column(
        children: [
          SizedBox(
            child: Column(
              children: [
                SizedBox(height: 10,),
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage("assets/image/avatar_default.png"),
                ),
                SizedBox(height: 10,),
                Text(name),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                SizedBox(height: 50,),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Account(friendId: 0)));
                  },
                  child: Row(
                    children: [
                      IconButton(onPressed: null, icon: Icon(Icons.person_2_rounded,size: 20,)),
                      Text("Accounts"),
                    ],),
                ),
                Divider(color: Colors.black26,thickness: 2,height: 5,),
                SizedBox(height: 20,),
                Row(
                  children: [
                    IconButton(onPressed: null, icon: Icon(Icons.sunny,size: 20,)),
                    Text("Theme")
                  ],
                ),
                Divider(color: Colors.black26,thickness: 2,height: 5,),
                SizedBox(height: 20,),
                Row(
                  children: [
                    IconButton(onPressed: ()
                    {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage(),));
                    }, icon: Icon(Icons.logout,size: 20,)),
                    Text("Log Out")
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