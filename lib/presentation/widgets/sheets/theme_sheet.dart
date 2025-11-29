import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_color.dart';
import '../../../providers/theme_provider.dart';

class ThemeSheet extends StatelessWidget {
  const ThemeSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColor.backgroundSecondary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColor.textSecondary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Theme',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColor.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                _buildThemeOption(
                  context,
                  title: 'Light',
                  icon: Icons.light_mode,
                  isSelected: themeProvider.themeMode == ThemeMode.light,
                  onTap: () {
                    themeProvider.setThemeMode(ThemeMode.light);
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 12),
                _buildThemeOption(
                  context,
                  title: 'Dark',
                  icon: Icons.dark_mode,
                  isSelected: themeProvider.themeMode == ThemeMode.dark,
                  onTap: () {
                    themeProvider.setThemeMode(ThemeMode.dark);
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 12),
                _buildThemeOption(
                  context,
                  title: 'System',
                  icon: Icons.brightness_auto,
                  isSelected: themeProvider.themeMode == ThemeMode.system,
                  onTap: () {
                    themeProvider.setThemeMode(ThemeMode.system);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColor.primary.withOpacity(0.1)
              : AppColor.backgroundPrimary,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: AppColor.primary)
              : Border.all(color: Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColor.primary : AppColor.textSecondary,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColor.primary : AppColor.textPrimary,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColor.primary),
          ],
        ),
      ),
    );
  }
}
