import 'package:flutter/material.dart';
import '../Page/ChatPage.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<Homescreen>
    with SingleTickerProviderStateMixin {
  TabController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 4, vsync: this, initialIndex: 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Trillion Chats',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(icon: Icon(Icons.search), onPressed: () {}),
          PopupMenuButton<String>(
            color: const Color.fromARGB(221, 255, 187, 0),
            onSelected: (value) {
              print(value);
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(value: "New Group", child: Text("New Group")),
                PopupMenuItem(value: "Test_1", child: Text("Test_1")),
                PopupMenuItem(value: "Test_2", child: Text("Test_2")),
                PopupMenuItem(value: "Settings", child: Text("Settings")),
              ];
            },
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(5), // Adjust the radius here
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 230, 0),

        bottom: TabBar(
          controller: _controller,
          indicatorColor: const Color.fromARGB(255, 241, 0, 0),
          tabs: [
            Tab(icon: Icon(Icons.camera_alt)),
            Tab(text: 'CHATS'),
            Tab(text: 'STATUS'),
            Tab(text: 'CALLS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _controller,

        children: [
          Center(child: Text('Camera')),
          ChatPage(),
          Center(child: Text('Status')),
          Center(child: Text('Calls')),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 248, 241, 178),
    );
  }
}
