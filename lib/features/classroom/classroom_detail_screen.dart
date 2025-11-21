import 'package:flutter/material.dart';
import 'classroom_service.dart';
import '../../core/constants/app_color.dart';

class ClassroomDetailScreen extends StatefulWidget {
  final int classroomId;

  const ClassroomDetailScreen({
    Key? key,
    required this.classroomId,
  }) : super(key: key);

  @override
  State<ClassroomDetailScreen> createState() => _ClassroomDetailScreenState();
}

class _ClassroomDetailScreenState extends State<ClassroomDetailScreen> {
  late Future<Map<String, dynamic>?> futureDetail;

  @override
  void initState() {
    super.initState();
    futureDetail = ClassroomService.getClassDetail(widget.classroomId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Class Details")),
      body: FutureBuilder(
        future: futureDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data;
          if (data == null) {
            return const Center(child: Text("Gagal memuat data kelas"));
          }

          final members = data["members"] ?? [];
          final schedules = data["schedules"] ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data["name"] ?? "-",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColor.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data["description"] ?? "",
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColor.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  "Daftar Anggota",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColor.primary,
                  ),
                ),
                const SizedBox(height: 12),

                Column(
                  children: members.map<Widget>((m) {
                    return ListTile(
                      title: Text(m["name"] ?? "-"),
                      subtitle: Text("Role: ${m["role"] ?? '-'}"),
                      leading: const Icon(Icons.person),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                const Text(
                  "Jadwal Kelas",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColor.primary,
                  ),
                ),
                const SizedBox(height: 12),

                Column(
                  children: schedules.map<Widget>((s) {
                    return Card(
                      child: ListTile(
                        title: Text(s["course"] ?? "-"),
                        subtitle: Text(s["day"] ?? "-"),
                        trailing: const Icon(Icons.arrow_forward_ios),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
