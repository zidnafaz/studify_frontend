import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_color.dart';
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

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColor.backgroundSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Edit Description',
          style: TextStyle(color: AppColor.textPrimary),
        ),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Enter classroom description',
            hintStyle: TextStyle(
              color: AppColor.textSecondary.withOpacity(0.5),
            ),
            filled: true,
            fillColor: AppColor.backgroundPrimary,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          style: const TextStyle(color: AppColor.textPrimary),
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
              backgroundColor: AppColor.primary,
              foregroundColor: Colors.white,
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
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColor.backgroundSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Leave Classroom',
          style: TextStyle(color: AppColor.textPrimary),
        ),
        content: const Text(
          'Are you sure you want to leave this classroom? You will need the classroom code to join again.',
          style: TextStyle(color: AppColor.textSecondary),
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
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
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
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColor.backgroundPrimary,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(88),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColor.primary,
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
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 48),
                        child: Text(
                          'Classroom Detail',
                          style: TextStyle(
                            color: Colors.white,
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
        body: const Center(
          child: CircularProgressIndicator(color: AppColor.primary),
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
          backgroundColor: AppColor.backgroundPrimary,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(88),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: SafeArea(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColor.primary,
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
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const Center(
                          child: Text(
                            'Classroom Detail',
                            style: TextStyle(
                              color: Colors.white,
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
                    color: AppColor.backgroundSecondary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
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
                                const Text(
                                  'Classroom Code',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColor.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  classroom.uniqueCode,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: AppColor.primary,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                _copyToClipboard(context, classroom.uniqueCode),
                            icon: const Icon(
                              Icons.copy,
                              color: AppColor.primary,
                            ),
                            tooltip: 'Copy code',
                          ),
                        ],
                      ),

                      // Separator
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Divider(
                          color: AppColor.textSecondary.withOpacity(0.2),
                          thickness: 1,
                          height: 1,
                        ),
                      ),

                      // Description
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColor.textSecondary,
                            ),
                          ),
                          if (isOwner)
                            IconButton(
                              onPressed: () =>
                                  _showEditDescriptionDialog(context),
                              icon: const Icon(Icons.edit, size: 20),
                              color: AppColor.primary,
                              tooltip: 'Edit description',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        classroom.description ?? 'No description',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColor.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // List of Members Header
                const Text(
                  'List of Members',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColor.textPrimary,
                  ),
                ),

                const SizedBox(height: 12),

                // Members List
                Container(
                  decoration: BoxDecoration(
                    color: AppColor.backgroundSecondary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: sortedUsers.length,
                    separatorBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Divider(
                        color: AppColor.textSecondary.withOpacity(0.2),
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
                                backgroundColor: AppColor.primary.withOpacity(
                                  0.1,
                                ),
                                child: Text(
                                  user.name[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.primary,
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
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColor.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      role,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: role == 'Owner'
                                            ? AppColor.primary
                                            : role == 'Coordinator'
                                            ? AppColor.accent
                                            : AppColor.textSecondary,
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
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red, width: 2),
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
