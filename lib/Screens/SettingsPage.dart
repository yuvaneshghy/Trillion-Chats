import 'package:flutter/material.dart';
import 'package:flutter_application_1/CustomUI/AppAvatar.dart';
import 'package:flutter_application_1/State/AppState.dart';
import 'package:flutter_application_1/Theme/AppColors.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        title: const Text(
          'Settings',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        children: [
          InkWell(
            onTap: () => _demo(context, 'Profile'),
            child: Container(
              color: AppColors.primary.withValues(alpha: 0.4),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  AppAvatar(
                    name: AppState.instance.currentUser?.username ?? 'Y',
                    isGroup: false,
                    color: AppColors.chatGreen,
                    radius: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppState.instance.currentUser?.username ?? 'User',
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppState.instance.currentUser?.status ??
                              'Hey there! I am using Trillion Chats',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.qr_code,
                    color: AppColors.chatGreen,
                    size: 28,
                  ),
                ],
              ),
            ),
          ),
          _tile(context, Icons.key, 'Account'),
          _tile(context, Icons.chat_bubble, 'Chats'),
          _tile(context, Icons.notifications, 'Notifications'),
          _tile(context, Icons.storage, 'Storage and data'),
          _tile(context, Icons.info, 'Help'),
          _tile(context, Icons.favorite, 'Invite a friend'),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.accent),
            title: const Text(
              'Logout',
              style: TextStyle(color: AppColors.accent, fontSize: 16),
            ),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await AppState.instance.logout();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: AppColors.chatGreen),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.grey),
      onTap: () => _demo(context, title),
    );
  }

  void _demo(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title (demo)'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
