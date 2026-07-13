import 'package:flutter/material.dart';
import 'package:flutter_application_1/CustomUI/CustomCard.dart';
import 'package:flutter_application_1/Model/ChatModel.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<ChatModel> chats = [
    ChatModel(
      name: "Yuva",
      icon: "person.svg",
      isGroup: false,
      time: "4:00",
      currentMessage: "Hi Everyone",
    ),
    ChatModel(
      name: "Nila",
      icon: "Assets/Person.svg",
      isGroup: false,
      time: "5:00",
      currentMessage: "Hi Everyone",
    ),
    ChatModel(
      name: "Nila_yuva",
      icon: "Assets/Groups.svg",
      isGroup: true,
      time: "5:00",
      currentMessage: "Hi Everyone",
    ),
    ChatModel(
      name: "Nila",
      icon: "Assets/Person.svg",
      isGroup: false,
      time: "5:00",
      currentMessage: "Hi Everyone",
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.message),
      ),
      body: ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, index) => CustomCard(chatModel: chats[index]),
      ),
      backgroundColor: const Color.fromARGB(255, 248, 241, 178),
    );
  }
}
