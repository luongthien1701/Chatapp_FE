import 'package:chatapp/Screen/hub.dart';
import 'package:chatapp/model/message.dart';
import 'package:chatapp/model/userrequest.dart';
import 'package:chatapp/provider/user_provider.dart';
import 'package:chatapp/provider/notification_provider.dart';
import 'package:flutter/material.dart';
import 'signup.dart';
import 'package:provider/provider.dart';
import 'package:chatapp/Service/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();
  bool _obscureText = true;
  final AuthService auth=AuthService();
  @override
  Widget build(BuildContext context) {
    final provider=context.read<UserProvider>();
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        automaticallyImplyLeading: false
      ),
      body: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 170, 209, 228),
          borderRadius: BorderRadius.circular(30),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 100),
                const Text(
                  "Welcome Back",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),


                const SizedBox(height: 20),
                const Text(
                  "Login to your account",
                  style: TextStyle(fontSize: 12),
                ),


                const SizedBox(height: 60),
                TextField(
                  controller: username,
                  decoration: const InputDecoration(
                    labelText: "Username",
                    border: OutlineInputBorder(),
                  ),
                ),


                const SizedBox(height: 20),
                TextField(
                  controller: password,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                      icon: Icon(_obscureText
                          ? Icons.remove_red_eye_outlined
                          : Icons.remove_red_eye_rounded),
                    ),
                  ),
                ),


                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () async {
                    final currentcontext=context;
                    if (username.text.isEmpty||password.text.isEmpty)
                    {
                      showDialog(context: context, builder: (context)=>AlertDialog(
                        title: Text("Thông báo"),
                        content: Text("Vui lòng nhập đầy đủ thông tin"),
                        actions: [
                          ElevatedButton(onPressed: () {Navigator.pop(context);}, child: Text("OK")),
                        ], 
                      )
                      );
                    }
                    try{
                    Loginrequest userlogin=Loginrequest(username: username.text, password: password.text);
                    SenderInfo user= await auth.login(userlogin);
                    provider.setUser(user.id, user.name, user.avatarUrl ?? '');
                    if (!mounted) return;
                    Navigator.push(currentcontext, MaterialPageRoute(builder: (context)=> Hub()));
                    }
                    catch(e)
                    {
                      print(e.toString());
                      print("login fail");
                    }
                  },
                  child: const Text("Login"),
                ),


                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?   "),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignUpPage()),
                        );
                      },
                      child: const Text(
                        "Signup",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
