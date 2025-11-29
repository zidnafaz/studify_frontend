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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      // Supaya form naik kalau keyboard muncul
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // HEADER: Tombol Cancel, Judul, Tombol Save
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancel",
                  style: TextStyle(color: colorScheme.error),
                ),
              ),
              Text(
                "New Personal Event",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: colorScheme.onSurface,
                ),
              ),
              TextButton(
                onPressed: () {
                  // LOGIKA SIMPAN SEMENTARA (Nanti disambung ke Backend)
                  print("Judul: ${_titleController.text}");
                  print(
                    "Waktu: ${_startTime.format(context)} - ${_endTime.format(context)}",
                  );
                  Navigator.pop(context); // Tutup form setelah simpan
                },
                child: Text(
                  "Save",
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Divider(color: colorScheme.onSurfaceVariant.withOpacity(0.2)),

          // ISI FORM: Bisa di-scroll
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 1. INPUT JUDUL
                  TextField(
                    controller: _titleController,
                    style: TextStyle(color: colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: "Title",
                      hintStyle: TextStyle(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colorScheme.onSurfaceVariant.withOpacity(0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colorScheme.onSurfaceVariant.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. INPUT WAKTU (Mulai -> Selesai)
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimeButton(
                          "Start",
                          _startTime,
                          () => _pickTime(true),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Icon(
                          Icons.arrow_forward,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Expanded(
                        child: _buildTimeButton(
                          "End",
                          _endTime,
                          () => _pickTime(false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 3. INPUT TANGGAL
                  OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: Icon(
                      Icons.calendar_today,
                      color: colorScheme.onSurface,
                    ),
                    label: Text(
                      "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      alignment: Alignment.centerLeft,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 4. INPUT LOKASI
                  TextField(
                    controller: _locationController,
                    style: TextStyle(color: colorScheme.onSurface),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.location_on_outlined,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      hintText: "Location",
                      hintStyle: TextStyle(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colorScheme.onSurfaceVariant.withOpacity(0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colorScheme.onSurfaceVariant.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 5. INPUT DESKRIPSI
                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    style: TextStyle(color: colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: "Description",
                      hintStyle: TextStyle(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colorScheme.onSurfaceVariant.withOpacity(0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colorScheme.onSurfaceVariant.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.primary),
                      ),
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
    final colorScheme = Theme.of(context).colorScheme;
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(Icons.access_time, color: colorScheme.onSurface),
      label: Text(
        time.format(context),
        style: TextStyle(color: colorScheme.onSurface),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: colorScheme.onSurfaceVariant.withOpacity(0.3)),
      ),
    );
  }
}
