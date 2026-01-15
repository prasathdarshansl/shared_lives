import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class InfoPage extends StatelessWidget {
  final String title;
  final String body;

  const InfoPage({
    super.key,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.primaryBlue,
      ),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          body,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
