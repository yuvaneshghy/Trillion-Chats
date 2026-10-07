import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Model/MessageModel.dart';
import 'package:flutter_application_1/Theme/AppColors.dart';
import 'package:flutter_application_1/CustomUI/GlassContainer.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isSent = message.isSentByMe;
    return Align(
      alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: GlassContainer(
        interactive: true,
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 6),
        opacity: isSent ? 0.3 : 0.1,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(14),
          topRight: const Radius.circular(14),
          bottomLeft: Radius.circular(isSent ? 14 : 4),
          bottomRight: Radius.circular(isSent ? 4 : 14),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (message.type == MessageType.image && message.mediaPath != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(message.mediaPath!),
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else if (message.type == MessageType.document && message.mediaPath != null)
                Container(
                  width: 200,
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 4.0),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.insert_drive_file, size: 30, color: Colors.white70),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          message.text.isNotEmpty ? message.text : "Document",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Text(
                  message.text,
                  style: const TextStyle(fontSize: 15.5, height: 1.25, color: Colors.white),
                ),
              const SizedBox(height: 3),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message.time,
                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                  const SizedBox(width: 4),
                  if (isSent)
                    const Icon(
                      Icons.done_all,
                      size: 15,
                      color: Colors.lightBlueAccent,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
