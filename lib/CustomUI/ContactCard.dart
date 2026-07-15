import 'package:flutter/material.dart';

class ContactCard extends StatefulWidget {
  const ContactCard({required Key key}) : super(key: key);

  @override
  _ContactCardState createState() => _ContactCardState();
}

class _ContactCardState extends State<ContactCard> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: Color.fromARGB(255, 94, 84, 2),
        child: Icon(Icons.person, color: Colors.white),
      ),
      title: Text(
        "Contact Name",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      subtitle: Text("Last message preview"),
    );
  }
}
