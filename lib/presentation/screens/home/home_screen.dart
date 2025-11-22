import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../providers/classroom_provider.dart';
import '../../../providers/personal_schedule_provider.dart';
import '../../../providers/combined_schedule_provider.dart';
import '../../../core/constants/app_color.dart';
import '../../../data/models/combined_schedule_model.dart';
import '../classroom/classroom_list_screen.dart';
import '../../../features/profile/profile_screen.dart';
import '../../widgets/schedule_calendar.dart';
import '../../widgets/sheets/add_personal_schedule_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const _HomeTab(),
    const ClassroomScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColor.backgroundSecondary,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            backgroundColor: AppColor.backgroundSecondary,
            selectedItemColor: AppColor.primary,
            unselectedItemColor: AppColor.textSecondary,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 12,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.group_outlined),
                activeIcon: Icon(Icons.group),
                label: 'Classroom',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Home Tab with Schedule View
class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  String? _selectedSourceId; // 'all', 'personal', or 'classroom:{id}'
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _showAllSchedules = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedSourceId = 'all'; // Default to 'all'
    
    // Fetch data on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ClassroomProvider>(context, listen: false)
          .fetchClassrooms();
      Provider.of<CombinedScheduleProvider>(context, listen: false)
          .fetchCombinedSchedules(source: _selectedSourceId);
    });
  }


  Map<String, List<CombinedSchedule>> _groupSchedulesByDate(List<CombinedSchedule> schedules) {
    final Map<String, List<CombinedSchedule>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    for (var schedule in schedules) {
      final scheduleDate = DateTime(
        schedule.startTime.year,
        schedule.startTime.month,
        schedule.startTime.day,
      );

      if (_showAllSchedules && scheduleDate.isBefore(today)) {
        continue;
      }

      if (!_showAllSchedules && !isSameDay(scheduleDate, _selectedDay)) {
        continue;
      }

      String dateKey;
      if (isSameDay(scheduleDate, today)) {
        dateKey = 'Today';
      } else if (isSameDay(scheduleDate, tomorrow)) {
        dateKey = 'Tomorrow';
      } else if (scheduleDate.year == now.year) {
        dateKey = DateFormat('d MMM').format(scheduleDate);
      } else {
        dateKey = DateFormat('d MMM yyyy').format(scheduleDate);
      }

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(schedule);
    }

    grouped.forEach((key, value) {
      value.sort((a, b) => a.startTime.compareTo(b.startTime));
    });

    return grouped;
  }

  Map<DateTime, List<ScheduleEvent>> _getCalendarEvents(List<CombinedSchedule> schedules) {
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

  Widget _buildScheduleList(List<CombinedSchedule> schedules) {
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
            
            Padding(
              padding: EdgeInsets.only(bottom: groupIndex < groupedSchedules.length - 1 ? 8 : 0),
              child: _CombinedScheduleCard(
                schedules: schedulesForDate,
                onScheduleTap: (schedule) {
                  if (schedule.isPersonal) {
                    // For personal schedules, show personal schedule detail
                    // We need to convert CombinedSchedule to PersonalSchedule
                    // For now, just show a simple dialog
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(schedule.title),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Time: ${DateFormat('HH:mm').format(schedule.startTime)} - ${DateFormat('HH:mm').format(schedule.endTime)}'),
                            if (schedule.location != null) Text('Location: ${schedule.location}'),
                            if (schedule.description != null) Text('Description: ${schedule.description}'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    // For class schedules, show class schedule detail
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(schedule.title),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Time: ${DateFormat('HH:mm').format(schedule.startTime)} - ${DateFormat('HH:mm').format(schedule.endTime)}'),
                            if (schedule.location != null) Text('Location: ${schedule.location}'),
                            if (schedule.lecturer != null) Text('Lecturer: ${schedule.lecturer}'),
                            if (schedule.description != null) Text('Description: ${schedule.description}'),
                            Text('Source: ${schedule.sourceName}'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        );
      },
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
          // Refresh combined schedules
          final combinedProvider = Provider.of<CombinedScheduleProvider>(context, listen: false);
          await combinedProvider.refresh();
        },
      ),
    );
  }

  void _handleFilterChange(String? sourceId) {
    if (sourceId == null) return;
    
    setState(() {
      _selectedSourceId = sourceId;
    });

    // Fetch schedules with new filter
    Provider.of<CombinedScheduleProvider>(context, listen: false)
        .fetchCombinedSchedules(source: sourceId == 'all' ? null : sourceId);
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Text(
                        'Studify',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Consumer<CombinedScheduleProvider>(
                        builder: (context, combinedProvider, child) {
                          final sources = combinedProvider.availableSources;
                          
                          if (sources.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButton<String>(
                              value: _selectedSourceId ?? 'all',
                              dropdownColor: AppColor.backgroundSecondary,
                              underline: const SizedBox(),
                              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              items: sources.map((ScheduleSource source) {
                                return DropdownMenuItem<String>(
                                  value: source.id,
                                  child: Text(source.name),
                                );
                              }).toList(),
                              onChanged: _handleFilterChange,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Consumer<CombinedScheduleProvider>(
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
                    _showAllSchedules = false;
                  });
                },
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                events: calendarEvents,
              ),
              
              const SizedBox(height: 16),
              
              // Schedule list header
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
      floatingActionButton: _selectedSourceId == 'personal' || _selectedSourceId == 'all' || _selectedSourceId == null
          ? FloatingActionButton(
              onPressed: _showAddScheduleSheet,
              backgroundColor: AppColor.primary,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}

// Custom ScheduleCard for CombinedSchedule
class _CombinedScheduleCard extends StatelessWidget {
  final List<CombinedSchedule> schedules;
  final Function(CombinedSchedule)? onScheduleTap;

  const _CombinedScheduleCard({
    required this.schedules,
    this.onScheduleTap,
  });

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Widget _buildScheduleItem(CombinedSchedule schedule, bool isLast) {
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
                  Container(
                    width: 4,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Color(int.parse(schedule.color.replaceFirst('#', '0xFF'))),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_formatTime(schedule.startTime)} - ${_formatTime(schedule.endTime)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColor.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        
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
                        if (schedule.isClass && schedule.lecturer != null && schedule.lecturer!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Lecturer: ${schedule.lecturer}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColor.textSecondary,
                            ),
                          ),
                        ],
                        if (schedule.isClass) ...[
                          const SizedBox(height: 4),
                          Text(
                            schedule.sourceName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColor.primary.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
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
