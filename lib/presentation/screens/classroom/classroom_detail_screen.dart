import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../data/models/classroom_model.dart';
import '../../../data/models/class_schedule_model.dart';
import '../../../providers/classroom_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/schedule_card.dart';
import '../../widgets/schedule_calendar.dart';
import '../../widgets/sheets/add_class_schedule_sheet.dart';
import '../../widgets/sheets/class_schedule_detail_sheet.dart';
import 'package:intl/intl.dart';
import 'classroom_info_screen.dart';

class ClassroomDetailScreen extends StatefulWidget {
  final Classroom classroom;

  const ClassroomDetailScreen({super.key, required this.classroom});

  @override
  State<ClassroomDetailScreen> createState() => _ClassroomDetailScreenState();
}

class _ClassroomDetailScreenState extends State<ClassroomDetailScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _showAllSchedules =
      true; // Default: tampilkan semua jadwal dari hari ini ke depan
  CalendarViewMode _calendarViewMode = CalendarViewMode.full;
  String _selectedDateFilter = 'all';
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;

    // Fetch class schedules for this classroom
    Future.microtask(() {
      _fetchSchedules();
    });
  }

  void _fetchSchedules({DateTime? startDate, DateTime? endDate}) {
    // If dates not provided, calculate based on current filter state
    if (startDate == null && endDate == null) {
      final baseDate = _selectedDay ?? DateTime.now();
      final start = DateTime(baseDate.year, baseDate.month, baseDate.day);

      if (_selectedDateFilter == 'custom') {
        startDate = _customStartDate;
        endDate = _customEndDate;
      } else {
        startDate = start;
        switch (_selectedDateFilter) {
          case '1d':
            endDate = startDate;
            break;
          case '3d':
            endDate = startDate!.add(const Duration(days: 2));
            break;
          case '7d':
            endDate = startDate!.add(const Duration(days: 6));
            break;
          case '1m':
            endDate = startDate!.add(const Duration(days: 30));
            break;
          case 'all':
            startDate = null;
            endDate = null;
            break;
        }
      }
    }

    Provider.of<ClassroomProvider>(context, listen: false).fetchClassSchedules(
      widget.classroom.id,
      startDate: startDate,
      endDate: endDate,
    );
  }

  void _handleDateFilterChange(String filter) async {
    DateTime? startDate;
    DateTime? endDate;
    final baseDate = _selectedDay ?? DateTime.now();

    if (filter == 'custom') {
      final picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(baseDate.year - 1),
        lastDate: DateTime(baseDate.year + 1),
        initialDateRange: _customStartDate != null && _customEndDate != null
            ? DateTimeRange(start: _customStartDate!, end: _customEndDate!)
            : null,
      );

      if (picked != null) {
        startDate = picked.start;
        endDate = picked.end;
        setState(() {
          _selectedDateFilter = filter;
          _customStartDate = startDate;
          _customEndDate = endDate;
          _showAllSchedules = false;
        });
      } else {
        return; // Cancelled
      }
    } else {
      setState(() {
        _selectedDateFilter = filter;
        _customStartDate = null;
        _customEndDate = null;
        _showAllSchedules = filter == 'all';
      });

      startDate = DateTime(baseDate.year, baseDate.month, baseDate.day);

      switch (filter) {
        case '1d':
          endDate = startDate;
          break;
        case '3d':
          endDate = startDate.add(const Duration(days: 2));
          break;
        case '7d':
          endDate = startDate.add(const Duration(days: 6));
          break;
        case '1m':
          endDate = startDate.add(const Duration(days: 30));
          break;
        case 'all':
          startDate = null;
          endDate = null;
          break;
        default:
          startDate = null;
          endDate = null;
          break;
      }
    }

    _fetchSchedules(startDate: startDate, endDate: endDate);
  }

  // Group schedules by date
  Map<String, List<ClassSchedule>> _groupSchedulesByDate(
    List<ClassSchedule> schedules,
  ) {
    final Map<String, List<ClassSchedule>> grouped = {};
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
      // if (_showAllSchedules && scheduleDate.isBefore(today)) {
      //   continue;
      // }

      // Filter berdasarkan tanggal yang dipilih jika tidak show all
      // Kita percayakan pada server-side filtering untuk range
      // If filter is 'all', only show schedules from selected day onwards in the list
      // The calendar will still show all events because it uses the raw list
      if (_selectedDateFilter == 'all' && _selectedDay != null) {
        final selectedDate = DateTime(
          _selectedDay!.year,
          _selectedDay!.month,
          _selectedDay!.day,
        );
        if (scheduleDate.isBefore(selectedDate)) {
          continue;
        }
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
  Map<DateTime, List<ScheduleEvent>> _getCalendarEvents(
    List<ClassSchedule> schedules,
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

  Widget _buildScheduleList(List<ClassSchedule> schedules) {
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
            Container(
              margin: EdgeInsets.only(bottom: 12, top: groupIndex > 0 ? 20 : 0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

            Padding(
              padding: EdgeInsets.only(
                bottom: groupIndex < groupedSchedules.length - 1 ? 8 : 0,
              ),
              child: ScheduleCard(
                schedules: schedulesForDate,
                onScheduleTap: (schedule) {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => ClassScheduleDetailSheet(
                      schedule: schedule,
                      classroom: widget.classroom,
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

  Future<void> _leaveClassroom() async {
    final classroomProvider = Provider.of<ClassroomProvider>(
      context,
      listen: false,
    );
    final classroom = widget.classroom;
    try {
      await classroomProvider.leaveClassroom(classroom.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Left classroom successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to leave classroom: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<AuthProvider>(context, listen: false).user;
    final isOwner = currentUser?.id == widget.classroom.ownerId;
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
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: colorScheme.onPrimary,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 48),
                        child: Text(
                          widget.classroom.name,
                          style: TextStyle(
                            color: colorScheme.onPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          color: colorScheme.onPrimary,
                        ),
                        color: isDark ? const Color(0xFF1C1D29) : Colors.white,
                        offset: const Offset(0, 50),
                        onSelected: (value) async {
                          if (value == 'detail') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ClassroomInfoScreen(
                                  classroom: widget.classroom,
                                ),
                              ),
                            );
                          } else if (value == 'leave') {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: colorScheme.surface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                title: Text(
                                  'Leave Classroom',
                                  style: TextStyle(
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                content: Text(
                                  'Are you sure you want to leave this classroom? You will need the classroom code to join again.',
                                  style: TextStyle(
                                    color: colorScheme.onSurface.withOpacity(
                                      0.7,
                                    ),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colorScheme.error,
                                      foregroundColor: colorScheme.onError,
                                    ),
                                    child: const Text('Leave'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/classroomList',
                                (route) => false,
                              );
                              await _leaveClassroom();
                            }
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          final items = <PopupMenuEntry<String>>[
                            PopupMenuItem<String>(
                              value: 'detail',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 20,
                                    color: colorScheme.onSurface,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'View Detail',
                                    style: TextStyle(
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ];
                          if (!isOwner) {
                            items.add(
                              PopupMenuItem<String>(
                                value: 'leave',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.exit_to_app,
                                      size: 20,
                                      color: colorScheme.onSurface,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Leave Classroom',
                                      style: TextStyle(
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return items;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: Consumer<ClassroomProvider>(
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
                  _fetchSchedules();
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

              // Schedule list header with show all button
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
                    Row(
                      children: [
                        // Filter Dropdown
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: DropdownButton<String>(
                            value: _selectedDateFilter,
                            isDense: true,
                            underline: const SizedBox(),
                            icon: Icon(
                              Icons.filter_list,
                              size: 16,
                              color: colorScheme.primary,
                            ),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.primary,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: '1d',
                                child: Text('1 Day'),
                              ),
                              DropdownMenuItem(
                                value: '3d',
                                child: Text('3 Days'),
                              ),
                              DropdownMenuItem(
                                value: '7d',
                                child: Text('7 Days'),
                              ),
                              DropdownMenuItem(
                                value: '1m',
                                child: Text('1 Month'),
                              ),
                              DropdownMenuItem(
                                value: 'custom',
                                child: Text('Custom'),
                              ),
                              DropdownMenuItem(
                                value: 'all',
                                child: Text('All'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                _handleDateFilterChange(value);
                              }
                            },
                          ),
                        ),
                      ],
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
      floatingActionButton: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final currentUser = authProvider.user;
          final isOwner = currentUser?.id == widget.classroom.ownerId;

          print(
            'Current User: ${currentUser?.id}, Owner: ${widget.classroom.ownerId}',
          );
          print('Is Owner: $isOwner');

          if (!isOwner) return const SizedBox.shrink();

          return FloatingActionButton(
            onPressed: _showAddScheduleSheet,
            backgroundColor: colorScheme.primary,
            shape: const CircleBorder(),
            child: Icon(Icons.add, color: colorScheme.onPrimary),
          );
        },
      ),
    );
  }

  void _showAddScheduleSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddClassScheduleSheet(
        classroom: widget.classroom,
        onSave: (data) async {
          final provider = Provider.of<ClassroomProvider>(
            context,
            listen: false,
          );
          await provider.createClassSchedule(
            classroomId: widget.classroom.id,
            title: data['title'],
            startTime: DateTime.parse(data['start_time']),
            endTime: DateTime.parse(data['end_time']),
            lecturer: data['lecturer'],
            location: data['location'],
            description: data['description'],
            color: data['color'],
            coordinator1: data['coordinator_1'],
            coordinator2: data['coordinator_2'],
            repeatDays: data['repeat_days'],
            repeatCount: data['repeat_count'],
            reminders: data['reminders'] != null
                ? List<int>.from(data['reminders'])
                : null,
          );
        },
      ),
    );
  }
}
