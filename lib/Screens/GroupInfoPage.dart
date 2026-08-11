import 'package:flutter/material.dart';
import 'package:flutter_application_1/CustomUI/AppAvatar.dart';
import 'package:flutter_application_1/Model/ChatModel.dart';
import 'package:flutter_application_1/Theme/AppColors.dart';

class GroupInfoPage extends StatelessWidget {
  final ChatModel chat;

  const GroupInfoPage({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        title: const Text(
          'Group info',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          Center(
            child: AppAvatar(
              name: chat.name,
              isGroup: true,
              color: chat.avatarColor,
              radius: 45,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              chat.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 4),
          const Center(
            child: Text(
              'Group · 8 members',
              style: TextStyle(fontSize: 14, color: AppColors.grey),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          _option(Icons.volume_off, 'Mute notifications'),
          _option(Icons.star, 'Starred messages'),
          _option(Icons.person_search, 'Search'),
          _option(Icons.image, 'Media, links and docs'),
          _option(Icons.wallpaper, 'Wallpaper'),
          _option(Icons.group_add, 'Add participants'),
          const Divider(),
          _option(Icons.exit_to_app, 'Exit group', color: AppColors.accent),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _option(IconData icon, String title, {Color color = Colors.black}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.grey),
    );
  }
}
