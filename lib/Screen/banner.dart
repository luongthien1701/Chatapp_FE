import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';

class GlobalBannerService {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static void show(String title, {String? avatar}) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(12),
      backgroundColor: Colors.white,
      boxShadows: const [
        BoxShadow(color: Colors.black26, blurRadius: 8),
      ],
      titleText: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      icon: avatar == null
          ? const Icon(Icons.notifications)
          : CircleAvatar(backgroundImage: NetworkImage(avatar)),
    ).show(context);
  }
}
