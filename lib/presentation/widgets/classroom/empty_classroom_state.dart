import 'package:flutter/material.dart';
import '../../../core/constants/app_color.dart';

class EmptyClassroomState extends StatelessWidget {
  const EmptyClassroomState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.class_outlined,
            size: 80,
            color: AppColor.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada classroom',
            style: TextStyle(
              fontSize: 16,
              color: AppColor.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap tombol + untuk membuat classroom baru',
            style: TextStyle(
              fontSize: 14,
              color: AppColor.textSecondary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
