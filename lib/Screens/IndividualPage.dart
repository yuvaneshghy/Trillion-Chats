import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Model/ChatModel.dart';
import 'package:flutter_svg/flutter_svg.dart';

class IndividualPage extends StatelessWidget {
  final ChatModel chatModel;

  const IndividualPage({super.key, required this.chatModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 230, 2),
        // Add padding to the right
        leadingWidth: 100,

        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.arrow_back, size: 30, color: Colors.black),

              CircleAvatar(
                radius: 30,
                backgroundColor: Color.fromARGB(255, 94, 84, 2),
                child: SvgPicture.asset(
                  chatModel.isGroup ? "Assets/Groups.svg" : "Assets/Person.svg",
                  color: const Color.fromARGB(255, 255, 255, 255),
                  height: 35,
                  width: 35,
                ),
              ),
            ],
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              chatModel.name,
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
            SizedBox(height: 3),
            Text(
              "Last seen at ${chatModel.time}",
              style: TextStyle(fontSize: 13, color: Colors.black),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.video_call, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.call, color: Colors.black),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              // Handle menu item selection
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'View Contact',
                  child: Text('View Contact'),
                ),
                PopupMenuItem<String>(
                  value: 'Media, Links, and Docs',
                  child: Text('Media, Links, and Docs'),
                ),
                PopupMenuItem<String>(value: 'Search', child: Text('Search')),
                PopupMenuItem<String>(
                  value: 'Mute Notifications',
                  child: Text('Mute Notifications'),
                ),
                PopupMenuItem<String>(
                  value: 'Wallpaper',
                  child: Text('Wallpaper'),
                ),
                PopupMenuItem<String>(value: 'More', child: Text('More')),
              ];
            },
          ),
        ],
      ),
      body: Container(
        color: Color.fromARGB(255, 248, 241, 178),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,

        child: Stack(
          children: [
            ListView(),
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 60,
                        //height: 100,
                        child: Card(
                          margin: EdgeInsets.only(left: 2, right: 2, bottom: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: TextFormField(
                            textAlignVertical: TextAlignVertical.center,
                            keyboardType: TextInputType.multiline,
                            maxLines: 5,
                            minLines: 1,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Type a message",
                              contentPadding: EdgeInsets.only(left: 20),
                              //border: InputBorder.none,
                              prefixIcon: IconButton(
                                icon: Icon(Icons.emoji_emotions),
                                onPressed: () {},
                              ),
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.attach_file),
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (Builder)=>);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.camera_alt),
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 8,
                          right: 5,
                          left: 5,
                        ),
                        child: CircleAvatar(
                          radius: 25,
                          backgroundColor: Color.fromARGB(255, 255, 230, 0),
                          child: IconButton(
                            icon: Icon(Icons.mic),
                            onPressed: () {},
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget bottomsheet(){
    return container();
  }
  
  Widget EmojiSelect() {
    return EmojiPicker(
      onEmojiSelected: (category, emoji) {
        print(emoji);
      },
    );
  }
}
