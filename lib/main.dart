import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:rela/Screen/CallScreen.dart';
import 'package:rela/Service/notification_service.dart';
import 'package:rela/provider/account_provider.dart';
import 'package:rela/provider/call_provider.dart';
import 'package:rela/provider/comment_provider.dart';
import 'package:rela/provider/newsfeed_provider.dart';
import 'package:rela/provider/search_provider.dart';
import 'package:rela/provider/theme_provider.dart';
import 'package:rela/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:rela/provider/mess_list_provider.dart'; 
import 'package:rela/provider/notification_provider.dart'; 
import 'package:rela/provider/convervasion_provider.dart'; 
import 'package:rela/provider/contact_provider.dart'; 

import 'Screen/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.subscribeToTopic("test");
  await requestNotificationPermission();
  await NotificationService.init();
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null) {
      NotificationService.showNotification(
        notification.hashCode,
        notification.title ?? '',
        notification.body ?? '',
      );
    }
  });
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
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
Future<void> requestNotificationPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings=await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
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
      
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            const CallScreen(), 
          ],
        );
      },
      
      home: const LoginPage(), 
    );
  }
}
