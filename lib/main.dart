import 'package:chatapp/provider/account_provider.dart';
import 'package:chatapp/provider/comment_provider.dart';
import 'package:chatapp/provider/newsfeed_provider.dart';
import 'package:chatapp/provider/search_provider.dart';
import 'package:chatapp/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:chatapp/provider/mess_list_provider.dart'; 
import 'package:chatapp/provider/notification_provider.dart'; 
import 'package:chatapp/provider/convervasion_provider.dart'; 
import 'package:chatapp/provider/contact_provider.dart'; 

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
      title: 'ChatApp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
      ),
      home: LoginPage(), 
    );
  }
}
