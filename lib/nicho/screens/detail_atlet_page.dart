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

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(title: Text(widget.name)),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchDetail(request),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("Data tidak ditemukan"));
          } else {
            final data = snapshot.data!;
            final medaliList = data['medali_list'] as List;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Card
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['name'],
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(),
                          Text("Country: ${data['country']}"),
                          Text("Discipline: ${data['discipline']}"),
                          Text("Birth Date: ${data['birth_date'] ?? '-'}"),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Medals Won",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  // List Medali
                  medaliList.isEmpty
                      ? const Text("Belum ada medali yang terekam.")
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: medaliList.length,
                          itemBuilder: (context, index) {
                            var medali = medaliList[index];
                            Color medalColor;
                            if (medali['medal_type'] == 'Gold Medal')
                              medalColor = Colors.yellow.shade700;
                            else if (medali['medal_type'] == 'Silver Medal')
                              medalColor = Colors.grey.shade400;
                            else
                              medalColor = Colors.brown.shade300;

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              child: ListTile(
                                leading: Icon(
                                  Icons.emoji_events,
                                  color: medalColor,
                                ),
                                title: Text(medali['event']),
                                subtitle: Text(
                                  "${medali['medal_type']} - ${medali['medal_date']}",
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
}
