import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:tk2/nicho/models/atlet.dart';
import 'package:tk2/nicho/screens/atlet_page.dart';

class AtletFormPage extends StatefulWidget {
  final AtletList? atlet; // Kalau null = mode Create, kalau ada isi = mode Edit

  const AtletFormPage({Key? key, this.atlet}) : super(key: key);

  @override
  State<AtletFormPage> createState() => _AtletFormPageState();
}

class _AtletFormPageState extends State<AtletFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Variabel utk menyimpan input user
  String _name = "";
  String _country = "";
  String _discipline = "Swimming"; // Default awal

  @override
  void initState() {
    super.initState();
    // Jika mode edit (dmn widget.atlet tidak null), isi form dengan data lama
    if (widget.atlet != null) {
      _name = widget.atlet!.name;
      _country = widget.atlet!.country;
      _discipline = widget.atlet!.discipline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final isEdit = widget.atlet != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? "Edit Athlete" : "Add New Athlete")),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Input Nama
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                onChanged: (String? value) {
                  setState(() {
                    _name = value!;
                  });
                },
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Name cannot be empty!";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Input Negara
              TextFormField(
                initialValue: _country,
                decoration: const InputDecoration(
                  labelText: "Country",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag),
                ),
                onChanged: (String? value) {
                  setState(() {
                    _country = value!;
                  });
                },
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Country cannot be empty!";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Input Discipline (Cabang Olahraga)
              TextFormField(
                initialValue: _discipline,
                decoration: const InputDecoration(
                  labelText: "Discipline",
                  hintText: "e.g. Swimming, Archery",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.sports_handball),
                ),
                onChanged: (String? value) {
                  setState(() {
                    _discipline = value!;
                  });
                },
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Discipline cannot be empty!";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Tombol Simpan
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final String url = isEdit
                        ? "http://127.0.0.1:8000/atlet/edit-flutter/${widget.atlet!.pk}/"
                        : "http://127.0.0.1:8000/atlet/create-flutter/";

                    // Kirim JSON
                    final response = await request.postJson(
                      url,
                      jsonEncode(<String, String>{
                        'name': _name,
                        'country': _country,
                        'discipline': _discipline,
                      }),
                    );

                    if (context.mounted) {
                      if (response['status'] == 'success') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Data saved successfully!"),
                          ),
                        );
                        // Balik ke list dan refresh
                        // Menggunakan pushReplacement bukan pop() agar halaman list terganti dengan yang baru
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AtletPage(),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Error: ${response['message']}"),
                          ),
                        );
                      }
                    }
                  }
                },
                child: Text(
                  "Save",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
