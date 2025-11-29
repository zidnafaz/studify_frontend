import 'package:flutter/material.dart';

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
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
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
                      backgroundColor: colorScheme.primary.withOpacity(0.1),
                      child: Icon(item.icon, color: colorScheme.primary),
                    ),
                    title: Text(
                      item.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    subtitle: item.subtitle is Widget
                        ? item.subtitle
                        : Text(
                            item.subtitle,
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
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
                      color: colorScheme.onSurfaceVariant.withOpacity(0.2),
                    ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}
