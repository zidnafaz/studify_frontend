import 'package:flutter/material.dart';
import 'classroom_service.dart';

class JoinClassScreen extends StatefulWidget {
  const JoinClassScreen({Key? key}) : super(key: key);

  @override
  State<JoinClassScreen> createState() => _JoinClassScreenState();
}

class _JoinClassScreenState extends State<JoinClassScreen> {
  final codeController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    final ok = await ClassroomService.joinClass(codeController.text);

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Berhasil Join Kelas")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kode tidak valid")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Join Classroom")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: codeController,
                decoration: const InputDecoration(labelText: "Unique Code"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Harus diisi" : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: submit,
                child: const Text("Join"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
