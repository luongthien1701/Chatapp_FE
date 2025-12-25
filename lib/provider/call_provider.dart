import 'package:chatapp/Service/call_service.dart';
import 'package:chatapp/Service/socket_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class CallProvider extends ChangeNotifier {
  bool isInCall = false;
  bool isCall = false;

  int? roomId;
  int? userId;
  final CallService _callService = CallService();
  RTCSessionDescription? remoteDescription;
  void onReceive(Map<String, dynamic> msg) {
    if (msg['event'] == 'incoming_call') {
      final data = msg['data'];
      roomId = data['roomId'];
      userId = data['userId'];
      remoteDescription = RTCSessionDescription(data['sdp'], data['type']);
      isInCall = true;
      isCall = false;
      notifyListeners();
    } else if (msg['event'] == 'call_answered') {
      final data = msg['data'];
      _callService.setRemoteAnser({'sdp': data['sdp'], 'type': data['type']});
    }
    else if (msg['event'] == 'ice_candidate') {
      final data = msg['data'];
      RTCIceCandidate candidate = RTCIceCandidate(
        data['candidate'],
        data['sdpMid'],
        data['sdpMLineIndex'],
      );
      _callService.addCandidate(candidate);
    }
  }

  void startCall(int roomId, int userId) async {
    this.roomId = roomId;
    this.userId = userId;
    await _callService.initCall();
    _callService.setRoomAndUser(roomId, userId);
    final offer = await _callService.createOffer();
    SocketService().sendMessage({
      'event': 'call_invite',
      'data': {
        'roomId': roomId,
        'userId': userId,
        'sdp': offer?.sdp,
        'type': offer?.type,
      },
    });
    isInCall = true;
    isCall = true;
    notifyListeners();
  }

  void acceptCall() async {
    isInCall = true;
    isCall = true;
    if (remoteDescription == null) return;
    await _callService.initCall();
    _callService.setRoomAndUser(roomId!, userId!);
    await _callService.setRemoteOffer({
      'sdp': remoteDescription?.sdp,
      'type': remoteDescription?.type,
    });
    final answer = await _callService.createAnswer();
    SocketService().sendMessage({
      'event': 'call_answer',
      'data': {
        'roomId': roomId,
        'userId': userId,
        'sdp': answer?.sdp,
        'type': answer?.type,
      },
    });

    notifyListeners();
  }

  void endCall() {
    isInCall = false;
    isCall = false;
    roomId = null;
    userId = null;
    _callService.dispose();
    notifyListeners();
  }
}
