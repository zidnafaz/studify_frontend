import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/combined_schedule_model.dart';
import '../../../data/models/class_schedule_model.dart';
import '../../../data/models/classroom_model.dart';
import '../../../data/models/personal_schedule_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/classroom_provider.dart';
import '../../../providers/personal_schedule_provider.dart';
import 'class_schedule_detail_sheet.dart';
import 'personal_schedule_detail_sheet.dart';

class CombinedScheduleDetailSheet extends StatelessWidget {
  final CombinedSchedule schedule;

  const CombinedScheduleDetailSheet({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    // If personal schedule, use PersonalScheduleDetailSheet
    if (schedule.isPersonal) {
      return _buildPersonalDetailSheet(context);
    } else {
      // For class schedule, we need classroom info
      return _buildClassDetailSheet(context);
    }
  }

  Widget _buildPersonalDetailSheet(BuildContext context) {
    // Get userId from auth provider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.id ?? 0;

    // Try to find PersonalSchedule from provider first
    final personalScheduleProvider = Provider.of<PersonalScheduleProvider>(
      context,
      listen: false,
    );

    // Look for existing PersonalSchedule in provider
    PersonalSchedule? personalSchedule;
    try {
      personalSchedule = personalScheduleProvider.schedules.firstWhere(
        (s) => s.id == schedule.id,
      );
    } catch (e) {
      // Not found in provider, create from CombinedSchedule
      personalSchedule = PersonalSchedule(
        id: schedule.id,
        userId: userId,
        title: schedule.title,
        startTime: schedule.startTime,
        endTime: schedule.endTime,
        location: schedule.location,
        description: schedule.description,
        color: schedule.color,
        createdAt: schedule.startTime, // Approximate
        updatedAt: schedule.startTime, // Approximate
      );
    }

    return PersonalScheduleDetailSheet(schedule: personalSchedule);
  }

  Widget _buildClassDetailSheet(BuildContext context) {
    // We need to get classroom info
    return FutureBuilder<Classroom?>(
      future: _getClassroom(context),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final classroom = snapshot.data;
        if (classroom == null) {
          return const Center(child: Text('Classroom not found'));
        }

        // Convert CombinedSchedule to ClassSchedule
        final classSchedule = ClassSchedule(
          id: schedule.id,
          classroomId: schedule.sourceId!,
          coordinator1: schedule.coordinator1,
          coordinator2: schedule.coordinator2,
          title: schedule.title,
          startTime: schedule.startTime,
          endTime: schedule.endTime,
          location: schedule.location,
          lecturer: schedule.lecturer,
          description: schedule.description,
          color: schedule.color,
          createdAt: schedule.startTime, // Approximate
          updatedAt: schedule.startTime, // Approximate
          coordinator1User: schedule.coordinator1User,
          coordinator2User: schedule.coordinator2User,
        );

        return ClassScheduleDetailSheet(
          schedule: classSchedule,
          classroom: classroom,
        );
      },
    );
  }

  Future<Classroom?> _getClassroom(BuildContext context) async {
    if (schedule.sourceId == null) return null;

    final provider = Provider.of<ClassroomProvider>(context, listen: false);
    try {
      final classrooms = provider.classrooms;
      return classrooms.firstWhere(
        (c) => c.id == schedule.sourceId,
        orElse: () {
          // If not in list, fetch it
          throw Exception('Classroom not found');
        },
      );
    } catch (e) {
      // Try to fetch from API
      try {
        await provider.fetchClassrooms();
        final classrooms = provider.classrooms;
        return classrooms.firstWhere((c) => c.id == schedule.sourceId);
      } catch (e) {
        return null;
      }
    }
  }
}
