import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../Theme/AppColors.dart';

class AppAvatar extends StatelessWidget {
  final String name;
  final bool isGroup;
  final Color color;
  final double radius;

  const AppAvatar({
    super.key,
    required this.name,
    required this.isGroup,
    required this.color,
    this.radius = 28,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: color,
      child: isGroup
          ? SvgPicture.asset(
              'Assets/Groups.svg',
              colorFilter:
                  const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              height: radius,
              width: radius,
            )
          : Text(
              name.isEmpty ? '?' : name.substring(0, 1).toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontSize: radius * 0.75,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}

class StoryRing extends StatelessWidget {
  final Widget child;
  final bool seen;

  const StoryRing({super.key, required this.child, this.seen = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: seen
            ? null
            : const LinearGradient(
                colors: [Color(0xFF25D366), Color(0xFF128C7E)],
              ),
        color: seen ? AppColors.grey.withValues(alpha: 0.4) : null,
      ),
      child: child,
    );
  }
}
