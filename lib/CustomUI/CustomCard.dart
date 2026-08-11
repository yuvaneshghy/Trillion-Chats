import 'package:flutter/material.dart';
import 'package:flutter_application_1/Model/ChatModel.dart';
import 'package:flutter_application_1/Theme/AppColors.dart';
import 'package:flutter_application_1/Screens/IndividualPage.dart';
import 'AppAvatar.dart';

class CustomCard extends StatelessWidget {
  const CustomCard({super.key, required this.chatModel});
  final ChatModel chatModel;

  @override
  Widget build(BuildContext context) {
    final lastSent = chatModel.messages.isNotEmpty &&
        chatModel.messages.last.isSentByMe;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => IndividualPage(chatModel: chatModel),
          ),
        );
      },
      child: ListTile(
        leading: AppAvatar(
          name: chatModel.name,
          isGroup: chatModel.isGroup,
          color: chatModel.avatarColor,
          radius: 28,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                chatModel.name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            if (chatModel.pinned)
              const Icon(Icons.push_pin,
                  size: 14, color: AppColors.grey),
          ],
        ),
        subtitle: Row(
          children: [
            if (lastSent) ...[
              const Icon(Icons.done_all, color: Colors.blueAccent, size: 16),
              const SizedBox(width: 3),
            ],
            Expanded(
              child: Text(
                chatModel.lastMessage,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(chatModel.lastTime,
                style: const TextStyle(fontSize: 12, color: AppColors.grey)),
            const SizedBox(height: 4),
            if (chatModel.unreadCount > 0)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: const BoxDecoration(
                  color: AppColors.whatsappGreen,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${chatModel.unreadCount}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              )
            else if (chatModel.muted)
              const Icon(Icons.volume_off,
                  size: 16, color: AppColors.grey),
          ],
        ),
      ),
    );
  }
}
