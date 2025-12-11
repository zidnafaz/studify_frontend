import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../widgets/profile/profile_header.dart';
import '../../widgets/profile/profile_menu_item.dart';
import '../../widgets/sheets/personal_details_sheet.dart';
import '../../widgets/sheets/theme_sheet.dart';
import '../../widgets/sheets/language_sheet.dart';
import '../../../l10n/generated/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch latest user data when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().checkAuthStatus();
    });
  }

  void _showComingSoon(BuildContext context, String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.comingSoon(featureName)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _openPersonalDetailsSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PersonalDetailsSheet(),
    );
  }

  Future<void> _openThemeSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ThemeSheet(),
    );
  }

  Future<void> _openLanguageSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LanguageSheet(),
    );
  }

  Future<void> _contactAdmin() async {
    _showComingSoon(context, AppLocalizations.of(context)!.faq);
  }

  Future<void> _sendFeedback() async {
    _showComingSoon(context, AppLocalizations.of(context)!.sendFeedback);
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.signOut),
          content: Text(AppLocalizations.of(context)!.signOutConfirmation),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(AppLocalizations.of(context)!.signOut),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      if (!mounted) return;
      final authProvider = context.read<AuthProvider>();
      await authProvider.logout();

      if (!mounted) return;

      // Navigate to welcome screen (login/register page)
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil('/welcome', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final colorScheme = Theme.of(context).colorScheme;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(88),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: SafeArea(
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.profile,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileHeader(user: user),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.account,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            ProfileMenuSection(
              items: [
                ProfileMenuItem(
                  icon: Icons.person_outline,
                  title: AppLocalizations.of(context)!.personalDetails,
                  subtitle: AppLocalizations.of(context)!.nameAndEmail,
                  onTap: _openPersonalDetailsSheet,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.settings,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            ProfileMenuSection(
              items: [
                ProfileMenuItem(
                  icon: Icons.palette_outlined,
                  title: AppLocalizations.of(context)!.theme,
                  subtitle: AppLocalizations.of(context)!.themeSubtitle,
                  onTap: _openThemeSheet,
                ),
                ProfileMenuItem(
                  icon: Icons.language,
                  title: AppLocalizations.of(context)!.language,
                  subtitle: AppLocalizations.of(context)!.changeLanguage,
                  onTap: _openLanguageSheet,
                ),
                ProfileMenuItem(
                  icon: Icons.info_outline,
                  title: AppLocalizations.of(context)!.version,
                  subtitle: 'v1.0.0',
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.support,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            ProfileMenuSection(
              items: [
                ProfileMenuItem(
                  icon: Icons.help_outline,
                  title: AppLocalizations.of(context)!.faq,
                  subtitle: AppLocalizations.of(context)!.contactAdmin,
                  onTap: _contactAdmin,
                ),
                ProfileMenuItem(
                  icon: Icons.feedback_outlined,
                  title: AppLocalizations.of(context)!.sendFeedback,
                  subtitle: AppLocalizations.of(context)!.feedbackSubtitle,
                  onTap: _sendFeedback,
                ),
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: Theme.of(context).brightness == Brightness.dark
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.error,
                    foregroundColor: colorScheme.onError,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _signOut,
                  icon: const Icon(Icons.logout),
                  label: Text(
                    AppLocalizations.of(context)!.signOut,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
