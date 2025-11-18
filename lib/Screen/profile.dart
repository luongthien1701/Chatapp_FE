import 'package:chatapp/Screen/account.dart';
import 'package:chatapp/Screen/login.dart';
import 'package:chatapp/Service/profile_service.dart';
import 'package:chatapp/model/userdto.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  final int userId;
  const Profile({super.key,required this.userId});

  @override
  State<Profile> createState() => _Profile();
}

class _Profile extends State<Profile> {
  String name="";
  int _userId=0;
  ProfileService profileService =ProfileService();
  @override
  void initState()
  {
    super.initState();
    _userId=widget.userId;
    loaddata();
  }
  void loaddata() async
  {
    UserDTO user=await profileService.getProfile(widget.userId);
    name=user.displayName;
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
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Account(userId: _userId, friendId: 0)));
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