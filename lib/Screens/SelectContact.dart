import 'package:flutter/material.dart';

class SelectContact extends StatefulWidget {
  @override
  _SelectContactState createState() => _SelectContactState();
}

class _SelectContactState extends State<SelectContact> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 230, 2),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select Contact",
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 3),
            Text("4 contacts", style: TextStyle(fontSize: 13)),
          ],
        ),

        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            color: Color.fromARGB(221, 255, 187, 0),
            onSelected: (value) {
              print(value);
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: "Invite a friend",
                  child: Text("Invite a friend"),
                ),
                PopupMenuItem(value: "Contacts", child: Text("Contacts")),
                PopupMenuItem(value: "Refresh", child: Text("Refresh")),
                PopupMenuItem(value: "Help", child: Text("Help")),
              ];
            },
          ),
        ],
      ),
    );
  }
}
