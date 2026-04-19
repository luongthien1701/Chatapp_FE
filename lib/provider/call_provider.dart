import 'package:flutter/material.dart';
import 'package:rela/Service/call_service.dart';
import 'package:rela/Service/profile_service.dart';
import 'package:rela/Service/socket_service.dart';
import 'package:rela/model/message.dart';

class CallProvider extends ChangeNotifier {
  final CallService callService = CallService();
  final ProfileService profileService = ProfileService();

  bool haveCall = false; // có cuộc gọi đến
  bool isInCall = false; // đã join agora

  int roomId = 0;
  int localUid = 0;

  SenderInfo info = SenderInfo(id: 0, name: "", avatarUrl: "");
  List<int> remoteUids = [];

  // ================= AGORA =================
  Future<void> initAgora() async {
    debugPrint("🛠 [CallProvider] initAgora: Bắt đầu khởi tạo Engine...");
    try {
      await callService.initializeAgora(
        onRemoteJoin: (uid) {
          debugPrint(
              "🔥 [CallProvider] CALLBACK TỪ SERVICE: onRemoteJoin -> $uid");
          addRemoteUser(uid);
        },
        onRemoteLeave: (uid) {
          debugPrint(
              "👋 [CallProvider] CALLBACK TỪ SERVICE: onRemoteLeave -> $uid");
          removeRemoteUser(uid);
        },
      );
      debugPrint("✅ [CallProvider] initAgora: Khởi tạo thành công!");
    } catch (e) {
      debugPrint("❌ [CallProvider] initAgora LỖI: $e");
    }
  }

  // ================= SOCKET =================
  Future<void> onReceived(Map msg) async {
    final event = msg['event'];
    final data = msg['data'];


    switch (event) {
      case 'call_comming':
        roomId = data['roomId'];
        haveCall = true;

        final callerId = data['userId'];
        info = await profileService.getProfile(callerId);

        notifyListeners();
        break;

      case 'call_accept':
        if (!isInCall) {
          isInCall = true;
        }
        haveCall = false;
        notifyListeners();
        break;

      case 'call_reject':
        _resetCall();
        break;
      case 'call_end':
        _resetCall();
        break;
      default:
    }
  }

  Future<void> startCall(int roomId, int userId) async {
    debugPrint("🚀 [CallProvider] START CALL >>> Room: $roomId, LocalUser: $userId");

    _resetCall(); 
    
    isInCall = true; 
    haveCall = false;
    notifyListeners(); 

    try {
      await initAgora();
      
      this.roomId = roomId;
      localUid = userId;

      final channel = 'room_$roomId';
      final token = await callService.getToken(channel, userId);

      await callService.joinChannel(token, channel, userId);
      SocketService().sendMessage({
        'event': 'call_invite',
        'data': {'roomId': roomId, 'userId': userId}
      });
      
      
      Future.microtask(() => notifyListeners());

    } catch (e) {
      _resetCall();
    }
  }

  Future<void> acceptCall(int userId) async {
    localUid = userId;

    await initAgora();

    final channel = 'room_$roomId';

    final token = await callService.getToken(channel, userId);

    // 3️⃣ Join Agora
    await callService.joinChannel(token, channel, userId);

    SocketService().sendMessage({
      'event': 'call_accept',
      'data': {
        'roomId': roomId,
        'userId': userId,
      }
    });

    isInCall = true;
    haveCall = false;
    notifyListeners();
  }

  void rejectCall(int userId) {
    SocketService().sendMessage({
      'event': 'call_reject',
      'data': {
        'roomId': roomId,
        'userId': userId,
      }
    });
    _resetCall();
  }

  void endCall() async {
    await callService.leaveChannel();

    SocketService().sendMessage({
      'event': 'call_end',
      'data': {
        'roomId': roomId,
        'userId': localUid,
      }
    });

    _resetCall();
  }

// ================= HELPER =================
  void addRemoteUser(int uid) {

    if (!remoteUids.contains(uid)) {
      remoteUids.add(uid);

      Future.microtask(() {
        notifyListeners();
      });
    }
  }

  void removeRemoteUser(int uid) {
    remoteUids.remove(uid);
    Future.microtask(() {
      notifyListeners();
    });
  }

  void _resetCall() {
    haveCall = false;
    isInCall = false;
    roomId = 0;
    localUid = 0;
    remoteUids.clear();
    notifyListeners();
  }
}
