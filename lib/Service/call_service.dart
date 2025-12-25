import 'package:chatapp/Service/socket_service.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class CallService {
  static final CallService _instance = CallService._internal();
  factory CallService() {
    return _instance;
  }
  CallService._internal();
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  bool _initialized = false;
  int roomId = 0;
    int userId = 0;
    void setRoomAndUser(int roomId, int userId) {
        this.roomId = roomId;
        this.userId = userId;
    }
  Future<void> initCall() async {
    if (_initialized) return;
    _initialized = true;
    Map<String, dynamic> configuration = {
      'iceServers': [
        {'url': 'stun:stun.l.google.com:19302'},
      ],
    };
    _peerConnection = await createPeerConnection(configuration);
    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': false,
    });
    _peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
        if (candidate.candidate != null) {
            SocketService().sendMessage({
            'event': 'ice_candidate',
            'data': {
                'candidate': candidate.candidate,
                'sdpMid': candidate.sdpMid,
                'sdpMLineIndex': candidate.sdpMLineIndex,
                'roomId': roomId,
                'userId': userId,
            },
            });
        }
    };
    _peerConnection?.onTrack = (RTCTrackEvent event) {
        if (event.streams.isNotEmpty) {
            _remoteStream = event.streams[0];
        }
    };

    _localStream?.getTracks().forEach((track) {
      _peerConnection?.addTrack(track, _localStream!);
    });
  }

  Future<RTCSessionDescription?> createOffer() async {
    RTCSessionDescription? offer = await _peerConnection?.createOffer();
    await _peerConnection?.setLocalDescription(offer!);
    return offer;
  }

  Future<void> setRemoteAnser(Map data) async {
    RTCSessionDescription answer = RTCSessionDescription(
      data['sdp'],
      data['type'],
    );
    await _peerConnection?.setRemoteDescription(answer);
  }

  Future<void> setRemoteOffer(Map data) async {
    RTCSessionDescription offer = RTCSessionDescription(
      data['sdp'],
      data['type'],
    );
    await _peerConnection?.setRemoteDescription(offer);
  }

  Future<RTCSessionDescription?> createAnswer() async {
    RTCSessionDescription? answer = await _peerConnection?.createAnswer();
    await _peerConnection?.setLocalDescription(answer!);
    return answer;
  }
  Future<void> addCandidate(RTCIceCandidate candidate) async {
    await _peerConnection?.addCandidate(candidate);
  }

  void dispose() {
    _localStream?.dispose();
    _peerConnection?.close();
    _peerConnection = null;
    _initialized = false;
    _localStream = null;
  }
}
