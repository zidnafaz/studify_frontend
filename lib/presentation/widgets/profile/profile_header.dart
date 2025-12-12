import 'package:flutter/material.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../data/models/user_model.dart';

class ProfileHeader extends StatelessWidget {
  final User? user;

  const ProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final name = user?.name ?? AppLocalizations.of(context)!.guestUser;
    final email = user?.email ?? AppLocalizations.of(context)!.noEmail;
    final initials = name.isNotEmpty
        ? name
              .split(' ')
              .take(2)
              .map((word) => word.isNotEmpty ? word[0] : '')
              .join()
              .toUpperCase()
        : '?';

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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: colorScheme.primary.withOpacity(0.1),
              child: Text(
                initials,
                style: TextStyle(
                  color: colorScheme.primary,
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
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
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
