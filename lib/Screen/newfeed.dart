import 'package:flutter/material.dart';

class Newfeed extends StatefulWidget {
  final int userId;
  const Newfeed({super.key, required this.userId});

  @override
  State<Newfeed> createState() => _NewfeedState();
}

class _NewfeedState extends State<Newfeed> {
  bool islike=false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListView.builder(
          itemCount: 3,
          itemBuilder: (_, index) => Card(
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar có viền
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black,
                          width: 1,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage(
                          "assets/image/avatar_default.png",
                        ),
                      ),
                    ),
          
                    SizedBox(width: 10),
          
                    // Name + Time
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Name",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Time",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
          
                SizedBox(height: 12),
                Text(
                  "This is a demo post content. Hello everyone!",
                  style: TextStyle(fontSize: 16),
                ),
          
                SizedBox(height: 12),
          
                ClipRRect(
                    borderRadius: BorderRadius.circular(30.0),
                     child: Image.asset(
                    "assets/image/demo_backrgound.jpg",
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                Row(
                  children: [
                    IconButton(onPressed: () => {
                      setState(() {
                        islike = !islike;
                      })
                    }, icon: Icon( !islike?Icons.favorite_border:Icons.favorite, color: !islike?Colors.black :Colors.red,)),
                    Text("10"),
                    IconButton(onPressed: () => {}, icon: Icon(Icons.comment,)),
                    Text("5"),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}
