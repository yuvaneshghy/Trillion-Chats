import 'package:flutter/material.dart';
import 'package:flutter_application_1/CustomUI/AppAvatar.dart';
import 'package:flutter_application_1/CustomUI/ContactCard.dart';
import 'package:flutter_application_1/Model/ContactModel.dart';
import 'package:flutter_application_1/Screens/CreateGroupInfoPage.dart';
import 'package:flutter_application_1/State/AppState.dart';
import 'package:flutter_application_1/Theme/AppColors.dart';

class CreateGroup extends StatefulWidget {
  const CreateGroup({super.key});

  @override
  _CreateGroupState createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  final List<ContactModel> _selected = [];
  String _query = '';

  void _toggle(ContactModel contact) {
    setState(() {
      if (_selected.contains(contact)) {
        _selected.remove(contact);
      } else {
        _selected.add(contact);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final contacts = AppState.instance.contacts
        .where((c) =>
            _query.isEmpty || c.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'New group',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: _selected.isEmpty
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CreateGroupInfoPage(selected: List.of(_selected)),
                      ),
                    );
                  },
            child: Text(
              'Next',
              style: TextStyle(
                fontSize: 16,
                color: _selected.isEmpty ? Colors.white54 : Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          if (_selected.isNotEmpty)
            SizedBox(
              height: 84,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: _selected.length,
                itemBuilder: (context, index) {
                  final c = _selected[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(
                      children: [
                        AppAvatar(
                          name: c.name,
                          isGroup: false,
                          color: c.color,
                          radius: 22,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          c.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, color: Colors.white),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: (value) => setState(() => _query = value),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search contacts',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: Colors.white10,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return ContactCard(
                  contact: contact,
                  selected: _selected.contains(contact),
                  showCheck: true,
                  onTap: () => _toggle(contact),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
