import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../providers/classroom_provider.dart';
import '../../../providers/personal_schedule_provider.dart';
import '../../../providers/combined_schedule_provider.dart';

import '../../../data/models/combined_schedule_model.dart';
import '../classroom/classroom_list_screen.dart';
import '../auth/profile_screen.dart';
import '../../widgets/schedule_calendar.dart';
import '../../widgets/sheets/add_personal_schedule_sheet.dart';
import '../../widgets/sheets/combined_schedule_detail_sheet.dart';

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
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1D29) : colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          border: isDark
              ? Border(top: BorderSide(color: Colors.white.withOpacity(0.1)))
              : null,
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
            backgroundColor: isDark
                ? const Color(0xFF1C1D29)
                : colorScheme.surface,
            selectedItemColor: colorScheme.primary,
            unselectedItemColor: colorScheme.onSurface.withOpacity(0.6),
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
  CalendarViewMode _calendarViewMode = CalendarViewMode.full;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedSourceId = 'all'; // Default to 'all'

    // Fetch data on init
    Future.microtask(() {
      Provider.of<ClassroomProvider>(context, listen: false).fetchClassrooms();
      Provider.of<CombinedScheduleProvider>(
        context,
        listen: false,
      ).fetchCombinedSchedules(source: _selectedSourceId);
    });
  }

  Map<String, List<CombinedSchedule>> _groupSchedulesByDate(
    List<CombinedSchedule> schedules,
  ) {
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

  Map<DateTime, List<ScheduleEvent>> _getCalendarEvents(
    List<CombinedSchedule> schedules,
  ) {
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

      events[date]!.add(
        ScheduleEvent(color: schedule.color, title: schedule.title),
      );
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
    final colorScheme = Theme.of(context).colorScheme;

    if (groupedSchedules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _showAllSchedules
                  ? 'No upcoming schedules'
                  : 'No schedule on this date',
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.7),
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
                margin: EdgeInsets.only(
                  bottom: 12,
                  top: groupIndex > 0 ? 20 : 0,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getDateIcon(dateKey),
                      size: 16,
                      color: colorScheme.onSecondaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dateKey,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            Padding(
              padding: EdgeInsets.only(
                bottom: groupIndex < groupedSchedules.length - 1 ? 8 : 0,
              ),
              child: _CombinedScheduleCard(
                schedules: schedulesForDate,
                onScheduleTap: (schedule) {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) =>
                        CombinedScheduleDetailSheet(schedule: schedule),
                  );
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
          final provider = Provider.of<PersonalScheduleProvider>(
            context,
            listen: false,
          );
          await provider.createPersonalSchedule(
            title: data['title'],
            startTime: DateTime.parse(data['start_time']),
            endTime: DateTime.parse(data['end_time']),
            location: data['location'],
            description: data['description'],
            color: data['color'],
            reminders: data['reminders'] != null
                ? List<int>.from(data['reminders'])
                : null,
            repeatDays: data['repeat_days'] != null
                ? List<int>.from(data['repeat_days'])
                : null,
            repeatCount: data['repeat_count'],
          );
          // Refresh combined schedules
          final combinedProvider = Provider.of<CombinedScheduleProvider>(
            context,
            listen: false,
          );
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
    Provider.of<CombinedScheduleProvider>(
      context,
      listen: false,
    ).fetchCombinedSchedules(source: sourceId == 'all' ? null : sourceId);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(88),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: SafeArea(
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        'Studify',
                        style: TextStyle(
                          color: colorScheme.onPrimary,
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButton<String>(
                              value: _selectedSourceId ?? 'all',
                              dropdownColor: isDark
                                  ? const Color(0xFF1C1D29)
                                  : colorScheme.surface,
                              underline: const SizedBox(),
                              icon: Icon(
                                Icons.arrow_drop_down,
                                color: colorScheme.onPrimary,
                                size: 20,
                              ),
                              iconSize: 20,
                              isDense: true,
                              // Selected value style (di appbar) - putih
                              selectedItemBuilder: (BuildContext context) {
                                return sources.map<Widget>((
                                  ScheduleSource source,
                                ) {
                                  return Text(
                                    source.name,
                                    style: TextStyle(
                                      color: colorScheme.onPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  );
                                }).toList();
                              },
                              // Dropdown items style (saat dibuka) - primary color
                              items: sources.map((ScheduleSource source) {
                                return DropdownMenuItem<String>(
                                  value: source.id,
                                  child: Text(
                                    source.name,
                                    style: TextStyle(
                                      color: colorScheme.primary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
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
                viewMode: _calendarViewMode,
                onViewModeChanged: (mode) {
                  setState(() {
                    _calendarViewMode = mode;
                  });
                },
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
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
                        child: Text(
                          'View All',
                          style: TextStyle(
                            color: colorScheme.primary,
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
      floatingActionButton:
          _selectedSourceId == 'personal' ||
              _selectedSourceId == 'all' ||
              _selectedSourceId == null
          ? FloatingActionButton(
              onPressed: _showAddScheduleSheet,
              backgroundColor: colorScheme.primary,
              shape: const CircleBorder(),
              child: Icon(Icons.add, color: colorScheme.onPrimary),
            )
          : null,
    );
  }
}

// Custom ScheduleCard for CombinedSchedule
class _CombinedScheduleCard extends StatelessWidget {
  final List<CombinedSchedule> schedules;
  final Function(CombinedSchedule)? onScheduleTap;

  const _CombinedScheduleCard({required this.schedules, this.onScheduleTap});

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Widget _buildScheduleItem(
    BuildContext context,
    CombinedSchedule schedule,
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

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_formatTime(schedule.startTime)} - ${_formatTime(schedule.endTime)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 4),

                        Text(
                          schedule.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        // Source, Location, Lecturer in one line
                        if (schedule.isClass || schedule.location != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (schedule.isClass) ...[
                                Text(
                                  schedule.sourceName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.primary.withOpacity(0.8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (schedule.location != null ||
                                    schedule.lecturer != null)
                                  Text(
                                    ' | ',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colorScheme.onSurface.withOpacity(
                                        0.5,
                                      ),
                                    ),
                                  ),
                              ],
                              if (schedule.location != null &&
                                  schedule.location!.isNotEmpty) ...[
                                Text(
                                  schedule.location!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.onSurface.withOpacity(
                                      0.6,
                                    ),
                                  ),
                                ),
                                if (schedule.isClass &&
                                    schedule.lecturer != null &&
                                    schedule.lecturer!.isNotEmpty)
                                  Text(
                                    ' | ',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colorScheme.onSurface.withOpacity(
                                        0.5,
                                      ),
                                    ),
                                  ),
                              ],
                              if (schedule.isClass &&
                                  schedule.lecturer != null &&
                                  schedule.lecturer!.isNotEmpty) ...[
                                Text(
                                  schedule.lecturer!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.onSurface.withOpacity(
                                      0.6,
                                    ),
                                  ),
                                ),
                              ],
                            ],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1D29) : colorScheme.surface,
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
