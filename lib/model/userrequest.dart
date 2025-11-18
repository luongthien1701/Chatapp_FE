
class Loginrequest {
  String username;
  String password;
  Loginrequest({required this.username,required this.password});
  Map<String,dynamic> toJson()
  {
    return {
      'username':username,
      'password':password
    };
  }
}
class SignUpRequest {
  String username;
  String password;
  String email;
  String phone;
  String displayname;
  SignUpRequest({required this.username,required this.password,required this.email,required this.phone,required this.displayname});
  Map<String,dynamic> toJson()
  {
    return {
      'username':username,
      'password':password,
      'email':email,
      'phone':phone,
      'displayname':displayname
    };
  }
}