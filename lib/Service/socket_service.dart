import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  WebSocketChannel? _channel;
  final _messageStreamController = StreamController<String>.broadcast();
  int? _userId;
  int _retryCount = 0;
  
  Stream<String> get messages => _messageStreamController.stream;

  void connect(int userId) {
    if (_channel != null) return;
    _userId = userId;
    print('🔌 Connecting as user $userId...');
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://192.168.200.1:8080/ws/chat?userId=$userId'),
    );

    _channel!.stream.listen(
      (message) => _messageStreamController.add(message),
      onError: (e) {
        print('⚠️ Socket error: $e');
        _handleReconnect();
      },
      onDone: () {
        print('🔌 Socket closed');
        _handleReconnect();
      },
    );
  }

  void _handleReconnect() {
    _channel = null;
    if (_userId != null) reconnect(_userId!);
  }

  void reconnect(int userId) async {
    if (_retryCount >= 5) return;
    _retryCount++;
    await Future.delayed(Duration(seconds: 2 * _retryCount));
    connect(userId);
  }

  void sendMessage(Map<String, dynamic> data) {
    if (_channel != null && _channel!.closeCode == null) {
      print(data);
      _channel!.sink.add(jsonEncode(data));
    } else {
      print('⚠️ Socket is closed, cannot send message');
    }
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
    _retryCount = 0;
    print('❌ Disconnected');
  }
}
