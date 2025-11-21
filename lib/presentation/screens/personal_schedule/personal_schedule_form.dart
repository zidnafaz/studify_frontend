import 'package:flutter/material.dart';

class PersonalScheduleForm extends StatefulWidget {
  const PersonalScheduleForm({super.key});

  @override
  State<PersonalScheduleForm> createState() => _PersonalScheduleFormState();
}

class _PersonalScheduleFormState extends State<PersonalScheduleForm> {
  // Controller untuk mengambil teks yang diketik user
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Variabel untuk menyimpan Tanggal & Waktu
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);

  // Fungsi Memilih Tanggal
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  // Fungsi Memilih Waktu
  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      // Supaya form naik kalau keyboard muncul
      height: MediaQuery.of(context).size.height * 0.9, 
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // HEADER: Tombol Cancel, Judul, Tombol Save
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel", style: TextStyle(color: Colors.red)),
              ),
              const Text("New Personal Event", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              TextButton(
                onPressed: () {
                   // LOGIKA SIMPAN SEMENTARA (Nanti disambung ke Backend)
                   print("Judul: ${_titleController.text}");
                   print("Waktu: ${_startTime.format(context)} - ${_endTime.format(context)}");
                   Navigator.pop(context); // Tutup form setelah simpan
                },
                child: const Text("Save", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Divider(),
          
          // ISI FORM: Bisa di-scroll
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 1. INPUT JUDUL
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: "Title",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. INPUT WAKTU (Mulai -> Selesai)
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimeButton("Start", _startTime, () => _pickTime(true)),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Icon(Icons.arrow_forward, color: Colors.grey),
                      ),
                      Expanded(
                        child: _buildTimeButton("End", _endTime, () => _pickTime(false)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 3. INPUT TANGGAL
                  OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today, color: Colors.black),
                    label: Text(
                      "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                      style: const TextStyle(color: Colors.black),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      alignment: Alignment.centerLeft,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 4. INPUT LOKASI
                  TextField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      hintText: "Location",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 5. INPUT DESKRIPSI
                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Description",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget kecil untuk tombol Jam biar rapi
  Widget _buildTimeButton(String label, TimeOfDay time, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.access_time, color: Colors.black),
      label: Text(
        time.format(context),
        style: const TextStyle(color: Colors.black),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}