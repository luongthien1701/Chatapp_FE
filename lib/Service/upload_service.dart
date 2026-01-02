import 'dart:convert';
import 'dart:io';

import 'package:rela/Service/ip.dart';
import 'package:http/http.dart' as http;

class UploadService {
  String baseUrl = Ip().getIp();
  Future<String> uploadimage(File file, String type, int ownerId) async {
    final uri = Uri.parse('$baseUrl/upload');

    final request = http.MultipartRequest('POST', uri)
      ..fields['type'] = type
      ..fields['ownerId'] = ownerId.toString()
      ..files.add(
        await http.MultipartFile.fromPath('image', file.path),
      );

    final response = await request.send();
    final body = await response.stream.bytesToString();
    final json = jsonDecode(body);
    print(json['url']);
    return json['url'];
  }
}