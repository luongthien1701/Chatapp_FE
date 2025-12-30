import 'package:rela/Screen/CallScreen.dart';
import 'package:rela/Screen/IncommingCall.dart';
import 'package:rela/provider/account_provider.dart';
import 'package:rela/provider/call_provider.dart';
import 'package:rela/provider/comment_provider.dart';
import 'package:rela/provider/newsfeed_provider.dart';
import 'package:rela/provider/search_provider.dart';
import 'package:rela/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:rela/provider/mess_list_provider.dart'; 
import 'package:rela/provider/notification_provider.dart'; 
import 'package:rela/provider/convervasion_provider.dart'; 
import 'package:rela/provider/contact_provider.dart'; 

import 'Screen/login.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatroomProvider()), 
        ChangeNotifierProvider(create: (_) => NotificationProvider()), 
        ChangeNotifierProvider(create: (_) => ConversationProvider()),
        ChangeNotifierProvider(create: (_) => FriendProvider()),
        ChangeNotifierProvider(create:  (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => AccountProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create:  (_) => NewsfeedProvider()),
        ChangeNotifierProvider(create:  (_) => CommentProvider()),
        ChangeNotifierProvider(create:  (_) => CallProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat App',
      theme: ThemeData(primarySwatch: Colors.blue),
      
      // 🔥 MAGIC IS HERE: builder giúp CallScreen luôn nằm trên cùng mọi màn hình
      builder: (context, child) {
        return Stack(
          children: [
            // Lớp ứng dụng bình thường (Hub, Conversation...)
            if (child != null) child,
            
            // Lớp màn hình gọi (Global Overlay)
            // Nó sẽ nằm đè lên trên tất cả, bất kể bạn đang ở màn hình nào
            const CallScreen(), 
          ],
        );
      },
      
      home: const LoginPage(), // Hoặc Hub()
    );
  }
}
