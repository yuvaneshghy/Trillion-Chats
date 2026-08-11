import 'package:flutter/material.dart';
import 'package:flutter_application_1/CustomUI/ContactCard.dart';
import 'package:flutter_application_1/Screens/CreateGroup.dart';
import 'package:flutter_application_1/Screens/IndividualPage.dart';
import 'package:flutter_application_1/State/AppState.dart';
import 'package:flutter_application_1/Theme/AppColors.dart';

class SelectContact extends StatefulWidget {
  const SelectContact({super.key});

  @override
  _SelectContactState createState() => _SelectContactState();
}

class _SelectContactState extends State<SelectContact> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _openChat(String name) {
    final contact = AppState.instance.contacts.firstWhere(
      (c) => c.name == name,
      orElse: () => AppState.instance.contacts.first,
    );
    final chat = AppState.instance.ensureChatForContact(contact);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => IndividualPage(chatModel: chat)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final contacts = AppState.instance.contacts
        .where((c) =>
            _query.isEmpty || c.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Select Contact',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 3),
            Text('Contacts', style: TextStyle(fontSize: 13)),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            color: AppColors.menu,
            onSelected: (value) {},
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'Invite a friend', child: Text('Invite a friend')),
              PopupMenuItem(value: 'Contacts', child: Text('Contacts')),
              PopupMenuItem(value: 'Refresh', child: Text('Refresh')),
              PopupMenuItem(value: 'Help', child: Text('Help')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: TextField(
              controller: _search,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Search contacts',
                prefixIcon: const Icon(Icons.search),
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
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.chatGreen,
              child: const Icon(Icons.group_add, color: Colors.white),
            ),
            title: const Text(
              'New group',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateGroup()),
              );
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return ContactCard(
                  contact: contact,
                  onTap: () => _openChat(contact.name),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
