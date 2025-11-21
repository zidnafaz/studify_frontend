import 'package:flutter/material.dart';

import '../../core/constants/app_color.dart';
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
                  initialValue: _profile.name.isEmpty ? 'Guest User' : _profile.name,
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    helperText: 'Edit via the Edit Profile button',
                  ),
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
          phone: phoneController.text.trim(),
          role: roleValue,
        );
        ProfileStore.instance.save(_profile);
      });
      _showMessage('Personal details updated');
    }
  }

  Future<void> _openSecuritySheet() async {
    final currentPassword = TextEditingController();
    final newPassword = TextEditingController();
    final confirmPassword = TextEditingController();
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
                      'Security',
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
                  controller: currentPassword,
                  decoration: const InputDecoration(
                    labelText: 'Current password',
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Current password is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: newPassword,
                  decoration: const InputDecoration(
                    labelText: 'New password',
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Password should be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: confirmPassword,
                  decoration: const InputDecoration(
                    labelText: 'Confirm new password',
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value != newPassword.text) {
                      return 'Passwords do not match';
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
                    child: const Text('Update password'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (saved == true) {
      _showMessage('Password updated securely');
    }
  }

  Future<void> _openNotificationsSheet() async {
    bool assignment = _profile.assignmentNotif;
    bool reminder = _profile.reminderNotif;
    bool classUpdate = _profile.classUpdateNotif;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Notifications',
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
                  SwitchListTile(
                    title: const Text('Assignment reminders'),
                    subtitle: const Text('Due dates and new tasks'),
                    value: assignment,
                    onChanged: (value) => setModalState(() => assignment = value),
                  ),
                  SwitchListTile(
                    title: const Text('Daily productivity tips'),
                    subtitle: const Text('Personalized guidance'),
                    value: reminder,
                    onChanged: (value) => setModalState(() => reminder = value),
                  ),
                  SwitchListTile(
                    title: const Text('Class updates'),
                    subtitle: const Text('Announcements from mentors'),
                    value: classUpdate,
                    onChanged: (value) => setModalState(() => classUpdate = value),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(bottomSheetContext).pop(true),
                      child: const Text('Save preferences'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (saved == true) {
      setState(() {
        _profile = _profile.copyWith(
          assignmentNotif: assignment,
          reminderNotif: reminder,
          classUpdateNotif: classUpdate,
        );
        ProfileStore.instance.save(_profile);
      });
      _showMessage('Notification preferences saved');
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
      
      _showMessage('Signed out successfully');
    }
  }

  @override
  Widget build(BuildContext context) {
    final interests = [
      'Mathematics',
      'Productivity',
      'UI/UX',
      'AI Research',
      'Writing'
    ];

    final stats = [
      _ProfileStat(label: 'Classes', value: '8'),
      _ProfileStat(label: 'Assignments', value: '21'),
      _ProfileStat(label: 'Streak', value: '17d'),
    ];

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
                        IconButton(
                          tooltip: 'Edit profile',
                          onPressed: _openEditProfileSheet,
                          icon: const Icon(Icons.edit_outlined),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: const [
                          Icon(
                            Icons.verified_user_outlined,
                            color: AppColor.primary,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Member since January 2024',
                              style: TextStyle(
                                color: AppColor.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: stats
                  .map(
                    (stat) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _StatCard(stat: stat),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
            const Text(
              'Interests',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColor.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: interests
                      .map(
                        (interest) => Chip(
                          backgroundColor: AppColor.accent.withValues(alpha: 0.15),
                          label: Text(
                            interest,
                            style: const TextStyle(
                              color: AppColor.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                      .toList(),
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
                _ProfileItem(
                  icon: Icons.lock_outline,
                  title: 'Security',
                  subtitle: 'Password and 2FA settings',
                  onTap: _openSecuritySheet,
                ),
                _ProfileItem(
                  icon: Icons.notifications_none,
                  title: 'Notifications',
                  subtitle: 'Assignments and reminder alerts',
                  onTap: _openNotificationsSheet,
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
                  title: 'Help Center',
                  subtitle: 'FAQs and quick guides',
                ),
                _ProfileItem(
                  icon: Icons.chat_bubble_outline,
                  title: 'Contact Mentor',
                  subtitle: 'Chat with your mentor',
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

class _ProfileStat {
  final String label;
  final String value;

  const _ProfileStat({required this.label, required this.value});
}

class _StatCard extends StatelessWidget {
  final _ProfileStat stat;

  const _StatCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              stat.value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColor.primary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              stat.label,
              style: const TextStyle(
                color: AppColor.textSecondary,
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
  final String subtitle;
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
                    subtitle: Text(
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

