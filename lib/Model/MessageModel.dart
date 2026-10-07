enum MessageType { text, image, document, location, contact, poll, audio }

class MessageModel {
  final String text;
  final String time;
  final bool isSentByMe;
  bool read;
  final MessageType type;
  final String? mediaPath;

  MessageModel({
    required this.text,
    required this.time,
    this.isSentByMe = true,
    this.read = true,
    this.type = MessageType.text,
    this.mediaPath,
  });
}
