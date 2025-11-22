import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_color.dart';
import '../../../data/models/personal_schedule_model.dart';
import '../classroom/schedule_text_field.dart';
import '../classroom/time_range_selector.dart';
import 'color_picker_sheet.dart';

class EditPersonalScheduleSheet extends StatefulWidget {
  final PersonalSchedule schedule;
  final Function(Map<String, dynamic>) onSave;

  const EditPersonalScheduleSheet({
    super.key,
    required this.schedule,
    required this.onSave,
  });

  @override
  State<EditPersonalScheduleSheet> createState() => _EditPersonalScheduleSheetState();
}

class _EditPersonalScheduleSheetState extends State<EditPersonalScheduleSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _locationController;
  late final TextEditingController _descriptionController;

  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late DateTime _selectedDate;
  Color _selectedColor = AppColor.scheduleGreen;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with existing schedule data
    _titleController = TextEditingController(text: widget.schedule.title);
    _locationController = TextEditingController(text: widget.schedule.location ?? '');
    _descriptionController = TextEditingController(text: widget.schedule.description ?? '');
    
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
  }

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
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
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
        if (_locationController.text.trim().isNotEmpty)
          'location': _locationController.text.trim(),
        if (_descriptionController.text.trim().isNotEmpty)
          'description': _descriptionController.text.trim(),
        'color': _colorToHex(_selectedColor),
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
                content: Text('Gagal memperbarui jadwal: $e'),
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
                        'Edit Jadwal Pribadi',
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

