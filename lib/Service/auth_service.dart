import 'dart:convert';
import 'package:chatapp/Service/ip.dart';
import 'package:chatapp/model/message.dart';
import 'package:chatapp/model/userrequest.dart';
import 'package:http/http.dart' as http;
class AuthService {
  String baseUrl = Ip().getIp();
  Future<SenderInfo> login(Loginrequest userlogin) async
  {
    final url=Uri.parse('$baseUrl/user/login');
    final respon=await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username':userlogin.username,'password':userlogin.password})
    );
    if (respon.statusCode==200)
    {
      final data=jsonDecode(utf8.decode(respon.bodyBytes));
      return SenderInfo.fromJson(data);
    }
    else 
    {
      throw Exception("Không thể đăng nhập");
    } 
  }
  Future<Apiresponse> signup(SignUpRequest usersignup) async
  {
    final url=Uri.parse('$baseUrl/user');
    final respon=await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username':usersignup.username,'password':usersignup.password,'email':usersignup.email,'phone':usersignup.phone,'display_name':usersignup.displayname})
    );
    try {
    if (respon.statusCode==201)
    {
      final data=jsonDecode(respon.body);
      return Apiresponse(success:true,message:data['message']);
    }
    else 
    {
      final data=jsonDecode(respon.body);
      return Apiresponse(success:false,message:data['message']);
    }
    } catch (e) {
      return Apiresponse(success:false,message:"Lỗi không xác định");
    }
  }
  
}
class Apiresponse 
{
  bool success;
  String message;
  Apiresponse({required this.success,required this.message});
}