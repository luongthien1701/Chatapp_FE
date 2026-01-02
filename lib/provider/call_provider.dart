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

    debugPrint("📩 [CallProvider] onReceived Socket Event: $event");
    debugPrint("📦 [CallProvider] Payload: $data");

    switch (event) {
      case 'call_comming':
        debugPrint("🔔 [CallProvider] Có cuộc gọi đến!");
        roomId = data['roomId'];
        haveCall = true;

        final callerId = data['userId'];
        debugPrint("🔍 [CallProvider] Đang lấy profile callerId: $callerId");
        info = await profileService.getProfile(callerId);
        debugPrint("👤 [CallProvider] Caller Info: ${info.name}");

        notifyListeners();
        break;

      case 'call_accept':
        debugPrint("✅ [CallProvider] Đối phương đã CHẤP NHẬN cuộc gọi!");
        debugPrint(
            "ℹ️ [CallProvider] Trạng thái hiện tại -> isInCall: $isInCall, roomId: $roomId");

        // Logic bổ sung: Đảm bảo UI update
        if (!isInCall) {
          debugPrint(
              "⚠️ [CallProvider] Cảnh báo: isInCall đang false khi nhận accept. Đang set lại true.");
          isInCall = true;
        }
        haveCall = false;
        notifyListeners();
        break;

      case 'call_reject':
        debugPrint("⛔ [CallProvider] Cuộc gọi bị từ chối.");
        _resetCall();
        break;
      case 'call_end':
        debugPrint("🔚 [CallProvider] Cuộc gọi kết thúc từ phía kia.");
        _resetCall();
        break;
      default:
        debugPrint("⚠️ [CallProvider] Event không xử lý: $event");
    }
  }

  // ================= ACTION =================
  // ================= ACTION =================
  // Trong CallProvider.dart

  Future<void> startCall(int roomId, int userId) async {
    debugPrint("🚀 [CallProvider] START CALL >>> Room: $roomId, LocalUser: $userId");

    _resetCall(); 
    
    // 1. Hiện UI chờ ngay lập tức
    isInCall = true; 
    haveCall = false;
    notifyListeners(); 

    try {
      // 2. Init & Join
      await initAgora();
      
      this.roomId = roomId;
      localUid = userId;

      final channel = 'room_$roomId';
      debugPrint("🔑 Đang lấy token...");
      final token = await callService.getToken(channel, userId);

      debugPrint("🔌 Đang Join Channel Agora...");
      await callService.joinChannel(token, channel, userId);
      debugPrint("✅ Join Channel xong.");

      // 3. Gửi Socket mời
      debugPrint("📡 Gửi socket call_invite...");
      SocketService().sendMessage({
        'event': 'call_invite',
        'data': {'roomId': roomId, 'userId': userId}
      });
      
      debugPrint("🏁 startCall hoàn tất.");
      
      // 🔥 FIX BỔ SUNG: Notify một lần nữa để chắc chắn UI không bị treo ở trạng thái cũ
      Future.microtask(() => notifyListeners());

    } catch (e) {
      debugPrint("❌ Lỗi startCall: $e");
      _resetCall();
    }
  }

  Future<void> acceptCall(int userId) async {
    debugPrint("📞 [CallProvider] ACCEPT CALL >>> LocalUser: $userId");

    // 1️⃣ Set State
    localUid = userId;

    // 2️⃣ Init Agora
    await initAgora();

    final channel = 'room_$roomId';

    debugPrint("🔑 [CallProvider] Đang lấy token...");
    final token = await callService.getToken(channel, userId);

    // 3️⃣ Join Agora
    debugPrint("🔌 [CallProvider] Đang Join Channel Agora...");
    await callService.joinChannel(token, channel, userId);
    debugPrint("✅ [CallProvider] Join Channel xong.");

    // 4️⃣ Gửi Socket
    debugPrint("📡 [CallProvider] Gửi socket call_accept...");
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
    debugPrint("🏁 [CallProvider] acceptCall hoàn tất. Đã vào màn hình gọi.");
  }

  void rejectCall(int userId) {
    debugPrint("⛔ [CallProvider] REJECT CALL");
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
    debugPrint("🔚 [CallProvider] END CALL");
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
    debugPrint("➕ [CallProvider] addRemoteUser: $uid");

    if (!remoteUids.contains(uid)) {
      remoteUids.add(uid);
      debugPrint("✅ [CallProvider] Đã thêm $uid vào danh sách remoteUids.");

      // 🔥 FIX QUAN TRỌNG: Đẩy việc cập nhật UI về luồng chính
      Future.microtask(() {
        notifyListeners();
      });
    }
  }

  void removeRemoteUser(int uid) {
    debugPrint("➖ [CallProvider] removeRemoteUser: $uid");
    remoteUids.remove(uid);
    // 🔥 FIX QUAN TRỌNG
    Future.microtask(() {
      notifyListeners();
    });
  }

  void _resetCall() {
    debugPrint("🔄 [CallProvider] RESET CALL STATE");
    haveCall = false;
    isInCall = false;
    roomId = 0;
    localUid = 0;
    remoteUids.clear();
    notifyListeners();
  }
}
