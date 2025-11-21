import 'package:flutter/material.dart';
import '../../core/constants/app_color.dart';

class PrimaryFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? tooltip;

  const PrimaryFloatingActionButton({
    super.key,
    required this.onPressed,
    this.icon = Icons.add,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: AppColor.primary,
      tooltip: tooltip,
      shape: const CircleBorder(),
      child: Icon(icon, color: AppColor.backgroundSecondary),
    );
  }
}
