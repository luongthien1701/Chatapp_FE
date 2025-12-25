import 'package:chatapp/model/message.dart';
import 'package:chatapp/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Call extends StatefulWidget {
  final int callerId;
  const Call({super.key, required this.callerId});

  @override
  State<Call> createState() => _Call();
}

class _Call extends State<Call> {
  String? name;
  String? avatarUrl;
  Offset offsetLeft = Offset.zero;
  Offset offsetRight = Offset.zero;
  @override
  void initState() {
    super.initState();
    loadInfo();
  }

  Future<void> loadInfo() async {
    Future.delayed(Duration(seconds: 2));
    SenderInfo sender = await context.read<UserProvider>().getProfile(
      widget.callerId,
    );
    setState(() {
      name = sender.name;
      avatarUrl = "http://localhost:8080" + sender.avatarUrl.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 82, 132, 219),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 70),
            Text(
              name.toString(),
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            SizedBox(height: 40),
            SizedBox(
              height: 100,
              width: 100,
              child: CircleAvatar(
                backgroundImage: NetworkImage(avatarUrl.toString(), scale: 30),
                radius: 20,
              ),
            ),
            SizedBox(height: 100),
            Text(
              "CALLING...",
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
            SizedBox(height: 100),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onPanUpdate: (d) {
                    setState(() {
                      offsetLeft = Offset(
                        (offsetLeft.dx + d.delta.dx > 0 &&
                                offsetLeft.dx + d.delta.dx <= 100)
                            ? offsetLeft.dx + d.delta.dx
                            : 0,
                        offsetLeft.dy,
                      );
                      if (offsetLeft.dx > 95) {
                        
                      }
                    });
                  },
                  onPanEnd: (details) {
                    setState(() {
                      offsetLeft = Offset.zero;
                    });
                  },
                  child: Transform.translate(
                    offset: offsetLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.phone, size: 50, color: Colors.green),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 100),
                GestureDetector(
                  onPanUpdate: (d) {
                    setState(() {
                      offsetRight = Offset(
                        (offsetRight.dx + d.delta.dx < 0 &&
                                offsetRight.dx + d.delta.dx > -100)
                            ? offsetRight.dx + d.delta.dx
                            : 0,
                        offsetRight.dy,
                      );
                      if (offsetRight.dx < -95) {
                        Navigator.pop(context);
                      }
                    });
                  },
                  onPanEnd: (details) {
                    setState(() {
                      offsetRight = Offset.zero;
                    });
                  },
                  child: Transform.translate(
                    offset: offsetRight,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.phone_disabled,
                          size: 50,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
