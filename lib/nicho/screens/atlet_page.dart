import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:tk2/nicho/models/atlet.dart';
import 'package:tk2/nicho/screens/detail_atlet_page.dart';

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

    return Scaffold(
      appBar: AppBar(title: const Text('List of Athletes')),
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
                  child: ListTile(
                    title: Text(
                      item.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("${item.country} - ${item.discipline}"),
                    trailing: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${item.totalMedals} 🏅",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                    onTap: () {
                      // Logic Guest vs Member
                      if (request.loggedIn) {
                        // Jika sudah login, ke halaman detail
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DetailAtletPage(id: item.pk, name: item.name),
                          ),
                        );
                      } else {
                        // Jika belum login (Guest), tampilkan pesan
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Anda harus login untuk melihat detail atlet!",
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
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
