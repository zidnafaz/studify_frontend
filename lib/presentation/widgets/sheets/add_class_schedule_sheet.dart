import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_color.dart';
import '../../../data/models/classroom_model.dart';
import '../../../data/models/schedule_repeat_model.dart';
import '../../../data/models/schedule_reminder_model.dart';
import '../../../data/models/user_model.dart';
import '../classroom/schedule_text_field.dart';
import '../classroom/time_range_selector.dart';
import 'repeat_selection_sheet.dart';
import 'add_reminder_sheet.dart';
import 'color_picker_sheet.dart';

class AddClassScheduleSheet extends StatefulWidget {
  final Classroom classroom;
  final Function(Map<String, dynamic>) onSave;

  const AddClassScheduleSheet({
    super.key,
    required this.classroom,
    required this.onSave,
  });

  @override
  State<AddClassScheduleSheet> createState() => _AddClassScheduleSheetState();
}

class _AddClassScheduleSheetState extends State<AddClassScheduleSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _lecturerController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  DateTime _selectedDate = DateTime.now();
  ScheduleRepeat? _repeat;
  Color _selectedColor = AppColor.scheduleGreen;
  User? _coordinator1;
  User? _coordinator2;
  List<ScheduleReminder> _reminders = [];
  bool _isLoading = false;

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
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectRepeat() async {
    final result = await showModalBottomSheet<ScheduleRepeat>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RepeatSelectionSheet(initialRepeat: _repeat),
    );
    if (result != null) {
      setState(() {
        _repeat = result;
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

    final result = await showDialog<User>(
      context: context,
      builder: (context) => _UserSelectionDialog(
        users: users,
        selectedUser: _coordinator1,
        title: 'Pilih Koordinator 1',
      ),
    );
    if (result != null) {
      setState(() {
        _coordinator1 = result;
      });
    }
  }

  Future<void> _selectCoordinator2() async {
    final users = widget.classroom.users ?? [];
    if (users.isEmpty) return;

    final result = await showDialog<User>(
      context: context,
      builder: (context) => _UserSelectionDialog(
        users: users,
        selectedUser: _coordinator2,
        title: 'Pilih Koordinator 2',
      ),
    );
    if (result != null) {
      setState(() {
        _coordinator2 = result;
      });
    }
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
        if (_coordinator1 != null) 'coordinator_1': _coordinator1!.id,
        if (_coordinator2 != null) 'coordinator_2': _coordinator2!.id,
        // Add repeat data
        if (_repeat != null && _repeat!.daysOfWeek.isNotEmpty) ...{
          'repeat_days': _repeat!.daysOfWeek,
          'repeat_count': _repeat!.repeatCount,
        },
      };

      await widget.onSave(data);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat jadwal: $e'),
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
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColor.backgroundSecondary,
          borderRadius: BorderRadius.only(
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
                        onPressed: _isLoading ? null : () => Navigator.pop(context),
                        child: const Text(
                          'Batal',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const Text(
                        'Jadwal Kelas Baru',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColor.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: _isLoading ? null : _save,
                        child: const Text(
                          'Simpan',
                          style: TextStyle(
                            color: AppColor.primary,
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
                    hintText: 'Judul',
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
                      text: DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate),
                    ),
                    prefixIcon: Icons.calendar_today,
                    readOnly: true,
                    onTap: _selectDate,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Repeat Field
                  ScheduleTextField(
                    controller: TextEditingController(
                      text: _repeat?.displayText ?? 'Tidak berulang',
                    ),
                    prefixIcon: Icons.repeat,
                    readOnly: true,
                    onTap: _selectRepeat,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Lecturer Field
                  ScheduleTextField(
                    controller: _lecturerController,
                    hintText: 'Dosen',
                    prefixIcon: Icons.person,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Coordinator 1 Field
                  ScheduleTextField(
                    controller: TextEditingController(
                      text: _coordinator1?.name ?? widget.classroom.owner?.name ?? 'Koordinator 1',
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
                      text: _coordinator2?.name ?? widget.classroom.owner?.name ?? 'Koordinator 2',
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
                    hintText: 'Lokasi',
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
                          color: AppColor.textSecondary.withOpacity(0.3),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.palette,
                            color: AppColor.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            'Warna',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColor.textPrimary,
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
                              color: AppColor.textSecondary.withOpacity(0.3),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.notifications,
                                color: AppColor.textSecondary,
                                size: 20,
                              ),
                              const SizedBox(width: 16),
                              Text(
                                _reminders.isEmpty
                                    ? 'Tambah Pengingat'
                                    : 'Pengingat (${_reminders.length})',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppColor.textPrimary,
                                ),
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.add,
                                color: AppColor.primary,
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
                            color: AppColor.backgroundPrimary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: _reminders.map((reminder) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: AppColor.textSecondary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      reminder.displayText,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColor.textPrimary,
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
                                      onPressed: () => _removeReminder(reminder),
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
                    hintText: 'Deskripsi',
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

  const _UserSelectionDialog({
    required this.users,
    required this.selectedUser,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final isSelected = selectedUser?.id == user.id;

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColor.primary,
                child: Text(
                  user.name[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(user.name),
              subtitle: Text(user.email),
              trailing: isSelected
                  ? const Icon(Icons.check_circle, color: AppColor.primary)
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
