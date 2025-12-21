import 'package:flutter/material.dart';
import 'package:tk2/ilham/widgets/left_drawer.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:tk2/ilham/screens/menu.dart';

class NewsFormPage extends StatefulWidget {
  const NewsFormPage({super.key});

  @override
  State<NewsFormPage> createState() => _NewsFormPageState();
}

class _NewsFormPageState extends State<NewsFormPage> {
  final _formKey = GlobalKey<FormState>();

  String _title = "";
  String _content = "";
  String _category = "other";
  String _thumbnail = "";

  final List<String> _categories = [
    'athlete',
    'event',
    'medal',
    'other',
  ];

  @override
  Widget build(BuildContext context) {
      final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Form Tambah Berita')),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      drawer: LeftDrawer(),
      body: Form(
            key: _formKey, 
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
                  // === Title ===
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: "Judul Berita",
                        labelText: "Judul Berita",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
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
                  ),
                  // === Content ===
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: "Isi Berita",
                        labelText: "Isi Berita",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                      onChanged: (String? value) {
                        setState(() {
                          _content = value!;
                        });
                      },
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return "Isi berita tidak boleh kosong!";
                        }
                        return null;
                      },
                    ),
                  ),
                  // === Category ===
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: "Kategori",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                      value: _category,
                      items: _categories
                          .map((cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(
                                    cat[0].toUpperCase() + cat.substring(1)),
                              ))
                          .toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _category = newValue!;
                        });
                      },
                    ),
                  ),

                  // === Thumbnail URL ===
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: "URL Thumbnail (opsional)",
                        labelText: "URL Thumbnail",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                      onChanged: (String? value) {
                        setState(() {
                          _thumbnail = value!;
                        });
                      },
                    ),
                  ),
                  // === Tombol Simpan ===
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.indigo),
                                ),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    // TODO: Replace the URL with your app's URL
                                    // To connect Android emulator with Django on localhost, use URL http://10.0.2.2/
                                    // If you using chrome,  use URL http://localhost:8000
                                    
                                    final response = await request.postJson(
                                      "https://angelo-benhanan-paraworld.pbp.cs.ui.ac.id/create-flutter/",
                                      jsonEncode({
                                        "title": _title,
                                        "content": _content,
                                        "thumbnail": _thumbnail,
                                        "category": _category,
                                      }),
                                    );
                                    if (context.mounted) {
                                      if (response['status'] == 'success') {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          content: Text("News successfully saved!"),
                                        ));
                                        Navigator.pop(context, true);
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          content: Text("Something went wrong, please try again."),
                                        ));
                                      }
                                    }
                                  }
                                },
                                child: const Text(
                                  "Save",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ),
      )
    );
  }
}
