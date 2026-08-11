import 'package:flutter/material.dart';

class UserModel {
  final String username;
  final String password;
  final String status;
  final Color color;

  UserModel({
    required this.username,
    required this.password,
    this.status = 'Hey there! I am using Trillion Chats',
    Color? color,
  }) : color = color ?? _colorFor(username);

  static const List<Color> _palette = [
    Color(0xFFE91E63),
    Color(0xFF3F51B5),
    Color(0xFF00BCD4),
    Color(0xFF9C27B0),
    Color(0xFFFF9800),
    Color(0xFF4CAF50),
    Color(0xFF795548),
    Color(0xFF607D8B),
  ];

  static Color _colorFor(String name) {
    var hash = 0;
    for (final c in name.codeUnits) {
      hash += c;
    }
    return _palette[hash % _palette.length];
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'] as String,
      password: json['password'] as String,
      status: json['status'] as String? ??
          'Hey there! I am using Trillion Chats',
      color: json['color'] is int
          ? Color(json['color'] as int)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
        'status': status,
        'color': color.toARGB32(),
      };
}
