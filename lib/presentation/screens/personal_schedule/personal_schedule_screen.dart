import 'package:flutter/material.dart';
import 'personal_schedule_form.dart';

class PersonalScheduleScreen extends StatefulWidget {
  const PersonalScheduleScreen({super.key});

  @override
  State<PersonalScheduleScreen> createState() => _PersonalScheduleScreenState();
}

class _PersonalScheduleScreenState extends State<PersonalScheduleScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // 1. APP BAR (Bagian Atas)
      appBar: AppBar(
        title: const Text(
          "Jadwal Pribadi",
          style: TextStyle(
            color: Colors.black, 
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      // 2. BODY (Isi Halaman)
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              "Belum ada jadwal pribadi",
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
          ],
        ),
      ),

      // 3. TOMBOL TAMBAH (Pojok Kanan Bawah)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true, // Supaya form bisa tinggi
            backgroundColor: Colors.transparent,
            builder: (context) => const PersonalScheduleForm(),
          );
        },
        backgroundColor: const Color(0xFF10B981), // Warna Hijau Mint (Sesuai Desain)
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}