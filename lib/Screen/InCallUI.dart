// File: InCallUI.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:chatapp/provider/call_provider.dart';

class InCallUI extends StatelessWidget {
  const InCallUI({super.key});

  @override
  Widget build(BuildContext context) {
    final call = context.watch<CallProvider>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ================= 1. REMOTE VIDEO (Người khác) =================
          if (call.remoteUids.isNotEmpty)
            Positioned.fill(
              // 🔥 FIX QUAN TRỌNG NHẤT: Thêm Key
              // Khi call.remoteUids[0] thay đổi (từ rỗng -> có ID), Key thay đổi
              // -> Flutter buộc phải Vẽ Lại (Re-render) toàn bộ Widget này
              key: ValueKey(call.remoteUids[0]), 
              
              child: AgoraVideoView(
                controller: VideoViewController.remote(
                  rtcEngine: call.callService.engine,
                  
                  // ID của người kia
                  canvas: VideoCanvas(uid: call.remoteUids[0]), 
                  
                  // 🔥 QUAN TRỌNG: Caller KHÔNG ĐƯỢC truyền localUid vào đây
                  connection: RtcConnection(channelId: 'room_${call.roomId}'), 
                ),
              ),
            )
          else
            // Màn hình chờ khi chưa có ai vào
            const Positioned.fill(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 20),
                    Text("Đang chờ người nhận...", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),

          // ================= 2. LOCAL VIDEO (Mình) =================
          Positioned(
            top: 40, right: 20, width: 120, height: 160,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AgoraVideoView(
                controller: VideoViewController(
                  rtcEngine: call.callService.engine,
                  canvas: const VideoCanvas(uid: 0), // 0 luôn là mình
                ),
              ),
            ),
          ),

          // ================= 3. NÚT KẾT THÚC =================
          Positioned(
            bottom: 40, left: 0, right: 0,
            child: Center(
              child: FloatingActionButton(
                backgroundColor: Colors.red,
                onPressed: () => call.endCall(),
                child: const Icon(Icons.call_end),
              ),
            ),
          ),
        ],
      ),
    );
  }
}