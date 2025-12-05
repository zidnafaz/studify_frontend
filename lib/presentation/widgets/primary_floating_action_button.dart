import 'package:flutter/material.dart';

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
    final colorScheme = Theme.of(context).colorScheme;

    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: colorScheme.primary,
      tooltip: tooltip,
      shape: const CircleBorder(),
      child: Icon(icon, color: colorScheme.onPrimary),
    );
  }
}
