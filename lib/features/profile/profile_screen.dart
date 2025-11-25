import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_color.dart';
import '../../providers/theme_provider.dart';
import 'profile_store.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late ProfileData _profile;

  @override
  void initState() {
    super.initState();
    _profile = ProfileStore.instance.data;
  }

  void _showComingSoon(BuildContext context, String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$featureName coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _openEditProfileSheet() async {
    final nameController = TextEditingController(text: _profile.name);
    final emailController = TextEditingController(text: _profile.email);
    final formKey = GlobalKey<FormState>();

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(bottomSheetContext).pop(false),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!value.contains('@')) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        Navigator.of(bottomSheetContext).pop(true);
                      }
                    },
                    child: const Text('Save changes'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (saved == true) {
      setState(() {
        _profile = _profile.copyWith(
          name: nameController.text.trim(),
          email: emailController.text.trim(),
        );
        ProfileStore.instance.save(_profile);
      });
      _showMessage('Profile updated');
    }
  }

  Future<void> _openPersonalDetailsSheet() async {
    final phoneController = TextEditingController(text: _profile.phone);
    final nameController = TextEditingController(text: _profile.name);
    String roleValue = _profile.role.isEmpty ? 'Student' : _profile.role;
    final formKey = GlobalKey<FormState>();

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Personal Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(bottomSheetContext).pop(false),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Phone number is required';
                    }
                    if (value.trim().length < 8) {
                      return 'Enter a valid phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: roleValue,
                  items: const [
                    DropdownMenuItem(value: 'Student', child: Text('Student')),
                    DropdownMenuItem(value: 'Class President', child: Text('Class President')),
                    DropdownMenuItem(value: 'Course coordinator', child: Text('Course coordinator')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Role',
                  ),
                  onChanged: (value) {
                    if (value != null) {
                      roleValue = value;
                    }
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        Navigator.of(bottomSheetContext).pop(true);
                      }
                    },
                    child: const Text('Save details'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (saved == true) {
      setState(() {
        _profile = _profile.copyWith(
          name: nameController.text.trim(),
          phone: phoneController.text.trim(),
          role: roleValue,
        );
        ProfileStore.instance.save(_profile);
      });
      _showMessage('Personal details updated');
    }
  }

  Future<void> _openThemeSheet() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    final selectedTheme = await showModalBottomSheet<ThemeMode>(
      context: context,
      builder: (bottomSheetContext) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Theme',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(bottomSheetContext).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.light_mode),
                title: const Text('Light'),
                trailing: themeProvider.themeMode == ThemeMode.light
                    ? const Icon(Icons.check)
                    : null,
                onTap: () => Navigator.of(bottomSheetContext).pop(ThemeMode.light),
              ),
              ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text('Dark'),
                trailing: themeProvider.themeMode == ThemeMode.dark
                    ? const Icon(Icons.check)
                    : null,
                onTap: () => Navigator.of(bottomSheetContext).pop(ThemeMode.dark),
              ),
              ListTile(
                leading: const Icon(Icons.brightness_auto),
                title: const Text('System'),
                trailing: themeProvider.themeMode == ThemeMode.system
                    ? const Icon(Icons.check)
                    : null,
                onTap: () => Navigator.of(bottomSheetContext).pop(ThemeMode.system),
              ),
            ],
          ),
        );
      },
    );

    if (selectedTheme != null) {
      await themeProvider.setThemeMode(selectedTheme);
      _showMessage('Theme updated');
    }
  }

  Future<void> _contactAdmin() async {
    const adminEmail = 'admin@studify.app';
    const subject = 'FAQ - Studify App';
    const body = 'Hi admin, I need help with:';
    
    final uri = Uri(
      scheme: 'mailto',
      path: adminEmail,
      query: 'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );
    
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showMessage('Unable to open email app');
      }
    } catch (e) {
      _showMessage('Error: Unable to contact admin');
    }
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Sign out'),
          content: const Text('Are you sure you want to sign out of Studify?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Sign out'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      ProfileStore.instance.reset();
      setState(() {
        _profile = ProfileStore.instance.data;
      });
      if (!mounted) return;
      
      // Navigate to welcome screen (login/register page)
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/welcome',
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: AppColor.secondary.withValues(alpha: 0.25),
                          child: Text(
                            _profile.name.isEmpty
                                ? '?'
                                : _profile.name
                                    .split(' ')
                                    .take(2)
                                    .map((word) => word.isNotEmpty ? word[0] : '')
                                    .join()
                                    .toUpperCase(),
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
                                _profile.name.isEmpty ? 'Guest User' : _profile.name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _profile.email.isEmpty ? 'No email' : _profile.email,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColor.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _profile.phone.isEmpty ? 'No phone' : _profile.phone,
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
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Account',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColor.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            _ProfileSection(
              items: [
                _ProfileItem(
                  icon: Icons.person_outline,
                  title: 'Personal Details',
                  subtitle: 'Name, phone number, and role',
                  onTap: _openPersonalDetailsSheet,
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Settings',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColor.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            _ProfileSection(
              items: [
                _ProfileItem(
                  icon: Icons.palette_outlined,
                  title: 'Theme',
                  subtitle: 'Light/Dark theme settings',
                  onTap: _openThemeSheet,
                ),
                _ProfileItem(
                  icon: Icons.info_outline,
                  title: 'Version',
                  subtitle: 'v1.0.0',
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Support',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColor.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            _ProfileSection(
              items: [
                _ProfileItem(
                  icon: Icons.help_outline,
                  title: 'FAQ',
                  subtitle: 'Contact admin for help',
                  onTap: _contactAdmin,
                ),
                _ProfileItem(
                  icon: Icons.feedback_outlined,
                  title: 'Send Feedback',
                  subtitle: 'Tell us how we can improve Studify',
                ),
              ],
              onItemTap: (title) => _showComingSoon(context, title),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColor.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _signOut,
                icon: const Icon(Icons.logout, color: AppColor.primary),
                label: const Text(
                  'Sign Out',
                  style: TextStyle(
                    color: AppColor.primary,
                    fontWeight: FontWeight.w600,
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

class _ProfileItem {
  final IconData icon;
  final String title;
  final dynamic subtitle; // Can be String or Widget
  final VoidCallback? onTap;

  const _ProfileItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });
}

class _ProfileSection extends StatelessWidget {
  final List<_ProfileItem> items;
  final void Function(String title)? onItemTap;

  const _ProfileSection({
    required this.items,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        children: items
            .map(
              (item) => Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColor.primary.withValues(alpha: 0.08),
                      child: Icon(
                        item.icon,
                        color: AppColor.primary,
                      ),
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
                    onTap: item.onTap ??
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
                      color: Colors.grey.shade200,
                    ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}

