import 'package:flutter/material.dart';
import '../../../core/constants/app_color.dart';
import '../../../data/models/classroom_model.dart';

class ClassroomCard extends StatelessWidget {
  final Classroom classroom;
  final VoidCallback? onTap;

  const ClassroomCard({super.key, required this.classroom, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.backgroundSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColor.textSecondary.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  classroom.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColor.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  classroom.description ?? 'Tidak ada deskripsi',
                  style: TextStyle(fontSize: 14, color: AppColor.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
