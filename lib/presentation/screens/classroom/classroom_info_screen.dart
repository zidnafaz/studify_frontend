import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../data/models/classroom_model.dart';
import '../../../data/models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/classroom_provider.dart';
import '../../widgets/sheets/member_detail_sheet.dart';

class ClassroomInfoScreen extends StatefulWidget {
  final Classroom classroom;

  const ClassroomInfoScreen({super.key, required this.classroom});

  @override
  State<ClassroomInfoScreen> createState() => _ClassroomInfoScreenState();
}

class _ClassroomInfoScreenState extends State<ClassroomInfoScreen> {
  Classroom? _detailedClassroom;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to ensure build phase is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchClassroomDetail();
    });
  }

  Future<void> _fetchClassroomDetail() async {
    final classroomProvider = Provider.of<ClassroomProvider>(
      context,
      listen: false,
    );

    setState(() {
      _isLoading = true;
    });

    await classroomProvider.fetchClassroom(widget.classroom.id);

    if (mounted) {
      setState(() {
        _detailedClassroom = classroomProvider.selectedClassroom;
        _isLoading = false;
      });
    }
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  String _getMemberRole(User user) {
    final classroom = _detailedClassroom ?? widget.classroom;
    if (user.id == classroom.ownerId) {
      return 'Owner';
    }
    if (user.isCoordinator == true) {
      return 'Coordinator';
    }
    return 'Member';
  }

  Future<void> _showEditDescriptionDialog(BuildContext context) async {
    final classroom = _detailedClassroom ?? widget.classroom;
    final controller = TextEditingController(text: classroom.description);
    final colorScheme = Theme.of(context).colorScheme;

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Edit Description',
          style: TextStyle(color: colorScheme.onSurface),
        ),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Enter classroom description',
            hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
            filled: true,
            fillColor: colorScheme.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          style: TextStyle(color: colorScheme.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _updateDescription(controller.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateDescription(String description) async {
    final classroomProvider = Provider.of<ClassroomProvider>(
      context,
      listen: false,
    );
    final classroom = _detailedClassroom ?? widget.classroom;

    try {
      await classroomProvider.updateClassroomDescription(
        classroomId: classroom.id,
        description: description,
      );

      if (mounted) {
        setState(() {
          _detailedClassroom = classroomProvider.selectedClassroom;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Description updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update description: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showLeaveClassroomDialog(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Leave Classroom',
          style: TextStyle(color: colorScheme.onSurface),
        ),
        content: Text(
          'Are you sure you want to leave this classroom? You will need the classroom code to join again.',
          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/classroomList',
                (route) => false,
              );

              await _leaveClassroom();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }

  Future<void> _leaveClassroom() async {
    final classroomProvider = Provider.of<ClassroomProvider>(
      context,
      listen: false,
    );
    final classroom = _detailedClassroom ?? widget.classroom;

    try {
      await classroomProvider.leaveClassroom(classroom.id);

      if (mounted) {
        Navigator.pop(context); // Go back to classroom list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Left classroom successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to leave classroom: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
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
                child: Stack(
                  children: [
                    Positioned(
                      left: 8,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: colorScheme.onPrimary,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 48),
                        child: Text(
                          'Classroom Detail',
                          style: TextStyle(
                            color: colorScheme.onPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Center(
          child: CircularProgressIndicator(color: colorScheme.primary),
        ),
      );
    }

    return Consumer<ClassroomProvider>(
      builder: (context, classroomProvider, child) {
        final classroom =
            classroomProvider.selectedClassroom ??
            _detailedClassroom ??
            widget.classroom;
        final authProvider = Provider.of<AuthProvider>(context);
        final currentUserId = authProvider.user?.id ?? 0;
        final isOwner = classroom.ownerId == currentUserId;

        // Sort users: owner first, then coordinators, then members
        final sortedUsers = List<User>.from(classroom.users ?? []);
        sortedUsers.sort((a, b) {
          // Owner always first
          if (a.id == classroom.ownerId) return -1;
          if (b.id == classroom.ownerId) return 1;

          // Then coordinators
          final aIsCoordinator = a.isCoordinator == true;
          final bIsCoordinator = b.isCoordinator == true;
          if (aIsCoordinator && !bIsCoordinator) return -1;
          if (!aIsCoordinator && bIsCoordinator) return 1;

          // Then by name
          return a.name.compareTo(b.name);
        });

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
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          child: IconButton(
                            icon: Icon(
                              Icons.arrow_back,
                              color: colorScheme.onPrimary,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        Center(
                          child: Text(
                            'Classroom Detail',
                            style: TextStyle(
                              color: colorScheme.onPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Classroom Code & Description Section
                Container(
                  padding: const EdgeInsets.all(16),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Classroom Code
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Classroom Code',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.onSurface.withOpacity(
                                      0.6,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  classroom.uniqueCode,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.primary,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                _copyToClipboard(context, classroom.uniqueCode),
                            icon: Icon(Icons.copy, color: colorScheme.primary),
                            tooltip: 'Copy code',
                          ),
                        ],
                      ),

                      // Separator
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Divider(
                          color: colorScheme.onSurface.withOpacity(0.1),
                          thickness: 1,
                          height: 1,
                        ),
                      ),

                      // Description
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          if (isOwner)
                            IconButton(
                              onPressed: () =>
                                  _showEditDescriptionDialog(context),
                              icon: const Icon(Icons.edit, size: 20),
                              color: colorScheme.primary,
                              tooltip: 'Edit description',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        classroom.description ?? 'No description',
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // List of Members Header
                Text(
                  'List of Members',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onBackground,
                  ),
                ),

                const SizedBox(height: 12),

                // Members List
                Container(
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
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: sortedUsers.length,
                    separatorBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Divider(
                        color: colorScheme.onSurface.withOpacity(0.1),
                        thickness: 1,
                        height: 1,
                      ),
                    ),
                    itemBuilder: (context, index) {
                      final user = sortedUsers[index];
                      final role = _getMemberRole(user);

                      return InkWell(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => MemberDetailSheet(
                              user: user,
                              role: role,
                              isOwner: isOwner,
                              classroom: classroom,
                              onMemberUpdated: () {
                                // Refresh classroom data after member update
                                _fetchClassroomDetail();
                              },
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              // Avatar
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: colorScheme.primary
                                    .withOpacity(0.1),
                                child: Text(
                                  user.name[0].toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Name and Role
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      role,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: role == 'Owner'
                                            ? colorScheme.primary
                                            : role == 'Coordinator'
                                            ? colorScheme.tertiary
                                            : colorScheme.onSurface.withOpacity(
                                                0.6,
                                              ),
                                        fontWeight: role == 'Owner'
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Leave Classroom Button (only for non-owners)
                if (!isOwner) ...[
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _showLeaveClassroomDialog(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.error,
                        side: BorderSide(color: colorScheme.error, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.exit_to_app, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Leave Classroom',
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
        );
      },
    );
  }
}
