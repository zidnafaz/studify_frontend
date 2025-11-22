import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_color.dart';
import '../../../data/models/class_schedule_model.dart';
import '../../../data/models/classroom_model.dart';
import '../../../data/models/schedule_reminder_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/classroom_provider.dart';
import '../../../providers/combined_schedule_provider.dart';
import 'add_reminder_sheet.dart';
import 'edit_class_schedule_sheet.dart';

class ClassScheduleDetailSheet extends StatefulWidget {
  final ClassSchedule schedule;
  final Classroom classroom;

  const ClassScheduleDetailSheet({
    super.key,
    required this.schedule,
    required this.classroom,
  });

  @override
  State<ClassScheduleDetailSheet> createState() =>
      _ClassScheduleDetailSheetState();
}

class _ClassScheduleDetailSheetState extends State<ClassScheduleDetailSheet> {
  Classroom? _detailedClassroom;
  List<ScheduleReminder> _reminders = [];

  @override
  void initState() {
    super.initState();
    // TODO: Load reminders from API
  }

  bool _canEdit(AuthProvider authProvider) {
    final currentUser = authProvider.user;

    if (currentUser == null) return false;

    // Check if user is owner
    if (currentUser.id == widget.classroom.ownerId) {
      return true;
    }

    // Check if user is coordinator 1 or 2
    if (currentUser.id == widget.schedule.coordinator1 ||
        currentUser.id == widget.schedule.coordinator2) {
      return true;
    }

    return false;
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

  Future<void> _addReminder() async {
    final result = await showModalBottomSheet<ScheduleReminder>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddReminderSheet(),
    );
    if (result != null && !_reminders.contains(result)) {
      setState(() {
        _reminders.add(result);
      });
      // TODO: Save reminder to API
    }
  }

  void _removeReminder(ScheduleReminder reminder) {
    setState(() {
      _reminders.remove(reminder);
    });
    // TODO: Delete reminder from API
  }

  void _showEditScheduleSheet(BuildContext context) {
    // Close detail sheet first
    Navigator.pop(context);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditClassScheduleSheet(
        schedule: widget.schedule,
        classroom: widget.classroom,
        onSave: (data) async {
          final provider = Provider.of<ClassroomProvider>(context, listen: false);
          try {
            await provider.updateClassSchedule(
              classroomId: widget.classroom.id,
              scheduleId: widget.schedule.id,
              title: data['title'],
              startTime: DateTime.parse(data['start_time']),
              endTime: DateTime.parse(data['end_time']),
              lecturer: data['lecturer'],
              location: data['location'],
              description: data['description'],
              color: data['color'],
              coordinator1: data['coordinator_1'],
              coordinator2: data['coordinator_2'],
            );
            
            // Refresh schedules list
            await provider.fetchClassSchedules(widget.classroom.id);
            
            // Refresh combined schedules for home screen
            final combinedProvider = Provider.of<CombinedScheduleProvider>(
              context,
              listen: false,
            );
            await combinedProvider.refresh();
            
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Jadwal berhasil diperbarui'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Gagal memperbarui jadwal: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            rethrow;
          }
        },
      ),
    );
  }

  Future<void> _showDeleteConfirmDialog(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColor.backgroundSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus Jadwal',
          style: TextStyle(color: AppColor.textPrimary),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus jadwal "${widget.schedule.title}"? Tindakan ini tidak dapat dibatalkan.',
          style: const TextStyle(color: AppColor.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColor.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _deleteSchedule(context);
    }
  }

  Future<void> _deleteSchedule(BuildContext context) async {
    final provider = Provider.of<ClassroomProvider>(context, listen: false);
    // Store context and navigator before async operations
    final currentContext = context;
    final navigator = Navigator.of(currentContext);

    try {
      await provider.deleteClassSchedule(
        classroomId: widget.classroom.id,
        scheduleId: widget.schedule.id,
      );

      // Refresh schedules list
      await provider.fetchClassSchedules(widget.classroom.id);

      // Refresh combined schedules for home screen
      final combinedProvider = Provider.of<CombinedScheduleProvider>(
        currentContext,
        listen: false,
      );
      await combinedProvider.refresh();

      if (mounted) {
        // Close detail sheet
        navigator.pop();
        
        // Show success message after a short delay to ensure sheet is closed
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            ScaffoldMessenger.of(currentContext).showSnackBar(
              const SnackBar(
                content: Text('Jadwal berhasil dihapus'),
                backgroundColor: Colors.green,
              ),
            );
          }
        });
      }
    } catch (e) {
      // Close sheet even if there's an error
      if (mounted) {
        navigator.pop();
        // Show error message after a short delay to ensure sheet is closed
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            ScaffoldMessenger.of(currentContext).showSnackBar(
              SnackBar(
                content: Text('Gagal menghapus jadwal: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
      }
    }
  }

  String _formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  String _formatDate(DateTime date) {
    return DateFormat('d MMM yyyy').format(date);
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColor.textSecondary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  Icons.access_time,
                  '${_formatTime(widget.schedule.startTime)} - ${_formatTime(widget.schedule.endTime)}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoItem(
                  Icons.calendar_today,
                  _formatDate(widget.schedule.startTime),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoItem(
                  Icons.palette,
                  '',
                  colorBox: Container(
                    width: 60,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Color(
                        int.parse(
                          widget.schedule.color.replaceFirst('#', '0xFF'),
                        ),
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildFullWidthInfoItem(
            Icons.person,
            widget.schedule.lecturer ?? '-',
          ),
          const SizedBox(height: 12),
          _buildFullWidthInfoItem(
            Icons.location_on,
            widget.schedule.location ?? '-',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text, {Widget? colorBox}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.backgroundPrimary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColor.textSecondary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColor.textSecondary),
          const SizedBox(height: 4),
          if (colorBox != null)
            colorBox
          else
            Text(
              text,
              style: const TextStyle(fontSize: 12, color: AppColor.textPrimary),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  Widget _buildFullWidthInfoItem(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColor.backgroundPrimary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColor.textSecondary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColor.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: AppColor.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColor.textSecondary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          ..._reminders.map(
            (reminder) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildReminderItem(reminder),
            ),
          ),
          InkWell(
            onTap: _addReminder,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add, color: AppColor.primary, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Add Reminder',
                    style: TextStyle(
                      color: AppColor.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderItem(ScheduleReminder reminder) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColor.backgroundPrimary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColor.textSecondary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.access_time,
            size: 20,
            color: AppColor.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              reminder.label,
              style: const TextStyle(fontSize: 14, color: AppColor.textPrimary),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.close,
              size: 20,
              color: AppColor.textSecondary,
            ),
            onPressed: () => _removeReminder(reminder),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final canEdit = _canEdit(authProvider);

        return Container(
          decoration: const BoxDecoration(
            color: AppColor.backgroundPrimary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.schedule.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColor.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description
                      if (widget.schedule.description != null &&
                          widget.schedule.description!.isNotEmpty) ...[
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColor.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: AppColor.textSecondary.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Text(
                            widget.schedule.description!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColor.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Info card
                      _buildInfoCard(),

                      const SizedBox(height: 20),

                      // Action Buttons
                      if (canEdit) ...[
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _showEditScheduleSheet(context),
                                icon: const Icon(Icons.edit, size: 18),
                                label: const Text('Edit'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  side: const BorderSide(color: AppColor.primary),
                                  foregroundColor: AppColor.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _showDeleteConfirmDialog(context),
                                icon: const Icon(Icons.delete, size: 18),
                                label: const Text('Hapus'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Reminder section
                      _buildReminderSection(),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
