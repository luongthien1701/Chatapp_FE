import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chatapp/provider/call_provider.dart';
import 'package:chatapp/provider/user_provider.dart';

class InCommingCall extends StatelessWidget {
  const InCommingCall({super.key});

  @override
  Widget build(BuildContext context) {
    final call = context.watch<CallProvider>();
    final userId = context.read<UserProvider>().userId;

    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage("http://192.168.1.13:8080${call.info.avatarUrl}"),
            ),
            const SizedBox(height: 20),
            Text(
              call.info.name,
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  backgroundColor: Colors.red,
                  onPressed: () => call.rejectCall(userId),
                  child: const Icon(Icons.call_end),
                ),
                FloatingActionButton(
                  backgroundColor: Colors.green,
                  onPressed: () => 
                  call.acceptCall(userId),
                  child: const Icon(Icons.call),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
