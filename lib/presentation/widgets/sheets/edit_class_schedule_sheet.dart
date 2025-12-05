import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/models/classroom_model.dart';
import '../../../data/models/class_schedule_model.dart';
import '../../../data/models/schedule_reminder_model.dart';
import '../../../data/models/user_model.dart';
import '../classroom/schedule_text_field.dart';
import '../classroom/time_range_selector.dart';
import 'add_reminder_sheet.dart';
import 'color_picker_sheet.dart';

class EditClassScheduleSheet extends StatefulWidget {
  final ClassSchedule schedule;
  final Classroom classroom;
  final Function(Map<String, dynamic>) onSave;

  const EditClassScheduleSheet({
    super.key,
    required this.schedule,
    required this.classroom,
    required this.onSave,
  });

  @override
  State<EditClassScheduleSheet> createState() => _EditClassScheduleSheetState();
}

class _EditClassScheduleSheetState extends State<EditClassScheduleSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _lecturerController;
  late final TextEditingController _locationController;
  late final TextEditingController _descriptionController;

  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late DateTime _selectedDate;
  Color _selectedColor = const Color(0xFF5CD9C1); // scheduleGreen
  User? _coordinator1;
  User? _coordinator2;
  List<ScheduleReminder> _reminders = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing schedule data
    _titleController = TextEditingController(text: widget.schedule.title);
    _lecturerController = TextEditingController(
      text: widget.schedule.lecturer ?? '',
    );
    _locationController = TextEditingController(
      text: widget.schedule.location ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.schedule.description ?? '',
    );

    // Initialize time and date from schedule
    _startTime = TimeOfDay.fromDateTime(widget.schedule.startTime);
    _endTime = TimeOfDay.fromDateTime(widget.schedule.endTime);
    _selectedDate = DateTime(
      widget.schedule.startTime.year,
      widget.schedule.startTime.month,
      widget.schedule.startTime.day,
    );

    // Initialize color from schedule
    _selectedColor = Color(
      int.parse(widget.schedule.color.replaceFirst('#', '0xFF')),
    );

    // Initialize coordinators from schedule
    // If coordinator is owner, we'll keep it as is
    // When saving, if coordinator is null, we'll use owner_id
    _coordinator1 = widget.schedule.coordinator1User;
    _coordinator2 = widget.schedule.coordinator2User;

    // If coordinator is owner, set to null so user can see it's default (owner)
    // but we'll still save owner_id when saving
    final ownerId = widget.classroom.ownerId;
    if (_coordinator1?.id == ownerId) {
      _coordinator1 = null; // Will show owner name in UI, but save as owner_id
    }
    if (_coordinator2?.id == ownerId) {
      _coordinator2 = null; // Will show owner name in UI, but save as owner_id
    }

    // Initialize reminders from schedule
    if (widget.schedule.reminders != null) {
      _reminders = widget.schedule.reminders!
          .map((r) => ScheduleReminder(minutesBefore: r.minutesBeforeStart))
          .toList();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _lecturerController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
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
    }
  }

  void _removeReminder(ScheduleReminder reminder) {
    setState(() {
      _reminders.remove(reminder);
    });
    // TODO: Delete reminder from API
  }

  Future<void> _selectColor() async {
    final result = await showModalBottomSheet<Color>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ColorPickerSheet(selectedColor: _selectedColor),
    );
    if (result != null) {
      setState(() {
        _selectedColor = result;
      });
    }
  }

  Future<void> _selectCoordinator1() async {
    final users = widget.classroom.users ?? [];
    if (users.isEmpty) return;

    final result = await showDialog<User?>(
      context: context,
      builder: (context) => _UserSelectionDialog(
        users: users,
        selectedUser: _coordinator1,
        title: 'Pilih Koordinator 1',
        allowClear: true,
      ),
    );
    setState(() {
      _coordinator1 = result;
    });
  }

  Future<void> _selectCoordinator2() async {
    final users = widget.classroom.users ?? [];
    if (users.isEmpty) return;

    final result = await showDialog<User?>(
      context: context,
      builder: (context) => _UserSelectionDialog(
        users: users,
        selectedUser: _coordinator2,
        title: 'Pilih Koordinator 2',
        allowClear: true,
      ),
    );
    setState(() {
      _coordinator2 = result;
    });
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final startDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _startTime.hour,
        _startTime.minute,
      );

      final endDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _endTime.hour,
        _endTime.minute,
      );

      // If coordinator is null, use owner_id as default
      final coordinator1Id = _coordinator1?.id ?? widget.classroom.ownerId;
      final coordinator2Id = _coordinator2?.id ?? widget.classroom.ownerId;

      final data = {
        'title': _titleController.text.trim(),
        'start_time': startDateTime.toIso8601String(),
        'end_time': endDateTime.toIso8601String(),
        if (_lecturerController.text.trim().isNotEmpty)
          'lecturer': _lecturerController.text.trim(),
        if (_locationController.text.trim().isNotEmpty)
          'location': _locationController.text.trim(),
        if (_descriptionController.text.trim().isNotEmpty)
          'description': _descriptionController.text.trim(),
        'color': _colorToHex(_selectedColor),
        'coordinator_1': coordinator1Id,
        'coordinator_2': coordinator2Id,
        if (_reminders.isNotEmpty)
          'reminders': _reminders.map((r) => r.minutesBefore).toList(),
      };

      await widget.onSave(data);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui jadwal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.pop(context),
                        child: const Text(
                          'Batal',
                          style: TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      ),
                      Text(
                        'Edit Class Event',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      TextButton(
                        onPressed: _isLoading ? null : _save,
                        child: Text(
                          'Simpan',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title Field
                  ScheduleTextField(
                    controller: _titleController,
                    hintText: 'Title',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Judul tidak boleh kosong';
                      }
                      return null;
                    },
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Time Range
                  TimeRangeSelector(
                    startTime: _startTime,
                    endTime: _endTime,
                    onStartTimeTap: _selectStartTime,
                    onEndTimeTap: _selectEndTime,
                  ),
                  const SizedBox(height: 16),

                  // Date Field
                  ScheduleTextField(
                    controller: TextEditingController(
                      text: DateFormat(
                        'dd MMMM yyyy',
                        'id_ID',
                      ).format(_selectedDate),
                    ),
                    prefixIcon: Icons.calendar_today,
                    readOnly: true,
                    onTap: _selectDate,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Lecturer Field
                  ScheduleTextField(
                    controller: _lecturerController,
                    hintText: 'Lecturer',
                    prefixIcon: Icons.person,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Coordinator 1 Field
                  ScheduleTextField(
                    controller: TextEditingController(
                      text:
                          _coordinator1?.name ??
                          widget.classroom.owner?.name ??
                          'Coordinator 1',
                    ),
                    prefixIcon: Icons.person_outline,
                    readOnly: true,
                    onTap: _selectCoordinator1,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Coordinator 2 Field
                  ScheduleTextField(
                    controller: TextEditingController(
                      text:
                          _coordinator2?.name ??
                          widget.classroom.owner?.name ??
                          'Coordinator 2',
                    ),
                    prefixIcon: Icons.person_outline,
                    readOnly: true,
                    onTap: _selectCoordinator2,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Location Field
                  ScheduleTextField(
                    controller: _locationController,
                    hintText: 'Location',
                    prefixIcon: Icons.location_on,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Color Field
                  InkWell(
                    onTap: _isLoading ? null : _selectColor,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: colorScheme.onSurfaceVariant.withOpacity(0.3),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.palette,
                            color: colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Color',
                            style: TextStyle(
                              fontSize: 16,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: _selectedColor,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: _selectedColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Reminder Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: _isLoading ? null : _addReminder,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: colorScheme.onSurfaceVariant.withOpacity(
                                0.3,
                              ),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.notifications,
                                color: colorScheme.onSurfaceVariant,
                                size: 20,
                              ),
                              const SizedBox(width: 16),
                              Text(
                                _reminders.isEmpty
                                    ? 'Add Reminder'
                                    : 'Reminders (${_reminders.length})',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.add,
                                color: colorScheme.primary,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_reminders.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: _reminders.map((reminder) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      reminder.displayText,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        size: 18,
                                        color: Colors.red,
                                      ),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () =>
                                          _removeReminder(reminder),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description Field
                  ScheduleTextField(
                    controller: _descriptionController,
                    hintText: 'Description',
                    maxLines: 4,
                    enabled: !_isLoading,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// User Selection Dialog
class _UserSelectionDialog extends StatelessWidget {
  final List<User> users;
  final User? selectedUser;
  final String title;
  final bool allowClear;

  const _UserSelectionDialog({
    required this.users,
    required this.selectedUser,
    required this.title,
    this.allowClear = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(title),
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: users.length + (allowClear ? 1 : 0),
          itemBuilder: (context, index) {
            // Clear option
            if (allowClear && index == 0) {
              final isSelected = selectedUser == null;
              return ListTile(
                leading: const Icon(Icons.clear, color: Colors.grey),
                title: const Text('Hapus Koordinator'),
                trailing: isSelected
                    ? Icon(Icons.check_circle, color: colorScheme.primary)
                    : null,
                onTap: () => Navigator.pop(context, null),
              );
            }

            // User option
            final userIndex = allowClear ? index - 1 : index;
            final user = users[userIndex];
            final isSelected = selectedUser?.id == user.id;

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: colorScheme.primary,
                child: Text(
                  user.name[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(user.name),
              subtitle: Text(user.email),
              trailing: isSelected
                  ? Icon(Icons.check_circle, color: colorScheme.primary)
                  : null,
              onTap: () => Navigator.pop(context, user),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
      ],
    );
  }
}
