import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/classroom_provider.dart';
import '../../widgets/classroom/classroom_card.dart';
import '../../widgets/classroom/empty_classroom_state.dart';
import '../../widgets/sheets/classroom_action_sheet.dart';
import '../../widgets/primary_floating_action_button.dart';
import 'classroom_detail_screen.dart';

class ClassroomScreen extends StatefulWidget {
  const ClassroomScreen({super.key});

  @override
  State<ClassroomScreen> createState() => _ClassroomScreenState();
}

class _ClassroomScreenState extends State<ClassroomScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _loadClassrooms();
    });
  }

  Future<void> _loadClassrooms() async {
    try {
      await context.read<ClassroomProvider>().fetchClassrooms();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat classroom: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
                child: Text(
                  'Classroom List',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Consumer<ClassroomProvider>(
        builder: (context, classroomProvider, child) {
          return RefreshIndicator(
            onRefresh: _loadClassrooms,
            child: _buildBody(classroomProvider),
          );
        },
      ),
      floatingActionButton: PrimaryFloatingActionButton(
        onPressed: _showClassroomActionSheet,
        tooltip: 'Classroom Actions',
      ),
    );
  }

  Widget _buildBody(ClassroomProvider provider) {
    if (provider.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    if (provider.classrooms.isEmpty) {
      return const EmptyClassroomState();
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      itemCount: provider.classrooms.length,
      itemBuilder: (context, index) {
        final classroom = provider.classrooms[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ClassroomCard(
            classroom: classroom,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ClassroomDetailScreen(classroom: classroom),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showClassroomActionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const ClassroomActionSheet(),
    );
  }
}
