import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:tk2/delila/models/news_entry.dart';
import 'package:tk2/ilham/screens/menu.dart'; // Sesuaikan import ini jika perlu

class EditNewsPage extends StatefulWidget {
  final NewsEntry news;

  const EditNewsPage({super.key, required this.news});

  @override
  State<EditNewsPage> createState() => _EditNewsPageState();
}

class _EditNewsPageState extends State<EditNewsPage> {
  final _formKey = GlobalKey<FormState>();

  late String _title;
  late String _content;
  late String _category;
  late String _thumbnail;

  final List<String> _categories = [
    'athlete',
    'event',
    'medal',
    'other',
  ];

  @override
  void initState() {
    super.initState();
    _title = widget.news.title;
    _content = widget.news.content;
    // Handle jika kategori dari backend tidak ada di list
    String initialCat = categoryValues.reverse[widget.news.category] ?? 'other';
    if (!_categories.contains(initialCat)) {
      initialCat = 'other';
    }
    _category = initialCat;
    _thumbnail = widget.news.thumbnail ?? "";
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Edit Berita')),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === TITLE ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  initialValue: _title,
                  decoration: InputDecoration(
                    hintText: "Judul Berita",
                    labelText: "Judul Berita",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (value) => _title = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Judul tidak boleh kosong!";
                    }
                    return null;
                  },
                ),
              ),

              // === CONTENT ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  initialValue: _content,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: "Isi Berita",
                    labelText: "Isi Berita",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (value) => _content = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Isi berita tidak boleh kosong!";
                    }
                    return null;
                  },
                ),
              ),

              // === CATEGORY ===
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
                  items: _categories.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(cat[0].toUpperCase() + cat.substring(1)),
                    );
                  }).toList(),
                  onChanged: (newValue) => setState(() {
                    _category = newValue!;
                  }),
                ),
              ),

              // === THUMBNAIL ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  initialValue: _thumbnail,
                  decoration: InputDecoration(
                    hintText: "URL Thumbnail (opsional)",
                    labelText: "URL Thumbnail",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (value) => _thumbnail = value,
                ),
              ),

              // === SAVE BUTTON ===
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
                        final response = await request.postJson(
                          // Pastikan URL ini benar
                          "http://localhost:8000/news/edit-flutter/${widget.news.id}/",
                          jsonEncode({
                            "title": _title,
                            "content": _content,
                            "thumbnail": _thumbnail,
                            "category": _category,
                          }),
                        );

                        if (context.mounted) {
                          // PERBAIKAN DISINI: Cek 'success' ATAU 'ok'
                          if (response['status'] == 'success' || response['status'] == 'ok') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("News successfully updated!"),
                              ),
                            );
                            // Kirim sinyal 'true' bahwa data berubah
                            Navigator.pop(context, true); 
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Error updating news."),
                              ),
                            );
                          }
                        }
                      }
                    },
                    child: const Text(
                      "Save Changes",
                      style: TextStyle(color: Colors.white),
                    ),
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