import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:rela/Service/ip.dart';
import 'package:rela/model/message.dart';
import 'package:rela/model/userdto.dart';
import 'package:http/http.dart' as http;

class LocationService {
  final String baseUrl = Ip().getIp();

  static Future<Position?> getCurrentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  Future<List<UserNear>> getNearbyUsers(int userId) async {
    final url = Uri.parse('$baseUrl/user/find?userId=$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      return data
          .map((e) => UserNear(
                user: SenderInfo(
                  id: e['sender']['id'],
                  name: e['sender']['name'],
                  avatarUrl: e['sender']['avatarUrl'],
                ),
                distance: e['distance'].toDouble(),
              ))
          .toList();
    } else {
      throw Exception("Không thể lấy danh sách người dùng gần đây");
    }
  }

  Future<bool> changeStatusProfileVisibility(
      int userId, double lat, double lon) async {
    final url = Uri.parse('$baseUrl/user/changestate/$userId');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'lat': lat, 'lon': lon}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return data['message'] as bool;
    } else {
      throw Exception("Không thể thay đổi trạng thái hiển thị hồ sơ");
    }
  }
}
