import 'package:flutter/material.dart';

class CallModel {
  final String name;
  final String time;
  final bool isVideo;
  final bool isIncoming;
  final bool isMissed;
  final Color color;

  const CallModel({
    required this.name,
    required this.time,
    required this.isVideo,
    required this.isIncoming,
    required this.isMissed,
    required this.color,
  });
}
