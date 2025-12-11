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
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _minutesBefore.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLow,
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
                                        _controller.text = _minutesBefore
                                            .toString();
                                      });
                                    }
                                  : null,
                              icon: const Icon(Icons.remove),
                              color: colorScheme.onSurface,
                            ),
                            Container(
                              width: 60,
                              child: TextField(
                                controller: _controller,
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onChanged: (value) {
                                  final minutes = int.tryParse(value);
                                  if (minutes != null && minutes > 0) {
                                    setState(() {
                                      _minutesBefore = minutes;
                                    });
                                  }
                                },
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
                                  _controller.text = _minutesBefore.toString();
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
                    AppLocalizations.of(context)!.minutesBeforeLabel,
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
