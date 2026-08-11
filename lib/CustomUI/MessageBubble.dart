import 'package:flutter/material.dart';
import 'package:flutter_application_1/Model/MessageModel.dart';
import 'package:flutter_application_1/Theme/AppColors.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isSent = message.isSentByMe;
    return Align(
      alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 6),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isSent ? AppColors.sentBubble : AppColors.receivedBubble,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isSent ? 14 : 4),
            bottomRight: Radius.circular(isSent ? 4 : 14),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.text,
              style: const TextStyle(fontSize: 15.5, height: 1.25),
            ),
            const SizedBox(height: 3),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.time,
                  style: const TextStyle(fontSize: 11, color: AppColors.grey),
                ),
                const SizedBox(width: 4),
                if (isSent)
                  const Icon(
                    Icons.done_all,
                    size: 15,
                    color: Color(0xFF34B7F1),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
