import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/constants/app_color.dart';

/// Model untuk menyimpan informasi schedule event pada calendar
class ScheduleEvent {
  final String color; // Hex color dari schedule
  final String title; // Optional: title schedule

  ScheduleEvent({
    required this.color,
    this.title = '',
  });
}

class ScheduleCalendar extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;
  final bool Function(DateTime day)? selectedDayPredicate;
  final Map<DateTime, List<ScheduleEvent>>? events; // Map tanggal ke list schedule events

  const ScheduleCalendar({
    super.key,
    required this.focusedDay,
    this.selectedDay,
    required this.onDaySelected,
    this.selectedDayPredicate,
    this.events,
  });

  List<ScheduleEvent> _getEventsForDay(DateTime day) {
    if (events == null) return [];
    
    // Normalize date untuk comparison (tanpa time)
    final normalizedDay = DateTime(day.year, day.month, day.day);
    
    // Cari events untuk tanggal ini
    for (var entry in events!.entries) {
      final normalizedKey = DateTime(entry.key.year, entry.key.month, entry.key.day);
      if (isSameDay(normalizedKey, normalizedDay)) {
        return entry.value;
      }
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      decoration: BoxDecoration(
        color: AppColor.backgroundSecondary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TableCalendar<ScheduleEvent>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: focusedDay,
        selectedDayPredicate: selectedDayPredicate ?? 
            (day) => isSameDay(selectedDay, day),
        onDaySelected: onDaySelected,
        calendarFormat: CalendarFormat.month,
        // Event loader untuk mendapatkan events per hari
        eventLoader: _getEventsForDay,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColor.textPrimary,
          ),
          leftChevronIcon: const Icon(
            Icons.chevron_left,
            color: AppColor.primary,
          ),
          rightChevronIcon: const Icon(
            Icons.chevron_right,
            color: AppColor.primary,
          ),
        ),
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: AppColor.secondary.withOpacity(0.8),
            shape: BoxShape.circle,
          ),
          selectedDecoration: const BoxDecoration(
            color: AppColor.primary,
            shape: BoxShape.circle,
          ),
          todayTextStyle: const TextStyle(
            color: AppColor.primary,
            fontWeight: FontWeight.w600,
          ),
          selectedTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          // Marker styling - akan di-override oleh calendarBuilders
          markerDecoration: const BoxDecoration(
            color: AppColor.accent,
            shape: BoxShape.circle,
          ),
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
                    color = Color(int.parse(event.color.replaceFirst('#', '0xFF')));
                  } catch (e) {
                    color = AppColor.accent; // Fallback color
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
    );
  }
}
