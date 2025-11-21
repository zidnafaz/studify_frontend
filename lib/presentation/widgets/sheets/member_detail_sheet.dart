import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_color.dart';
import '../../../data/models/classroom_model.dart';
import '../../../data/models/user_model.dart';
import '../../../providers/classroom_provider.dart';

class MemberDetailSheet extends StatelessWidget {
  final User user;
  final String role;
  final bool isOwner;
  final Classroom classroom;
  final VoidCallback? onMemberUpdated;

  const MemberDetailSheet({
    super.key,
    required this.user,
    required this.role,
    required this.isOwner,
    required this.classroom,
    this.onMemberUpdated,
  });

  Future<void> _showTransferOwnershipDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColor.backgroundSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Transfer Ownership',
          style: TextStyle(color: AppColor.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to transfer ownership to:',
              style: TextStyle(color: AppColor.textSecondary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColor.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColor.primary.withOpacity(0.2),
                    child: Text(
                      user.name[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColor.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColor.textPrimary,
                          ),
                        ),
                        Text(
                          user.email,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColor.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'You will become a regular member after this action.',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await _transferOwnership(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Transfer'),
          ),
        ],
      ),
    );
  }

  Future<void> _transferOwnership(BuildContext context) async {
    final classroomProvider = Provider.of<ClassroomProvider>(context, listen: false);

    try {
      await classroomProvider.transferOwnership(
        classroomId: classroom.id,
        newOwnerId: user.id,
      );

      if (context.mounted) {
        Navigator.pop(context); // Close bottom sheet
        onMemberUpdated?.call(); // Trigger refresh
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ownership transferred successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to transfer ownership: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showRemoveMemberDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColor.backgroundSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Remove Member',
          style: TextStyle(color: AppColor.textPrimary, fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to remove this member?',
              style: TextStyle(color: AppColor.textSecondary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.red.withOpacity(0.2),
                    child: Text(
                      user.name[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColor.textPrimary,
                          ),
                        ),
                        Text(
                          user.email,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColor.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action cannot be undone.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await _removeMember(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Future<void> _removeMember(BuildContext context) async {
    final classroomProvider = Provider.of<ClassroomProvider>(context, listen: false);

    try {
      await classroomProvider.removeMember(
        classroomId: classroom.id,
        userId: user.id,
      );

      if (context.mounted) {
        Navigator.pop(context); // Close bottom sheet
        onMemberUpdated?.call(); // Trigger refresh
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Member removed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove member: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUserOwner = user.id == classroom.ownerId;

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
              children: [
                // Avatar
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColor.primary.withOpacity(0.1),
                  child: Text(
                    user.name[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: AppColor.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Name
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColor.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 4),

                // Email
                Text(
                  user.email,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColor.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                // Role badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: role == 'Owner'
                        ? AppColor.primary.withOpacity(0.1)
                        : role == 'Coordinator'
                            ? AppColor.accent.withOpacity(0.1)
                            : AppColor.textSecondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    role,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: role == 'Owner'
                          ? AppColor.primary
                          : role == 'Coordinator'
                              ? AppColor.accent
                              : AppColor.textSecondary,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Coordinator schedules
                if (role == 'Coordinator' && 
                    user.coordinatorSchedules != null && 
                    user.coordinatorSchedules!.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColor.accent.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColor.accent.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: AppColor.accent,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Coordinator of:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColor.accent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...user.coordinatorSchedules!.map((schedule) {
                          // Parse color from hex string
                          final colorValue = int.parse(schedule.color.replaceFirst('#', '0xFF'));
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Color(colorValue),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    schedule.title,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColor.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Owner actions
                if (isOwner && !isUserOwner) ...[
                  // Remove member button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _showRemoveMemberDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_remove, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Remove Member',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Transfer ownership button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _showTransferOwnershipDialog(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColor.primary,
                        side: const BorderSide(color: AppColor.primary, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.swap_horiz, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Transfer Ownership',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
