import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rela/provider/call_provider.dart';
import 'incommingCall.dart';
import 'inCallUI.dart';

class CallScreen extends StatelessWidget {
  const CallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final call = context.watch<CallProvider>();

    if (call.haveCall && !call.isInCall) {
      return const InCommingCall();
    }

    if (call.isInCall) {
      return const InCallUI();
    }

    return const SizedBox.shrink();
  }
}
