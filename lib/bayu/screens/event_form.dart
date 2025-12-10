import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../../ilham/widgets/left_drawer.dart';
import '../../ilham/widgets/navbar.dart';
import '../../abi/models/CabangOlahraga.dart';
import '../models/events.dart';

class EventFormPage extends StatefulWidget {
  final Events? event;
  final bool isGlobal;

  const EventFormPage({super.key, this.event, this.isGlobal = false});

  @override
  State<EventFormPage> createState() => _EventFormPageState();
}

class _EventFormPageState extends State<EventFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Variabel Input User
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _pictureUrlController = TextEditingController();

  // Variabel Dropdown (Menyimpan ID)
  String? _selectedSportId;

  // List Data Cabang Olahraga dari Django
  List<CabangOlahragaElement> _sportList = [];

  // Variabel Tanggal & Waktu
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  @override
  void initState() {
    super.initState();
    _fetchSportBranches(); // Fetch dropdown data first

    if (widget.event != null) {
      _titleController.text = widget.event!.title;
      _descriptionController.text = widget.event!.description;
      _locationController.text = widget.event!.location;

      // Handle null image
      _pictureUrlController.text = widget.event!.pictureUrl ?? "";

      // Parse existing date
      _selectedDate = widget.event!.startTime;
      _selectedTime = TimeOfDay.fromDateTime(widget.event!.startTime);
    }
  }

  // dispse to prevent memory leaks
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _pictureUrlController.dispose();
    super.dispose();
  }

  Future<void> _fetchSportBranches() async {
    final request = context.read<CookieRequest>();

    try {
      final response = await request.get('http://127.0.0.1:8000/showJSONCabangOlahraga/');

      var listData = response['cabangOlahraga'];
      List<CabangOlahragaElement> tempList = [];

      for (var d in listData) {
        tempList.add(CabangOlahragaElement.fromJson(d));
      }

      setState(() {
        _sportList = tempList;
      });
    } catch (e) {
      debugPrint("Gagal mengambil data cabang olahraga: $e");
    }
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && context.mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _selectedTime,
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDate = pickedDate;
          _selectedTime = pickedTime;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: const MainNavbar(),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- INPUT JUDUL ---
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: "Title",
                  hintText: "Masukkan nama turnamen",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
                ),

                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Judul tidak boleh kosong!";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // --- INPUT DESKRIPSI ---
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: "Description",
                  hintText: "Deskripsi detail acara...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
                ),
                maxLines: 3,

                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Deskripsi tidak boleh kosong!";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // --- INPUT LOKASI ---
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: "Location",
                  hintText: "Lokasi pertandingan",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Lokasi tidak boleh kosong!";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // --- DROPDOWN CABANG OLAHRAGA  ---
              DropdownButtonFormField<String>(
                value: _selectedSportId,
                hint: const Text("Pilih Cabang Olahraga"),

                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),

                items: _sportList.map((CabangOlahragaElement item) {
                  return DropdownMenuItem<String>(
                    value: item.id, // ID yang akan dikirim ke backend
                    child: Text(item.name), // Nama yang dilihat user
                  );
                }).toList(),

                onChanged: (String? val) {
                  setState(() {
                    _selectedSportId = val;
                  });
                },
                validator: (value) {
                  if (value == null) return "Harap pilih kategori olahraga";
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // --- INPUT URL GAMBAR ---
              TextFormField(
                controller: _pictureUrlController,
                decoration: InputDecoration(
                  labelText: "Picture URL",
                  hintText: "http://example.com/image.png",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
                ),
              ),
              const SizedBox(height: 20),

              // --- PEMILIH TANGGAL & WAKTU ---
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month, color: Colors.blue),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Waktu Mulai:", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          "${_selectedDate.day}-${_selectedDate.month}-${_selectedDate.year} "
                              "at ${_selectedTime.format(context)}",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () => _selectDateTime(context),
                      child: const Text("Ubah"),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // --- TOMBOL SAVE ---
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size.fromHeight(50), // Lebar tombol full
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {

                    // 1. Gabungkan Date dan Time
                    final fullDateTime = DateTime(
                      _selectedDate.year, _selectedDate.month, _selectedDate.day,
                      _selectedTime.hour, _selectedTime.minute,
                    );

                    String url;
                    if (widget.event == null) {
                      url = "http://127.0.0.1:8000/event/create-flutter/";
                    } else if (widget.isGlobal){
                      url = "http://127.0.0.1:8000/events/create-flutter-global/";
                    } else {
                      url = "http://127.0.0.1:8000/events/create-flutter/";
                    }

                    // 2. Kirim ke Django
                    final response = await request.postJson(
                      url,
                      <String, dynamic>{
                        'title': _titleController.text, // Use controller.text
                        'description': _descriptionController.text,
                        'location': _locationController.text,
                        'cabang_olahraga_id': _selectedSportId,
                        'picture_url': _pictureUrlController.text,
                        'start_time': fullDateTime.toIso8601String(),
                      },
                    );

                    // 3. Cek Response
                    if (context.mounted) {
                      if (response['status'] == 'success') {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Event berhasil dibuat!"),
                          backgroundColor: Colors.green,
                        ));
                        Navigator.pop(context, true); // Kembali ke halaman list
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Gagal: ${response['message']}"),
                          backgroundColor: Colors.red,
                        ));
                      }
                    }
                  }
                },
                child: const Text(
                  "Simpan Event",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}