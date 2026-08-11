import 'package:flutter/material.dart';
import 'package:flutter_application_1/CustomUI/StoryCard.dart';
import 'package:flutter_application_1/Model/StatusModel.dart';
import 'package:flutter_application_1/Screens/ViewStatus.dart';
import 'package:flutter_application_1/State/AppState.dart';
import 'package:flutter_application_1/Theme/AppColors.dart';

class StatusPage extends StatelessWidget {
  const StatusPage({super.key});

  Widget _header(String title) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.chatGreen,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final statuses = AppState.instance.statuses;
        final myStatus = statuses.firstWhere((s) => s.isMyStatus);
        final recent = statuses.where((s) => !s.isMyStatus && !s.isSeen).toList();
        final viewed = statuses.where((s) => !s.isMyStatus && s.isSeen).toList();

        void openStatus(StatusModel status, int index, List<StatusModel> list) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewStatus(
                statuses: list,
                initialIndex: index,
              ),
            ),
          );
        }

        return ListView(
          children: [
            StoryCard(
              status: myStatus,
              onTap: () => openStatus(myStatus, 0, [myStatus]),
            ),
            if (recent.isNotEmpty) ...[
              _header('Recent updates'),
              for (var i = 0; i < recent.length; i++)
                StoryCard(status: recent[i], onTap: () => openStatus(recent[i], i, recent)),
            ],
            if (viewed.isNotEmpty) ...[
              _header('Viewed updates'),
              for (var i = 0; i < viewed.length; i++)
                StoryCard(status: viewed[i], onTap: () => openStatus(viewed[i], i, viewed)),
            ],
          ],
        );
      },
    );
  }
}
