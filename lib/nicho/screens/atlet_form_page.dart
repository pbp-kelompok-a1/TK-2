import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:tk2/nicho/models/atlet.dart';
import 'package:tk2/nicho/screens/atlet_page.dart';

class AtletFormPage extends StatefulWidget {
  final AtletList? atlet;

  const AtletFormPage({Key? key, this.atlet}) : super(key: key);

  @override
  State<AtletFormPage> createState() => _AtletFormPageState();
}

class _AtletFormPageState extends State<AtletFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _shortNameController;
  late TextEditingController _countryController;
  late TextEditingController _disciplineController;
  late TextEditingController _birthPlaceController;
  late TextEditingController _birthCountryController;
  late TextEditingController _nationalityController;
  late TextEditingController _birthDateController;

  String _gender = "Male";

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.atlet?.name ?? "");
    _shortNameController = TextEditingController(
      text: widget.atlet?.shortName ?? "",
    );
    _countryController = TextEditingController(
      text: widget.atlet?.country ?? "",
    );
    _disciplineController = TextEditingController(
      text: widget.atlet?.discipline ?? "Swimming",
    );
    _birthPlaceController = TextEditingController(
      text: widget.atlet?.birthPlace ?? "",
    );
    _birthCountryController = TextEditingController(
      text: widget.atlet?.birthCountry ?? "",
    );
    _nationalityController = TextEditingController(
      text: widget.atlet?.nationality ?? "",
    );
    _birthDateController = TextEditingController(
      text: widget.atlet?.birthDate ?? "",
    );

    if (widget.atlet?.gender != null) {
      _gender = widget.atlet!.gender!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _shortNameController.dispose();
    _countryController.dispose();
    _disciplineController.dispose();
    _birthPlaceController.dispose();
    _birthCountryController.dispose();
    _nationalityController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final isEdit = widget.atlet != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Athlete" : "Add New Athlete"),
        backgroundColor: const Color(0xFF3BC3FD),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Basic Information",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              buildTextField("Full Name", _nameController, Icons.person),
              buildTextField(
                "Short Name (Optional)",
                _shortNameController,
                Icons.badge,
              ),
              buildTextField("Discipline", _disciplineController, Icons.sports),
              buildTextField("Country", _countryController, Icons.flag),

              const SizedBox(height: 10),
              const Text(
                "Personal Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Dropdown gender
              DropdownButtonFormField<String>(
                initialValue: _gender,
                decoration: const InputDecoration(
                  labelText: "Gender",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.wc),
                ),
                items: ["Male", "Female"].map((String value) {
                  return DropdownMenuItem(value: value, child: Text(value));
                }).toList(),
                onChanged: (val) => setState(() => _gender = val!),
              ),
              const SizedBox(height: 12),

              // Input birth date
              TextFormField(
                controller: _birthDateController,
                decoration: const InputDecoration(
                  labelText: "Birth Date (e.g. 1990-10-16)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  // Memunculkan kalender
                  FocusScope.of(context).requestFocus(FocusNode());
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime(1995),
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _birthDateController.text = picked.toString().split(
                        ' ',
                      )[0]; // Ambil YYYY-MM-DD
                    });
                  }
                },
              ),
              const SizedBox(height: 12),

              buildTextField(
                "Birth Place",
                _birthPlaceController,
                Icons.location_city,
              ),
              buildTextField(
                "Birth Country",
                _birthCountryController,
                Icons.public,
              ),
              buildTextField(
                "Nationality",
                _nationalityController,
                Icons.language,
              ),

              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final String url = isEdit
                        ? "http://127.0.0.1:8000/atlet/edit-flutter/${widget.atlet!.pk}/"
                        : "http://127.0.0.1:8000/atlet/create-flutter/";

                    final response = await request.postJson(
                      url,
                      jsonEncode({
                        'name': _nameController.text,
                        'short_name': _shortNameController.text,
                        'discipline': _disciplineController.text,
                        'country': _countryController.text,
                        'gender': _gender,
                        'birth_date': _birthDateController.text,
                        'birth_place': _birthPlaceController.text,
                        'birth_country': _birthCountryController.text,
                        'nationality': _nationalityController.text,
                      }),
                    );

                    if (context.mounted) {
                      if (response['status'] == 'success') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Data saved successfully!"),
                          ),
                        );
                        Navigator.pop(context, true);
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
                child: const Text(
                  "SAVE ATHLETE",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget helper
  Widget buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: Icon(icon),
        ),
        validator: (value) {
          if (label != "Short Name (Optional)" &&
              (value == null || value.isEmpty)) {
            return "$label cannot be empty!";
          }
          return null;
        },
      ),
    );
  }
}
