import 'package:flutter/material.dart';

class StatusModel {
  final String name;
  String time;
  final Color color;
  final List<Color> gradient;
  final bool isMyStatus;
  bool isSeen;
  String? content;

  StatusModel({
    required this.name,
    required this.time,
    required this.color,
    required this.gradient,
    this.isMyStatus = false,
    this.isSeen = false,
    this.content,
  });
}
