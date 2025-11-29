import 'package:flutter/material.dart';
import '../../../data/models/schedule_repeat_model.dart';

class RepeatSelectionSheet extends StatefulWidget {
  final ScheduleRepeat? initialRepeat;

  const RepeatSelectionSheet({super.key, this.initialRepeat});

  @override
  State<RepeatSelectionSheet> createState() => _RepeatSelectionSheetState();
}

class _RepeatSelectionSheetState extends State<RepeatSelectionSheet> {
  late List<int> _selectedDays;
  int _repeatCount = 1;

  final List<String> _dayNames = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDays = widget.initialRepeat?.daysOfWeek ?? [];
    _repeatCount = widget.initialRepeat?.repeatCount ?? 1;
  }

  void _toggleDay(int day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
      }
      _selectedDays.sort();
    });
  }

  void _save() {
    final repeat = ScheduleRepeat(
      daysOfWeek: _selectedDays,
      repeatCount: _repeatCount,
    );
    Navigator.pop(context, repeat);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tambah Pengulangan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  TextButton(
                    onPressed: _save,
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
              const SizedBox(height: 24),

              // Description
              Text(
                'Ulangi pengingat ini setiap',
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),

              // Days Selection
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: List.generate(_dayNames.length, (index) {
                    final dayValue = index + 1;
                    final isSelected = _selectedDays.contains(dayValue);

                    return Column(
                      children: [
                        if (index > 0) const Divider(height: 1),
                        InkWell(
                          onTap: () => _toggleDay(dayValue),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _dayNames[index],
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? colorScheme.primary
                                          : colorScheme.onSurfaceVariant
                                                .withOpacity(0.3),
                                      width: 2,
                                    ),
                                    color: isSelected
                                        ? colorScheme.primary
                                        : Colors.transparent,
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                          Icons.check,
                                          size: 16,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
              const SizedBox(height: 24),

              // Repeat Count
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ulangi sebanyak berapa kali',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.3),
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: _repeatCount > 1
                              ? () {
                                  setState(() {
                                    _repeatCount--;
                                  });
                                }
                              : null,
                          icon: Icon(
                            Icons.remove,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(
                          width: 40,
                          child: Text(
                            '$_repeatCount',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _repeatCount++;
                            });
                          },
                          icon: Icon(Icons.add, color: colorScheme.onSurface),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
