import 'package:flutter/material.dart';
import 'package:flutter_application_1/Model/ContactModel.dart';
import 'package:flutter_application_1/Theme/AppColors.dart';
import 'AppAvatar.dart';

class ContactCard extends StatelessWidget {
  final ContactModel contact;
  final bool selected;
  final VoidCallback? onTap;
  final bool showCheck;

  const ContactCard({
    super.key,
    required this.contact,
    this.selected = false,
    this.onTap,
    this.showCheck = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: selected ? AppColors.menu.withValues(alpha: 0.35) : null,
        child: ListTile(
          leading: AppAvatar(
            name: contact.name,
            isGroup: false,
            color: contact.color,
            radius: 24,
          ),
          title: Text(
            contact.name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            contact.status,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14),
          ),
          trailing: showCheck
              ? Icon(
                  selected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: selected ? AppColors.whatsappGreen : AppColors.grey,
                )
              : null,
        ),
      ),
    );
  }
}
