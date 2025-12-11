import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../l10n/generated/app_localizations.dart';

import '../classroom/schedule_text_field.dart';
import '../classroom/time_range_selector.dart';
import 'color_picker_sheet.dart';
import 'add_reminder_sheet.dart';
import 'repeat_selection_sheet.dart';
import '../../../data/models/schedule_reminder_model.dart';
import '../../../data/models/schedule_repeat_model.dart';

class AddPersonalScheduleSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;

  const AddPersonalScheduleSheet({super.key, required this.onSave});

  @override
  State<AddPersonalScheduleSheet> createState() =>
      _AddPersonalScheduleSheetState();
}

class _AddPersonalScheduleSheetState extends State<AddPersonalScheduleSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  DateTime _selectedDate = DateTime.now();
  Color _selectedColor = const Color(0xFF5CD9C1); // scheduleGreen
  bool _isLoading = false;
  List<ScheduleReminder> _reminders = [];
  ScheduleRepeat? _repeat;

  @override
  void dispose() {
    _titleController.dispose();
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

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Store context and navigator before async operations
    final currentContext = context;
    final navigator = Navigator.of(currentContext);

    try {
      final startDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _startTime.hour,
        _startTime.minute,
      );

      var endDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _endTime.hour,
        _endTime.minute,
      );

      // If end time is before start time, assume it's the next day
      if (endDateTime.isBefore(startDateTime)) {
        endDateTime = endDateTime.add(const Duration(days: 1));
      }

      final data = {
        'title': _titleController.text.trim(),
        'start_time': startDateTime.toIso8601String(),
        'end_time': endDateTime.toIso8601String(),
        if (_locationController.text.trim().isNotEmpty)
          'location': _locationController.text.trim(),
        if (_descriptionController.text.trim().isNotEmpty)
          'description': _descriptionController.text.trim(),
        'color': _colorToHex(_selectedColor),
        if (_reminders.isNotEmpty)
          'reminders': _reminders.map((r) => r.minutesBefore).toList(),
        if (_repeat != null && _repeat!.daysOfWeek.isNotEmpty) ...{
          'repeat_days': _repeat!.daysOfWeek,
          'repeat_count': _repeat!.repeatCount,
        },
      };

      await widget.onSave(data);

      // Close sheet after successful save
      if (mounted) {
        navigator.pop(true);
      }
    } catch (e) {
      // Close sheet even if there's an error
      if (mounted) {
        navigator.pop(false);
        // Show error message after a short delay to ensure sheet is closed
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            ScaffoldMessenger.of(currentContext).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.scheduleCreateError(e.toString())),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
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
                        child: Text(
                          AppLocalizations.of(context)!.cancel,
                          style: TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context)!.newPersonalScheduleTitle,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      TextButton(
                        onPressed: _isLoading ? null : _save,
                        child: Text(
                          AppLocalizations.of(context)!.save,
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
                    hintText: AppLocalizations.of(context)!.titleHint,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppLocalizations.of(context)!.titleRequired;
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

                  // Repeat Field
                  ScheduleTextField(
                    controller: TextEditingController(
                      text: _repeat?.displayText ?? AppLocalizations.of(context)!.noRepeat,
                    ),
                    hintText: AppLocalizations.of(context)!.repeatLabel,
                    prefixIcon: Icons.repeat,
                    readOnly: true,
                    onTap: _selectRepeat,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Location Field
                  ScheduleTextField(
                    controller: _locationController,
                    hintText: AppLocalizations.of(context)!.locationHint,
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
                            AppLocalizations.of(context)!.colorLabel,
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

                  // Reminders Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.remindersLabel,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._reminders.map(
                        (reminder) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceVariant.withOpacity(
                                0.3,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: colorScheme.outline.withOpacity(0.1),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.notifications_none,
                                  size: 20,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  reminder.label,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  onPressed: () => _removeReminder(reminder),
                                  icon: const Icon(Icons.close, size: 18),
                                  color: colorScheme.error,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add,
                                color: colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(context)!.addReminderButton,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description Field
                  ScheduleTextField(
                    controller: _descriptionController,
                    hintText: AppLocalizations.of(context)!.descriptionHint,
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
