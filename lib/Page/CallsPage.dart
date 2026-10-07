import 'package:flutter/material.dart';
import 'package:flutter_application_1/CustomUI/AppAvatar.dart';
import 'package:flutter_application_1/Model/CallModel.dart';
import 'package:flutter_application_1/State/AppState.dart';
import 'package:flutter_application_1/Theme/AppColors.dart';
import 'package:flutter_application_1/CustomUI/GlassContainer.dart';

class CallsPage extends StatelessWidget {
  const CallsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final calls = AppState.instance.calls;
        return ListView.builder(
          itemCount: calls.length,
          itemBuilder: (context, index) {
            final call = calls[index];
            return _CallTile(call: call);
          },
        );
      },
    );
  }
}

class _CallTile extends StatelessWidget {
  final CallModel call;
  const _CallTile({required this.call});

  @override
  Widget build(BuildContext context) {
    final iconColor = call.isMissed
        ? AppColors.accent
        : AppColors.whatsappGreen;
    final callIcon = call.isMissed ? Icons.arrow_downward : Icons.arrow_upward;

    return GlassContainer(
      interactive: true,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: AppAvatar(
          name: call.name,
          isGroup: false,
          color: call.color,
          radius: 24,
        ),
        title: Text(
          call.name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        subtitle: Row(
          children: [
            Icon(callIcon, color: iconColor, size: 16),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                call.time,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ),
          ],
        ),
        trailing: Icon(
          call.isVideo ? Icons.videocam : Icons.call,
          color: Colors.white70,
        ),
      ),
    );
  }
}
