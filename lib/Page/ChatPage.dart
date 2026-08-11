import 'package:flutter/material.dart';
import 'package:flutter_application_1/CustomUI/AppAvatar.dart';
import 'package:flutter_application_1/CustomUI/CustomCard.dart';
import 'package:flutter_application_1/Model/ChatModel.dart';
import 'package:flutter_application_1/Model/UserModel.dart';
import 'package:flutter_application_1/Screens/IndividualPage.dart';
import 'package:flutter_application_1/State/AppState.dart';
import 'package:flutter_application_1/Theme/AppColors.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool _matches(ChatModel chat) {
    final q = _query.toLowerCase();
    return q.isEmpty ||
        chat.name.toLowerCase().contains(q) ||
        chat.lastMessage.toLowerCase().contains(q);
  }

  Widget _searchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        controller: _search,
        onChanged: (value) => setState(() => _query = value),
        decoration: InputDecoration(
          hintText: 'Search by name',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _search.clear();
                    setState(() => _query = '');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _userResult(UserModel user) {
    return ListTile(
      leading: AppAvatar(
        name: user.username,
        isGroup: false,
        color: user.color,
        radius: 24,
      ),
      title: Text(
        user.username,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      subtitle: const Text('User on Trillion Chats'),
      trailing: const Icon(Icons.chat_bubble_outline, color: AppColors.chatGreen),
      onTap: () {
        final chat = AppState.instance.startChat(user);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => IndividualPage(chatModel: chat)),
        );
      },
    );
  }

  Widget _sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.chatGreen,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final all = AppState.instance.chats;
        final chats = all.where(_matches).toList();
        final pinned = chats.where((c) => c.pinned).toList();
        final others = chats.where((c) => !c.pinned).toList();
        final users = AppState.instance.searchUsers(_query);

        final List<Widget> children = [];

        if (users.isNotEmpty) {
          children.add(_sectionHeader('Users'));
          for (final u in users) {
            children.add(_userResult(u));
          }
        }
        if (chats.isNotEmpty) {
          children.add(_sectionHeader(users.isNotEmpty ? 'Chats' : ''));
          for (final c in pinned) {
            children.add(CustomCard(chatModel: c));
          }
          for (final c in others) {
            children.add(CustomCard(chatModel: c));
          }
        }
        if (users.isEmpty && chats.isEmpty) {
          children.add(
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 80),
                child: Text(
                  _query.isEmpty
                      ? 'No chats yet\nSearch for a user by name to start chatting'
                      : 'No users or chats found for "$_query"',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: AppColors.grey),
                ),
              ),
            ),
          );
        }

        return Column(
          children: [
            _searchBar(),
            Expanded(
              child: ListView(
                children: children,
              ),
            ),
          ],
        );
      },
    );
  }
}
