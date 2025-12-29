import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chatapp/provider/call_provider.dart';
import 'IncommingCall.dart';
import 'InCallUI.dart';

class CallScreen extends StatelessWidget {
  const CallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final call = context.watch<CallProvider>();

    if (call.haveCall && !call.isInCall) {
      return InCommingCall();
    }

    if (call.isInCall) {
      return const InCallUI();
    }

    return const SizedBox.shrink();
  }
}
