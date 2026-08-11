import 'package:flutter/material.dart';
import 'package:flutter_application_1/Model/StatusModel.dart';
import 'package:flutter_application_1/Theme/AppColors.dart';
import 'AppAvatar.dart';

class StoryCard extends StatelessWidget {
  final StatusModel status;
  final VoidCallback onTap;

  const StoryCard({super.key, required this.status, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            if (status.isMyStatus)
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  AppAvatar(
                    name: status.name,
                    isGroup: false,
                    color: status.color,
                    radius: 26,
                  ),
                  const CircleAvatar(
                    radius: 10,
                    backgroundColor: AppColors.whatsappGreen,
                    child: Icon(Icons.add, size: 15, color: Colors.white),
                  ),
                ],
              )
            else
              StoryRing(
                seen: status.isSeen,
                child: AppAvatar(
                  name: status.name,
                  isGroup: false,
                  color: status.color,
                  radius: 26,
                ),
              ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    status.time,
                    style: const TextStyle(fontSize: 13, color: AppColors.grey),
                  ),
                ],
              ),
            ),
            if (status.isMyStatus)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.photo_camera,
                      color: AppColors.whatsappGreen, size: 22),
                  SizedBox(width: 20),
                  Icon(Icons.edit, color: AppColors.whatsappGreen, size: 22),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
