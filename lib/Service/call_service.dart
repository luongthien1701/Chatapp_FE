import 'dart:convert';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:rela/Service/ip.dart';

class CallService {
  String baseUrl = Ip().getIp();
  static CallService? _instance;
  factory CallService() => _instance ??= CallService._();

  CallService._();
  late RtcEngine engine;
  bool _initialized = false;

  RtcEngineContext get context => const RtcEngineContext(
        appId: 'c43cb3a3918a4d6f9ce96e5f3cbd5aab',
      );
  Future<void> initializeAgora({
    required void Function(int uid) onRemoteJoin,
    required void Function(int uid) onRemoteLeave,
  }) async {
    if (_initialized) return;

    engine = createAgoraRtcEngine();
    await engine.initialize(const RtcEngineContext(
        appId: 'c43cb3a3918a4d6f9ce96e5f3cbd5aab',
        channelProfile: ChannelProfileType.channelProfileCommunication));
    await engine.enableVideo();
    await engine.enableAudio();
    await engine.startPreview();
    await engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          debugPrint(
              '✅ Joined channel: ${connection.channelId}, uid=${connection.localUid}');
        },
        onUserJoined: (connection, uid, elapsed) {
          onRemoteJoin(uid);
        },
        onUserOffline: (connection, uid, reason) {
          onRemoteLeave(uid);
        },
      ),
    );

    _initialized = true;
  }

  Future<String> getToken(String channelName, int userId) async {
    final url = Uri.parse(
      '$baseUrl/agora/token?channelName=$channelName&userId=$userId',
    );
    try {
      final respon = await http.get(url);
      if (respon.statusCode == 200) {
        final data = jsonDecode(respon.body);
        return data['token'];
      } else {
        throw Exception("Không thể lấy token");
      }
    } catch (e) {
      throw Exception("Lỗi không xác định");
    }
  }

  Future<void> joinChannel(String token, String channelId, int uid) async {
    await engine.joinChannel(
      token: token,
      channelId: channelId,
      uid: uid,
      options: const ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileCommunication,

        clientRoleType: ClientRoleType.clientRoleBroadcaster,

        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
        publishCameraTrack: true,
        publishMicrophoneTrack: true,
      ),
    );
  }

  Future<void> leaveChannel() async {
    await engine.leaveChannel();
    await engine.stopPreview();
  }

  Future<void> dispose() async {
    await engine.release();
    _initialized = false;
  }
}
