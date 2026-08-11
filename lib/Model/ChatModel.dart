import 'package:flutter/material.dart';
import 'MessageModel.dart';

class ChatModel {
  final String name;
  final bool isGroup;
  final Color avatarColor;
  final List<MessageModel> messages;
  String lastSeen;
  bool muted;
  bool pinned;
  int unreadCount;
  double lastTs;

  ChatModel({
    required this.name,
    required this.isGroup,
    required this.messages,
    this.avatarColor = const Color(0xFF5E5402),
    this.lastSeen = 'online',
    this.muted = false,
    this.pinned = false,
    this.unreadCount = 0,
    this.lastTs = 0,
  });

  String get lastMessage {
    if (messages.isEmpty) return '';
    final last = messages.last;
    return last.isSentByMe ? 'You: ${last.text}' : last.text;
  }

  String get lastTime => messages.isEmpty ? '' : messages.last.time;
}
