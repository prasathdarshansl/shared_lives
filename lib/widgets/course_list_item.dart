import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CourseListItem extends StatelessWidget {
  final String title;
  final String subtitle;

  const CourseListItem({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 1,
      child: ListTile(
        dense: true,
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryBlue.withOpacity(0.08),
          child: const Icon(Icons.menu_book, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 13),
        ),
      ),
    );
  }
}
