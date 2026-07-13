import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_application_1/Model/ChatModel.dart';
import '../Screens/IndividualPage.dart';

class CustomCard extends StatelessWidget {
  const CustomCard({super.key, required this.chatModel});
  final ChatModel chatModel;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => IndividualPage(chatModel: chatModel),
          ),
        );
      },
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              radius: 30,
              backgroundColor: Color.fromARGB(255, 94, 84, 2),
              child: SvgPicture.asset(
                chatModel.isGroup ? "Assets/Groups.svg" : "Assets/Person.svg",
                color: Colors.white,
                height: 35,
                width: 35,
              ),
            ),
            trailing: Text(chatModel.time),
            title: Text(
              chatModel.name,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            subtitle: Row(
              children: [
                Icon(Icons.done_all, color: Colors.blueAccent),
                SizedBox(width: 3),
                Text(chatModel.currentMessage, style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.only(left: 80, right: 20),
          //   child: Divider(thickness: 1.6),
          // ),
        ],
      ),
    );
  }
}
