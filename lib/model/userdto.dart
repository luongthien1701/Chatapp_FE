import 'package:rela/model/message.dart';

class UserDTO
{
  final int id;
  final String displayName;
  UserDTO({required this.id,required this.displayName});
} 
class UserProfile
{
  final int id;
  final String displayName;
  final String? email;
  final String password;
  final String? phone;
  UserProfile({required this.id,required this.displayName,required this.email,required this.password,required this.phone});
} 
class UserNear 
{
  final SenderInfo user;
  final double distance; // khoảng cách tính bằng km  
  UserNear({required this.user, required this.distance});
}