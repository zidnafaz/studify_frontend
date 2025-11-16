import 'package:flutter/material.dart';
import 'create_class_screen.dart';
import 'join_class_screen.dart';
import 'classroom_detail_screen.dart';
import 'classroom_service.dart';

class ClassroomListScreen extends StatefulWidget {
  const ClassroomListScreen({Key? key}) : super(key: key);

  @override
  State<ClassroomListScreen> createState() => _ClassroomListScreenState();
}

class _ClassroomListScreenState extends State<ClassroomListScreen> {
  late Future<List<dynamic>> futureClassrooms;

  @override
  void initState() {
    super.initState();
    futureClassrooms = ClassroomService.getClassrooms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Classrooms")),
      body: FutureBuilder(
        future: futureClassrooms,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data ?? [];

          if (data.isEmpty) {
            return const Center(child: Text("Belum ada kelas"));
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];

              return ListTile(
                title: Text(item["name"] ?? "-"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ClassroomDetailScreen(
                        classroomId: item["id"],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: "create",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateClassScreen()),
              ).then((_) {
                setState(() {
                  futureClassrooms = ClassroomService.getClassrooms();
                });
              });
            },
            label: const Text("Create Class"),
            icon: const Icon(Icons.add),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: "join",
            backgroundColor: Colors.green,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const JoinClassScreen()),
              ).then((_) {
                setState(() {
                  futureClassrooms = ClassroomService.getClassrooms();
                });
              });
            },
            label: const Text("Join Class"),
            icon: const Icon(Icons.meeting_room),
          ),
        ],
      ),
    );
  }
}
