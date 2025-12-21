import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:tk2/nicho/models/atlet.dart';
import 'package:tk2/nicho/screens/detail_atlet_page.dart';
import 'package:tk2/nicho/screens/atlet_form_page.dart';

class AtletPage extends StatefulWidget {
  const AtletPage({Key? key}) : super(key: key);

  @override
  _AtletPageState createState() => _AtletPageState();
}

class _AtletPageState extends State<AtletPage> {
  final String url =
      "https://angelo-benhanan-paraworld.pbp.cs.ui.ac.id/atlet/json/";

  // Variabel state utk filter
  String _searchQuery = "";
  String _selectedDiscipline = "All";

  Future<List<AtletList>> fetchAtlet(CookieRequest request) async {
    final response = await request.get(url);
    List<AtletList> listAtlet = [];
    for (var d in response) {
      if (d != null) {
        listAtlet.add(AtletList.fromJson(d));
      }
    }
    return listAtlet;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final bool isAdmin =
        request.loggedIn && (request.jsonData['is_admin'] == true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ParaWorld Athletes'),
        backgroundColor: const Color(0xFF3BC3FD),
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AtletFormPage(),
                  ),
                ).then((value) {
                  if (value == true) {
                    setState(() {});
                  }
                });
              },
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            )
          : null,
      body: Column(
        children: [
          // BAGIAN SEARCH & FILTER
          Container(
            padding: const EdgeInsets.all(12.0),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: "Search athlete name...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),

          // DAFTAR ATLET
          Expanded(
            child: FutureBuilder<List<AtletList>>(
              future: fetchAtlet(request),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No athlete data"));
                } else {
                  // Ambil list unik discipline utk dropdown filter
                  List<String> disciplines =
                      ["All"] +
                      snapshot.data!.map((e) => e.discipline).toSet().toList();

                  // LOGIC FILTERING
                  List<AtletList> filteredList = snapshot.data!.where((item) {
                    bool matchesSearch = item.name.toLowerCase().contains(
                      _searchQuery,
                    );
                    bool matchesDiscipline =
                        _selectedDiscipline == "All" ||
                        item.discipline == _selectedDiscipline;
                    return matchesSearch && matchesDiscipline;
                  }).toList();

                  return Column(
                    children: [
                      // Dropdown filter discipline
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            const Text("Filter by Sport: "),
                            const SizedBox(width: 10),
                            DropdownButton<String>(
                              value: _selectedDiscipline,
                              items: disciplines.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedDiscipline = newValue!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                      // ListView yg sudah difilter
                      Expanded(
                        child: ListView.builder(
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            var item = filteredList[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                children: [
                                  ListTile(
                                    title: Text(
                                      item.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      "${item.country} - ${item.discipline}",
                                    ),
                                    trailing: medalWidget(item),
                                    onTap: () {
                                      if (request.loggedIn) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                DetailAtletPage(
                                                  id: item.pk,
                                                  name: item.name,
                                                ),
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Login to view athlete details!",
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                  if (isAdmin)
                                    adminButtons(context, item, request),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget helper utk medali
  Widget medalWidget(AtletList item) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          "${item.totalMedals} Medals",
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.goldCount > 0) Text("🥇${item.goldCount} "),
            if (item.silverCount > 0) Text("🥈${item.silverCount} "),
            if (item.bronzeCount > 0) Text("🥉${item.bronzeCount} "),
          ],
        ),
      ],
    );
  }

  // Widget helper utk tombol admin
  Widget adminButtons(
    BuildContext context,
    AtletList item,
    CookieRequest request,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AtletFormPage(atlet: item),
                ),
              ).then((value) {
                if (value == true) {
                  setState(() {}); // Refresh list jika sukses edit
                }
              });
            },
            icon: const Icon(Icons.edit, size: 18, color: Colors.orange),
            label: const Text("Edit", style: TextStyle(color: Colors.orange)),
          ),
          TextButton.icon(
            onPressed: () => deleteAtlet(context, item, request),
            icon: const Icon(Icons.delete, size: 18, color: Colors.red),
            label: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Fungsi delete
  Future<void> deleteAtlet(
    BuildContext context,
    AtletList item,
    CookieRequest request,
  ) async {
    bool confirm =
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Delete Athlete"),
            content: Text("Are you sure you want to delete ${item.name}?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      final response = await request.postJson(
        "https://angelo-benhanan-paraworld.pbp.cs.ui.ac.id/atlet/delete-ajax/${item.pk}/",
        jsonEncode({}),
      );
      if (response['status'] == 'success') {
        setState(() {});
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Successfully deleted!")));
      }
    }
  }
}
