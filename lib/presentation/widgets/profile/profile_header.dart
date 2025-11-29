import 'package:flutter/material.dart';
import 'package:studify/core/constants/app_color.dart';
import '../../../data/models/user_model.dart';

class ProfileHeader extends StatelessWidget {
  final User? user;

  const ProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final name = user?.name ?? 'Guest User';
    final email = user?.email ?? 'No email';
    final initials = name.isNotEmpty
        ? name
              .split(' ')
              .take(2)
              .map((word) => word.isNotEmpty ? word[0] : '')
              .join()
              .toUpperCase()
        : '?';

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1D29) : AppColor.backgroundSecondary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
        border: isDark
            ? Border.all(color: Colors.white.withOpacity(0.1))
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: AppColor.primary.withOpacity(0.1),
              child: Text(
                initials,
                style: const TextStyle(
                  color: AppColor.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColor.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColor.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
