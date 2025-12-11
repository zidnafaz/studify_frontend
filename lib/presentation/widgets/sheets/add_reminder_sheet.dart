import 'package:flutter/material.dart';
import '../../../l10n/generated/app_localizations.dart';

import '../../../data/models/schedule_reminder_model.dart';

class AddReminderSheet extends StatefulWidget {
  const AddReminderSheet({super.key});

  @override
  State<AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends State<AddReminderSheet> {
  int _minutesBefore = 15;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

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
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.addReminderTitle,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  TextButton(
                    onPressed: _save,
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
              const SizedBox(height: 24),

              // Reminder Time Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.minutesBeforeLabel,
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: _minutesBefore > 1
                              ? () {
                                  setState(() {
                                    _minutesBefore--;
                                  });
                                }
                              : null,
                          icon: Icon(
                            Icons.remove,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(
                          width: 60,
                          child: TextField(
                            controller: TextEditingController(
                                text: '$_minutesBefore')
                              ..selection = TextSelection.fromPosition(
                                TextPosition(
                                    offset: '$_minutesBefore'.length),
                              ),
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                            onChanged: (value) {
                              final newValue = int.tryParse(value);
                              if (newValue != null && newValue > 0) {
                                setState(() {
                                  _minutesBefore = newValue;
                                });
                              }
                            },
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _minutesBefore++;
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
