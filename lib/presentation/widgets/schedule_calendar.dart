import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

/// Model untuk menyimpan informasi schedule event pada calendar
class ScheduleEvent {
  final String color; // Hex color dari schedule
  final String title; // Optional: title schedule

  ScheduleEvent({required this.color, this.title = ''});
}

enum CalendarViewMode {
  full, // Month view
  minimal, // Two weeks view
  compact, // Week view
}

class ScheduleCalendar extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;
  final bool Function(DateTime day)? selectedDayPredicate;
  final Map<DateTime, List<ScheduleEvent>>?
  events; // Map tanggal ke list schedule events
  final CalendarViewMode viewMode;
  final Function(CalendarViewMode)? onViewModeChanged;

  const ScheduleCalendar({
    super.key,
    required this.focusedDay,
    this.selectedDay,
    required this.onDaySelected,
    this.selectedDayPredicate,
    this.events,
    this.viewMode = CalendarViewMode.full,
    this.onViewModeChanged,
  });

  CalendarFormat _getCalendarFormat() {
    switch (viewMode) {
      case CalendarViewMode.full:
        return CalendarFormat.month;
      case CalendarViewMode.minimal:
        return CalendarFormat.twoWeeks;
      case CalendarViewMode.compact:
        return CalendarFormat.week;
    }
  }

  List<ScheduleEvent> _getEventsForDay(DateTime day) {
    if (events == null) return [];

    // Normalize date untuk comparison (tanpa time)
    final normalizedDay = DateTime(day.year, day.month, day.day);

    // Cari events untuk tanggal ini
    for (var entry in events!.entries) {
      final normalizedKey = DateTime(
        entry.key.year,
        entry.key.month,
        entry.key.day,
      );
      if (isSameDay(normalizedKey, normalizedDay)) {
        return entry.value;
      }
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
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
      child: Column(
        children: [
          // View mode toggle button
          if (onViewModeChanged != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: colorScheme.onSurface.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildViewModeButton(
                          context,
                          CalendarViewMode.full,
                          Icons.calendar_view_week,
                          'Full',
                        ),
                        Container(
                          width: 1,
                          height: 12,
                          color: colorScheme.onSurface.withOpacity(0.1),
                        ),
                        _buildViewModeButton(
                          context,
                          CalendarViewMode.minimal,
                          Icons.calendar_view_month,
                          'Minimal',
                        ),
                        Container(
                          width: 1,
                          height: 12,
                          color: colorScheme.onSurface.withOpacity(0.1),
                        ),
                        _buildViewModeButton(
                          context,
                          CalendarViewMode.compact,
                          Icons.calendar_today,
                          'Compact',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          TableCalendar<ScheduleEvent>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: focusedDay,
            selectedDayPredicate:
                selectedDayPredicate ?? (day) => isSameDay(selectedDay, day),
            onDaySelected: onDaySelected,
            calendarFormat: _getCalendarFormat(),
            availableCalendarFormats: const {
              CalendarFormat.month: 'Month',
              CalendarFormat.twoWeeks: '2 Weeks',
              CalendarFormat.week: 'Week',
            },
            // Event loader untuk mendapatkan events per hari
            eventLoader: _getEventsForDay,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              leftChevronIcon: Icon(
                Icons.chevron_left,
                color: colorScheme.primary,
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right,
                color: colorScheme.primary,
              ),
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: colorScheme.secondary.withOpacity(0.8),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
              todayTextStyle: TextStyle(
                color: colorScheme.onSecondary,
                fontWeight: FontWeight.w600,
              ),
              selectedTextStyle: TextStyle(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
              // Marker styling - akan di-override oleh calendarBuilders
              markerDecoration: BoxDecoration(
                color: colorScheme.tertiary,
                shape: BoxShape.circle,
              ),
              defaultTextStyle: TextStyle(color: colorScheme.onSurface),
              weekendTextStyle: TextStyle(color: colorScheme.error),
            ),
            // Custom builder untuk menampilkan markers dengan warna schedule
            calendarBuilders: CalendarBuilders<ScheduleEvent>(
              markerBuilder: (context, day, events) {
                if (events.isEmpty) return const SizedBox.shrink();

                // Ambil maksimal 3 events untuk ditampilkan
                final displayEvents = events.take(3).toList();

                return Positioned(
                  bottom: 4,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: displayEvents.map((event) {
                      // Parse color dari hex string
                      Color color;
                      try {
                        color = Color(
                          int.parse(event.color.replaceFirst('#', '0xFF')),
                        );
                      } catch (e) {
                        color = colorScheme.tertiary; // Fallback color
                      }

                      return Container(
                        width: 5,
                        height: 5,
                        margin: const EdgeInsets.symmetric(horizontal: 0.5),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
          // Bottom padding untuk marker dots
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildViewModeButton(
    BuildContext context,
    CalendarViewMode mode,
    IconData icon,
    String label,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = viewMode == mode;
    return InkWell(
      onTap: () => onViewModeChanged?.call(mode),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
