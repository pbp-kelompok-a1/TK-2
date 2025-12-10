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
  final String url = "http://127.0.0.1:8000/atlet/json/";

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

    // Anggap user admin jika sudah login (dpt diperketat lagi nnti)
    final bool isAdmin = request.loggedIn;

    return Scaffold(
      appBar: AppBar(title: const Text('List of Athletes')),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AtletFormPage(),
                  ),
                );
              },
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            )
          : null,
      body: FutureBuilder<List<AtletList>>(
        future: fetchAtlet(request),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No athlete data"));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var item = snapshot.data![index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          item.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text("${item.country} - ${item.discipline}"),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Total Medali
                            Text(
                              "${item.totalMedals} Medals",
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Row untuk Gold, Silver, Bronze
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (item.goldCount > 0) ...[
                                  const Text("🥇"),
                                  Text(
                                    "${item.goldCount} ",
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                                if (item.silverCount > 0) ...[
                                  const Text("🥈"),
                                  Text(
                                    "${item.silverCount} ",
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                                if (item.bronzeCount > 0) ...[
                                  const Text("🥉"),
                                  Text(
                                    "${item.bronzeCount} ",
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                        onTap: () {
                          // Logic Guest vs Member
                          if (request.loggedIn) {
                            // Jika sudah login, ke halaman detail
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailAtletPage(
                                  id: item.pk,
                                  name: item.name,
                                ),
                              ),
                            );
                          } else {
                            // Jika belum login (Guest), tampilkan pesan
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Login untuk melihat detail atlet!",
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                      ),
                      // Tombol EDIT & DELETE (hny jika Admin)
                      if (isAdmin)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Tombol Edit
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      // Kirim data item ke form agar jadi mode Edit
                                      builder: (context) =>
                                          AtletFormPage(atlet: item),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.edit,
                                  size: 18,
                                  color: Colors.orange,
                                ),
                                label: const Text(
                                  "Edit",
                                  style: TextStyle(color: Colors.orange),
                                ),
                              ),

                              const SizedBox(width: 8),

                              // Tombol Delete
                              TextButton.icon(
                                onPressed: () async {
                                  // Konfirmasi Hapus
                                  bool confirm =
                                      await showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text("Hapus Atlet"),
                                          content: Text(
                                            "Yakin ingin menghapus ${item.name}?",
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text("Batal"),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: const Text(
                                                "Hapus",
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ) ??
                                      false;

                                  if (confirm) {
                                    final response = await request.postJson(
                                      "http://127.0.0.1:8000/atlet/delete-ajax/${item.pk}/",
                                      jsonEncode({}),
                                    );

                                    if (context.mounted) {
                                      if (response['status'] == 'success') {
                                        setState(() {}); // Refresh list
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text("Berhasil dihapus!"),
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text("Gagal menghapus!"),
                                          ),
                                        );
                                      }
                                    }
                                  }
                                },
                                icon: const Icon(
                                  Icons.delete,
                                  size: 18,
                                  color: Colors.red,
                                ),
                                label: const Text(
                                  "Delete",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
