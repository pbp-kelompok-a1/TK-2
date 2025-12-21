import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class DetailAtletPage extends StatefulWidget {
  final int id;
  final String name;

  const DetailAtletPage({Key? key, required this.id, required this.name})
    : super(key: key);

  @override
  _DetailAtletPageState createState() => _DetailAtletPageState();
}

class _DetailAtletPageState extends State<DetailAtletPage> {
  final String baseUrl = "http://127.0.0.1:8000/atlet/json-detail/";

  Future<Map<String, dynamic>> fetchDetail(CookieRequest request) async {
    final response = await request.get("$baseUrl${widget.id}/");
    return response;
  }

  // 1. Fungsi hapus medali
  Future<void> deleteMedal(int medalId) async {
    final request = context.read<CookieRequest>();
    final response = await request.post(
      "http://127.0.0.1:8000/atlet/delete-medali-flutter/$medalId/",
      {},
    );
    if (response['status'] == 'success') {
      setState(() {}); // Refresh UI
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Medal deleted")));
    }
  }

  // 2. Pop up form edit
  void showEditDialog(Map<String, dynamic> medali) {
    TextEditingController typeController = TextEditingController(
      text: medali['medal_type'],
    );
    TextEditingController eventController = TextEditingController(
      text: medali['event'],
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Medal"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: typeController,
              decoration: const InputDecoration(labelText: "Medal Type"),
            ),
            TextField(
              controller: eventController,
              decoration: const InputDecoration(labelText: "Event"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final request = context.read<CookieRequest>();
              final response = await request.post(
                "http://127.0.0.1:8000/atlet/edit-medali-flutter/${medali['pk']}/",
                jsonEncode({
                  "medal_type": typeController.text,
                  "event": eventController.text,
                  "medal_date": medali['medal_date'],
                }),
              );
              if (response['status'] == 'success') {
                Navigator.pop(context);
                setState(() {}); // Refresh list medali
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // 3. Pop up konfirmasi hapus
  void showDeleteConfirm(int medalId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete?"),
        content: const Text("Are you sure you want to delete this medal?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteMedal(medalId);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Fungsi utks kirim data ke Django
  Future<void> addMedal(String type, String event) async {
    final request = context.read<CookieRequest>();
    final response = await request.post(
      "http://127.0.0.1:8000/atlet/add-medali-flutter/${widget.id}/",
      jsonEncode({
        "medal_type": type,
        "event": event,
        "medal_date": "2024-01-01",
      }),
    );
    if (response['status'] == 'success') {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("New medal added successfully!")),
      );
    }
  }

  // Fungsi utk menampilkan pop up form
  void showAddMedalDialog() {
    TextEditingController typeController = TextEditingController();
    TextEditingController eventController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Medal"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: typeController,
              decoration: const InputDecoration(
                labelText: "Medal Type (Gold/Silver/Bronze)",
              ),
            ),
            TextField(
              controller: eventController,
              decoration: const InputDecoration(labelText: "Event Name"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              addMedal(typeController.text, eventController.text);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final bool isAdmin = request.loggedIn;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F9), // warna background
      appBar: AppBar(
        title: const Text('Athlete Detail'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueGrey,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchDetail(request),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("Data not found"));
          } else {
            final data = snapshot.data!;
            final medaliList = data['medali_list'] as List;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Header utk nama & subtitle (Cabor | Negara)
                  Text(
                    data['name'].toString().toUpperCase(),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  // Tampilkan short name di bawah nama
                  if (data['short_name'] != "-")
                    Text(
                      "${data['short_name']}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),

                  const SizedBox(height: 8),
                  // Subtitle: Cabor | Negara yang dibela
                  Text(
                    "(${data['discipline']} | ${data['country']})",
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 25),

                  // 2. Athlete Information Card
                  buildSectionHeader("Athlete Information"),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        buildInfoRow("Short Name", data['short_name'] ?? "-"),
                        buildInfoRow(
                          "Representing/Country",
                          data['country'] ?? "-",
                        ),
                        buildInfoRow("Nationality", data['nationality'] ?? "-"),
                        buildInfoRow("Gender", data['gender'] ?? "-"),
                        buildInfoRow("Birth Date", data['birth_date'] ?? "-"),
                        buildInfoRow("Birth Place", data['birth_place'] ?? "-"),
                        buildInfoRow(
                          "Birth Country",
                          data['birth_country'] ?? "-",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // 3. Medal History Section
                  buildSectionHeader("Medal History"),

                  // Tombol add medali (hny utk admin)
                  if (isAdmin)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            showAddMedalDialog();
                          },
                          icon: const Icon(Icons.add),
                          label: const Text("Add New Medal"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5CB85C),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // List Medali
                  medaliList.isEmpty
                      ? const Card(
                          child: ListTile(
                            title: Text("No medals recorded yet."),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: medaliList.length,
                          itemBuilder: (context, index) {
                            var medali = medaliList[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "${medali['medal_type']} (${medali['medal_date']})",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        if (isAdmin)
                                          Row(
                                            children: [
                                              buildActionBtn(
                                                "Edit",
                                                Colors.amber,
                                                () {
                                                  showEditDialog(medali);
                                                },
                                              ),
                                              const SizedBox(width: 5),
                                              buildActionBtn(
                                                "Delete",
                                                Colors.red,
                                                () {
                                                  showDeleteConfirm(
                                                    medali['pk'],
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      medali['event'],
                                      style: const TextStyle(
                                        color: Colors.blueGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  // UI helper, header bagian
  Widget buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: const BoxDecoration(
        color: Color(0xFFD9EAF7),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2C3E50),
        ),
      ),
    );
  }

  // UI helper, baris informasi
  Widget buildInfoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey,
            ),
          ),
          Text(value, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }

  // UI helper, tombol edit/delete medali
  Widget buildActionBtn(String label, Color color, VoidCallback onPressed) {
    return SizedBox(
      height: 30,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          textStyle: const TextStyle(fontSize: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        child: Text(label),
      ),
    );
  }
}
