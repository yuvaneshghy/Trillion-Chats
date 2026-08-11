import 'package:flutter/material.dart';
import 'package:flutter_application_1/CustomUI/AppAvatar.dart';
import 'package:flutter_application_1/Model/ContactModel.dart';
import 'package:flutter_application_1/Screens/IndividualPage.dart';
import 'package:flutter_application_1/State/AppState.dart';
import 'package:flutter_application_1/Theme/AppColors.dart';

class CreateGroupInfoPage extends StatefulWidget {
  final List<ContactModel> selected;

  const CreateGroupInfoPage({super.key, required this.selected});

  @override
  _CreateGroupInfoPageState createState() => _CreateGroupInfoPageState();
}

class _CreateGroupInfoPageState extends State<CreateGroupInfoPage> {
  final TextEditingController _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _create() {
    final name = _name.text.trim();
    final defaultName = widget.selected.length > 1
        ? widget.selected.take(2).map((c) => c.name).join(', ')
        : 'New Group';
    final chat = AppState.instance.createGroup(
      name.isEmpty ? defaultName : name,
      AppColors.chatGreen,
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => IndividualPage(chatModel: chat)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'New group',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: _create,
            child: const Text(
              'Create',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Stack(
                children: [
                  const AppAvatar(
                    name: '',
                    isGroup: true,
                    color: AppColors.chatGreen,
                    radius: 45,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.whatsappGreen,
                      child: Icon(
                        Icons.camera_alt,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _name,
                maxLength: 25,
                decoration: const InputDecoration(
                  hintText: 'Type group subject',
                  counterText: '',
                  border: UnderlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Participants: ${widget.selected.length}',
                style: const TextStyle(fontSize: 14, color: AppColors.grey),
              ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.selected.length,
              itemBuilder: (context, index) {
                final c = widget.selected[index];
                return ListTile(
                  leading: AppAvatar(
                    name: c.name,
                    isGroup: false,
                    color: c.color,
                    radius: 22,
                  ),
                  title: Text(c.name),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
