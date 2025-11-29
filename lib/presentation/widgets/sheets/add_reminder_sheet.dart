import 'package:flutter/material.dart';

import '../../../data/models/schedule_reminder_model.dart';

class AddReminderSheet extends StatefulWidget {
  const AddReminderSheet({super.key});

  @override
  State<AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends State<AddReminderSheet> {
  int _minutesBefore = 15;

  void _save() {
    final reminder = ScheduleReminder(minutesBefore: _minutesBefore);
    Navigator.pop(context, reminder);
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
                    'Tambah Pengingat',
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

              // Reminder Time Selector
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: colorScheme.onSurfaceVariant.withOpacity(
                              0.3,
                            ),
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: _minutesBefore > 1
                                  ? () {
                                      setState(() {
                                        if (_minutesBefore <= 15) {
                                          _minutesBefore--;
                                        } else if (_minutesBefore <= 60) {
                                          _minutesBefore -= 5;
                                        } else {
                                          _minutesBefore -= 30;
                                        }
                                      });
                                    }
                                  : null,
                              icon: const Icon(Icons.remove),
                              color: colorScheme.onSurface,
                            ),
                            Container(
                              constraints: const BoxConstraints(minWidth: 40),
                              child: Text(
                                '$_minutesBefore',
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
                                  if (_minutesBefore < 15) {
                                    _minutesBefore++;
                                  } else if (_minutesBefore < 60) {
                                    _minutesBefore += 5;
                                  } else {
                                    _minutesBefore += 30;
                                  }
                                });
                              },
                              icon: const Icon(Icons.add),
                              color: colorScheme.onSurface,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'menit sebelumnya',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
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
