import 'package:flutter/material.dart';
import 'package:flutter_application_1/Page/CameraPage.dart';
import 'package:flutter_application_1/Page/ChatPage.dart';
import 'package:flutter_application_1/Page/StatusPage.dart';
import 'package:flutter_application_1/Page/CallsPage.dart';
import 'package:flutter_application_1/Screens/CreateGroup.dart';
import 'package:flutter_application_1/Screens/SettingsPage.dart';
import 'package:flutter_application_1/Screens/SelectContact.dart';
import 'package:flutter_application_1/State/AppState.dart';
import 'package:flutter_application_1/Theme/AppColors.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<Homescreen>
    with SingleTickerProviderStateMixin {
  late TabController _controller;
  final List<String> _titles = [
    'Trillion Chats',
    'Trillion Chats',
    'Status',
    'Calls',
  ];

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 4, vsync: this, initialIndex: 1);
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _newGroup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateGroup()),
    );
  }

  Future<void> _logout() async {
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
  }

  void _statusOptions() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _controller.animateTo(0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Text status'),
              onTap: () {
                Navigator.pop(context);
                _textStatusDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _textStatusDialog() {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Text status'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 140,
          decoration: const InputDecoration(hintText: 'Type your status'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                AppState.instance.updateMyStatus(text);
              }
              Navigator.pop(context);
            },
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }

  void _newCall() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'New call',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            for (final contact in AppState.instance.contacts.take(5))
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: contact.color,
                  child: Text(
                    contact.name.substring(0, 1),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(contact.name),
                trailing: const Icon(Icons.call, color: AppColors.chatGreen),
                onTap: () {
                  AppState.instance.addCall(contact);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Calling ${contact.name} (demo)'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget? _fab() {
    switch (_controller.index) {
      case 1:
        return FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SelectContact()),
            );
          },
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.black,
          child: const Icon(Icons.message),
        );
      case 2:
        return FloatingActionButton(
          onPressed: _statusOptions,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.black,
          child: const Icon(Icons.photo_camera),
        );
      case 3:
        return FloatingActionButton(
          onPressed: _newCall,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.black,
          child: const Icon(Icons.add_call),
        );
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_controller.index],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              if (_controller.index == 1) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Search (demo)'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            color: AppColors.menu,
            onSelected: (value) {
              switch (value) {
                case 'New Group':
                  _newGroup();
                  break;
                case 'Settings':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsPage()),
                  );
                  break;
                case 'Logout':
                  _logout();
                  break;
                default:
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$value (demo)'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'New Group', child: Text('New Group')),
              PopupMenuItem(value: 'New Broadcast', child: Text('New Broadcast')),
              PopupMenuItem(value: 'Starred Messages', child: Text('Starred Messages')),
              PopupMenuItem(value: 'Settings', child: Text('Settings')),
              PopupMenuItem(value: 'Logout', child: Text('Logout')),
            ],
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(5)),
        ),
        backgroundColor: AppColors.primary,
        bottom: TabBar(
          controller: _controller,
          indicatorColor: AppColors.accent,
          tabs: const [
            Tab(icon: Icon(Icons.camera_alt)),
            Tab(text: 'CHATS'),
            Tab(text: 'STATUS'),
            Tab(text: 'CALLS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _controller,
        children: const [
          CameraPage(),
          ChatPage(),
          StatusPage(),
          CallsPage(),
        ],
      ),
      floatingActionButton: _fab(),
      backgroundColor: AppColors.background,
    );
  }
}
