import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../data/models/personal_schedule_model.dart';
import '../../../data/models/schedule_reminder_model.dart';
import '../../../providers/personal_schedule_provider.dart';
import '../../../providers/combined_schedule_provider.dart';
import 'add_reminder_sheet.dart';
import 'edit_personal_schedule_sheet.dart';

class PersonalScheduleDetailSheet extends StatefulWidget {
  final PersonalSchedule schedule;

  const PersonalScheduleDetailSheet({super.key, required this.schedule});

  @override
  State<PersonalScheduleDetailSheet> createState() =>
      _PersonalScheduleDetailSheetState();
}

class _PersonalScheduleDetailSheetState
    extends State<PersonalScheduleDetailSheet> {
  List<ScheduleReminder> _reminders = [];

  @override
  void initState() {
    super.initState();
    // TODO: Load reminders from API
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

  Future<void> _showDeleteConfirmDialog(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Hapus Jadwal',
          style: TextStyle(color: colorScheme.onSurface),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus jadwal "${widget.schedule.title}"? Tindakan ini tidak dapat dibatalkan.',
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
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
    final provider = Provider.of<PersonalScheduleProvider>(
      context,
      listen: false,
    );
    // Store context and navigator before async operations
    final currentContext = context;
    final navigator = Navigator.of(currentContext);

    try {
      await provider.deletePersonalSchedule(widget.schedule.id);

      // Refresh combined schedules for home screen
      final combinedProvider = Provider.of<CombinedScheduleProvider>(
        currentContext,
        listen: false,
      );
      await combinedProvider.refresh();

      if (context.mounted) {
        // Close detail sheet
        navigator.pop();

        // Show success message after a short delay to ensure sheet is closed
        Future.delayed(const Duration(milliseconds: 100), () {
          if (context.mounted) {
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
      if (context.mounted) {
        navigator.pop();
        // Show error message after a short delay to ensure sheet is closed
        Future.delayed(const Duration(milliseconds: 100), () {
          if (context.mounted) {
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

  void _showEditScheduleSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditPersonalScheduleSheet(
        schedule: widget.schedule,
        onSave: (data) async {
          final provider = Provider.of<PersonalScheduleProvider>(
            context,
            listen: false,
          );
          try {
            await provider.updatePersonalSchedule(
              scheduleId: widget.schedule.id,
              title: data['title'],
              startTime: DateTime.parse(data['start_time']),
              endTime: DateTime.parse(data['end_time']),
              location: data['location'],
              description: data['description'],
              color: data['color'],
            );

            // Refresh schedules list
            await provider.fetchPersonalSchedules();

            // Refresh combined schedules for home screen
            final combinedProvider = Provider.of<CombinedScheduleProvider>(
              context,
              listen: false,
            );
            await combinedProvider.refresh();

            if (context.mounted) {
              Navigator.pop(context); // Close edit sheet
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

  String _formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  String _formatDate(DateTime date) {
    return DateFormat('d MMM yyyy').format(date);
  }

  Widget _buildReminderSection() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.onSurfaceVariant.withOpacity(0.2),
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
                  Icon(Icons.add, color: colorScheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Add Reminder',
                    style: TextStyle(
                      color: colorScheme.primary,
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
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.onSurfaceVariant.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.access_time,
            size: 20,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              reminder.displayText,
              style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),
            onPressed: () => _removeReminder(reminder),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.onSurfaceVariant.withOpacity(0.2),
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
          if (widget.schedule.location != null &&
              widget.schedule.location!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildFullWidthInfoItem(
              Icons.location_on,
              widget.schedule.location!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text, {Widget? colorBox}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.onSurfaceVariant.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: 4),
          if (colorBox != null)
            colorBox
          else
            Text(
              text,
              style: TextStyle(fontSize: 12, color: colorScheme.onSurface),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  Widget _buildFullWidthInfoItem(IconData icon, String text) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.onSurfaceVariant.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.schedule.title,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          if (widget.schedule.description != null &&
                              widget.schedule.description!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              widget.schedule.description!,
                              style: TextStyle(
                                fontSize: 14,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: colorScheme.onSurface),
                      onPressed: () => Navigator.pop(context),
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
                      _buildInfoCard(),
                      const SizedBox(height: 20),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _showEditScheduleSheet(context),
                              icon: const Icon(Icons.edit, size: 18),
                              label: const Text('Edit'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                side: BorderSide(color: colorScheme.primary),
                                foregroundColor: colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  _showDeleteConfirmDialog(context),
                              icon: const Icon(Icons.delete, size: 18),
                              label: const Text('Hapus'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Reminder section
                      _buildReminderSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
