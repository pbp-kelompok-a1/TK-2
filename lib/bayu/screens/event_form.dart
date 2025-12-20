import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../../ilham/widgets/left_drawer.dart';
import '../../ilham/widgets/navbar.dart';
import '../../abi/models/CabangOlahraga.dart';

class EventFormPage extends StatefulWidget {
  const EventFormPage({super.key});

  @override
  State<EventFormPage> createState() => _EventFormPageState();
}

class _EventFormPageState extends State<EventFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Variabel Input User
  String _title = "";
  String _description = "";
  String _location = "";
  String _pictureUrl = "";

  // Variabel Dropdown (Menyimpan ID)
  String? _selectedSportId;

  // List Data Cabang Olahraga dari Django
  List<CabangOlahragaElement> _sportList = [];

  // Variabel Tanggal & Waktu
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    // Ambil data cabang olahraga begitu halaman dibuka
    Future.microtask(() => _fetchSportBranches());
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
                decoration: InputDecoration(
                  labelText: "Title",
                  hintText: "Masukkan nama turnamen",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
                ),
                onChanged: (String? value) {
                  setState(() {
                    _title = value!;
                  });
                },
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
                decoration: InputDecoration(
                  labelText: "Description",
                  hintText: "Deskripsi detail acara...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
                ),
                maxLines: 3,
                onChanged: (String? value) {
                  setState(() {
                    _description = value!;
                  });
                },
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
                decoration: InputDecoration(
                  labelText: "Location",
                  hintText: "Lokasi pertandingan",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
                ),
                onChanged: (String? value) {
                  setState(() {
                    _location = value!;
                  });
                },
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

                // INI PERBAIKANNYA: Pindahkan border ke dalam InputDecoration
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
                decoration: InputDecoration(
                  labelText: "Picture URL",
                  hintText: "http://example.com/image.png",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
                ),
                onChanged: (String? value) {
                  setState(() {
                    _pictureUrl = value!;
                  });
                },
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

                    // 2. Kirim ke Django
                    // TODO: Pastikan URL ini sesuai dengan path di urls.py ('event/create-flutter/')
                    final response = await request.postJson(
                      "http://10.0.2.2:8000/event/create-flutter/",
                      jsonEncode(<String, dynamic>{
                        'title': _title,
                        'description': _description,
                        'location': _location,
                        'cabang_olahraga_id': _selectedSportId, // Kirim ID
                        'picture_url': _pictureUrl,
                        'start_time': fullDateTime.toIso8601String(),
                      }),
                    );

                    // 3. Cek Response
                    if (context.mounted) {
                      if (response['status'] == 'success') {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Event berhasil dibuat!"),
                          backgroundColor: Colors.green,
                        ));
                        Navigator.pop(context); // Kembali ke halaman list
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