import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/constants/app_color.dart';
import '../../../data/models/personal_schedule_model.dart';
import '../../../providers/personal_schedule_provider.dart';
import '../../widgets/schedule_calendar.dart';
import '../../widgets/sheets/add_personal_schedule_sheet.dart';
import '../../widgets/sheets/personal_schedule_detail_sheet.dart';
import 'package:intl/intl.dart';

class PersonalScheduleScreen extends StatefulWidget {
  const PersonalScheduleScreen({super.key});

  @override
  State<PersonalScheduleScreen> createState() => _PersonalScheduleScreenState();
}

class _PersonalScheduleScreenState extends State<PersonalScheduleScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _showAllSchedules = true; // Default: tampilkan semua jadwal dari hari ini ke depan

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    
    // Fetch personal schedules
    Future.microtask(() {
      Provider.of<PersonalScheduleProvider>(context, listen: false)
          .fetchPersonalSchedules();
    });
  }

  // Group schedules by date
  Map<String, List<PersonalSchedule>> _groupSchedulesByDate(List<PersonalSchedule> schedules) {
    final Map<String, List<PersonalSchedule>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    for (var schedule in schedules) {
      final scheduleDate = DateTime(
        schedule.startTime.year,
        schedule.startTime.month,
        schedule.startTime.day,
      );

      // Skip jadwal yang sudah lewat jika mode "show all"
      if (_showAllSchedules && scheduleDate.isBefore(today)) {
        continue;
      }

      // Filter berdasarkan tanggal yang dipilih jika tidak show all
      if (!_showAllSchedules && !isSameDay(scheduleDate, _selectedDay)) {
        continue;
      }

      String dateKey;
      if (isSameDay(scheduleDate, today)) {
        dateKey = 'Today';
      } else if (isSameDay(scheduleDate, tomorrow)) {
        dateKey = 'Tomorrow';
      } else if (scheduleDate.year == now.year) {
        // Format: "12 Nov" untuk tahun yang sama
        dateKey = DateFormat('d MMM').format(scheduleDate);
      } else {
        // Format: "12 Nov 2026" untuk tahun berbeda
        dateKey = DateFormat('d MMM yyyy').format(scheduleDate);
      }

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(schedule);
    }

    // Sort schedules within each group by start time
    grouped.forEach((key, value) {
      value.sort((a, b) => a.startTime.compareTo(b.startTime));
    });

    return grouped;
  }

  // Convert schedules to calendar events dengan color
  Map<DateTime, List<ScheduleEvent>> _getCalendarEvents(List<PersonalSchedule> schedules) {
    final Map<DateTime, List<ScheduleEvent>> events = {};
    
    for (var schedule in schedules) {
      final date = DateTime(
        schedule.startTime.year,
        schedule.startTime.month,
        schedule.startTime.day,
      );
      
      if (!events.containsKey(date)) {
        events[date] = [];
      }
      
      events[date]!.add(ScheduleEvent(
        color: schedule.color,
        title: schedule.title,
      ));
    }
    
    return events;
  }

  String _getScheduleHeaderText() {
    if (_showAllSchedules) {
      return 'Upcoming Schedule';
    } else {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));
      final selected = DateTime(
        _selectedDay!.year,
        _selectedDay!.month,
        _selectedDay!.day,
      );

      if (isSameDay(selected, today)) {
        return 'Today\'s Schedule';
      } else if (isSameDay(selected, tomorrow)) {
        return 'Tomorrow\'s Schedule';
      } else if (selected.year == now.year) {
        return 'Schedule ${DateFormat('d MMM').format(selected)}';
      } else {
        return 'Schedule ${DateFormat('d MMM yyyy').format(selected)}';
      }
    }
  }

  IconData _getDateIcon(String dateKey) {
    if (dateKey == 'Today') {
      return Icons.today;
    } else if (dateKey == 'Tomorrow') {
      return Icons.event;
    } else {
      return Icons.calendar_month;
    }
  }

  Widget _buildScheduleList(List<PersonalSchedule> schedules) {
    final groupedSchedules = _groupSchedulesByDate(schedules);

    if (groupedSchedules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: AppColor.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _showAllSchedules 
                  ? 'No upcoming schedules' 
                  : 'No schedule on this date',
              style: const TextStyle(
                color: AppColor.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: groupedSchedules.length,
      itemBuilder: (context, groupIndex) {
        final dateKey = groupedSchedules.keys.elementAt(groupIndex);
        final schedulesForDate = groupedSchedules[dateKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header (hanya tampilkan jika show all schedules)
            if (_showAllSchedules) ...[
              Container(
                margin: EdgeInsets.only(bottom: 12, top: groupIndex > 0 ? 20 : 0),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColor.secondary.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getDateIcon(dateKey),
                      size: 16,
                      color: AppColor.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dateKey,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColor.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Single schedule card containing all schedules for this date
            Padding(
              padding: EdgeInsets.only(bottom: groupIndex < groupedSchedules.length - 1 ? 8 : 0),
              child: _PersonalScheduleCard(
                schedules: schedulesForDate,
                onScheduleTap: (schedule) {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => PersonalScheduleDetailSheet(
                      schedule: schedule,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundPrimary,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(88),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: SafeArea(
            child: Container(
              decoration: BoxDecoration(
                color: AppColor.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 48),
                        child: const Text(
                          'Jadwal Pribadi',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: Consumer<PersonalScheduleProvider>(
        builder: (context, provider, child) {
          final schedules = provider.schedules;
          final isLoading = provider.isLoading;
          final calendarEvents = _getCalendarEvents(schedules);

          return Column(
            children: [
              // Calendar
              ScheduleCalendar(
                focusedDay: _focusedDay,
                selectedDay: _selectedDay,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    _showAllSchedules = false; // Switch to selected date mode
                  });
                },
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                events: calendarEvents,
              ),
              
              const SizedBox(height: 16),
              
              // Schedule list header with show all button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _getScheduleHeaderText(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColor.textPrimary,
                      ),
                    ),
                    if (!_showAllSchedules)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _showAllSchedules = true;
                            _selectedDay = DateTime.now();
                          });
                        },
                        child: const Text(
                          'View All',
                          style: TextStyle(
                            color: AppColor.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Schedule list
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildScheduleList(schedules),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddScheduleSheet,
        backgroundColor: AppColor.primary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddScheduleSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddPersonalScheduleSheet(
        onSave: (data) async {
          final provider = Provider.of<PersonalScheduleProvider>(context, listen: false);
          await provider.createPersonalSchedule(
            title: data['title'],
            startTime: DateTime.parse(data['start_time']),
            endTime: DateTime.parse(data['end_time']),
            location: data['location'],
            description: data['description'],
            color: data['color'],
          );
        },
      ),
    );
  }
}

// Custom ScheduleCard for PersonalSchedule
class _PersonalScheduleCard extends StatelessWidget {
  final List<PersonalSchedule> schedules;
  final Function(PersonalSchedule)? onScheduleTap;

  const _PersonalScheduleCard({
    required this.schedules,
    this.onScheduleTap,
  });

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Widget _buildScheduleItem(PersonalSchedule schedule, bool isLast) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onScheduleTap != null ? () => onScheduleTap!(schedule) : null,
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
                      color: Color(int.parse(schedule.color.replaceFirst('#', '0xFF'))),
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
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColor.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        
                        // Title
                        Text(
                          schedule.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColor.textPrimary,
                          ),
                        ),
                        if (schedule.location != null && schedule.location!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          // Location
                          Text(
                            schedule.location!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColor.textSecondary,
                            ),
                          ),
                        ],
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
              color: AppColor.textSecondary.withOpacity(0.2),
              thickness: 1,
              height: 1,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: schedules.asMap().entries.map((entry) {
            final index = entry.key;
            final schedule = entry.value;
            final isLast = index == schedules.length - 1;
            return _buildScheduleItem(schedule, isLast);
          }).toList(),
        ),
      ),
    );
  }
}
