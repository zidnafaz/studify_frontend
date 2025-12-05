import 'package:flutter/material.dart';

import '../../../data/models/class_schedule_model.dart';

class ScheduleCard extends StatelessWidget {
  final List<ClassSchedule> schedules;
  final Function(ClassSchedule)? onScheduleTap;

  const ScheduleCard({super.key, required this.schedules, this.onScheduleTap});

  String _formatTime(DateTime time) {
    // Format time to HH:MM
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Widget _buildScheduleItem(
    BuildContext context,
    ClassSchedule schedule,
    bool isLast,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onScheduleTap != null
                ? () => onScheduleTap!(schedule)
                : null,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  // Color bar indicator (vertical rectangle)
                  Container(
                    width: 4,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Color(
                        int.parse(schedule.color.replaceFirst('#', '0xFF')),
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Schedule details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Time range
                        Text(
                          '${_formatTime(schedule.startTime)} - ${_formatTime(schedule.endTime)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Title
                        Text(
                          schedule.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Location | Lecturer
                        Text(
                          '${schedule.location} | ${schedule.lecturer}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Divider(
              color: colorScheme.onSurface.withOpacity(0.1),
              thickness: 1,
              height: 1,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
        border: isDark
            ? Border.all(color: Colors.white.withOpacity(0.1))
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: schedules.asMap().entries.map((entry) {
            final index = entry.key;
            final schedule = entry.value;
            final isLast = index == schedules.length - 1;
            return _buildScheduleItem(context, schedule, isLast);
          }).toList(),
        ),
      ),
    );
  }
}
