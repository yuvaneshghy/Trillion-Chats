class MessageModel {
  final String text;
  final String time;
  final bool isSentByMe;
  bool read;

  MessageModel({
    required this.text,
    required this.time,
    this.isSentByMe = true,
    this.read = true,
  });
}
