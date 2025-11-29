import 'package:flutter/material.dart';
import 'package:studify/core/constants/app_color.dart';

class ProfileMenuItem {
  final IconData icon;
  final String title;
  final dynamic subtitle; // Can be String or Widget
  final VoidCallback? onTap;

  const ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });
}

class ProfileMenuSection extends StatelessWidget {
  final List<ProfileMenuItem> items;
  final void Function(String title)? onItemTap;

  const ProfileMenuSection({super.key, required this.items, this.onItemTap});

  @override
  Widget build(BuildContext context) {
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
      child: Column(
        children: items
            .map(
              (item) => Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColor.primary.withOpacity(0.1),
                      child: Icon(item.icon, color: AppColor.primary),
                    ),
                    title: Text(
                      item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColor.textPrimary,
                      ),
                    ),
                    subtitle: item.subtitle is Widget
                        ? item.subtitle
                        : Text(
                            item.subtitle,
                            style: const TextStyle(
                              color: AppColor.textSecondary,
                            ),
                          ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap:
                        item.onTap ??
                        () {
                          if (onItemTap != null) {
                            onItemTap!(item.title);
                          }
                        },
                  ),
                  if (item != items.last)
                    Divider(
                      indent: 72,
                      height: 0,
                      color: AppColor.textSecondary.withOpacity(0.2),
                    ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}
