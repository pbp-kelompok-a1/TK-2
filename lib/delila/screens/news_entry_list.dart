import 'package:flutter/material.dart';
import 'package:tk2/delila/models/news_entry.dart';
import 'package:tk2/delila/screens/newslist_form.dart';
import 'package:tk2/ilham/widgets/left_drawer.dart';
import 'package:tk2/delila/screens/news_detail.dart';
import 'package:tk2/delila/widgets/news_entry_card.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class NewsEntryListPage extends StatefulWidget {
  const NewsEntryListPage({super.key});

  @override
  State<NewsEntryListPage> createState() => _NewsEntryListPageState();
}

class _NewsEntryListPageState extends State<NewsEntryListPage> {
  Future<List<NewsEntry>> fetchNews(CookieRequest request) async {
  
      // URL tetap localhost sesuai request
      final response = await request.get('http://localhost:8000/news/json/');
      
      var data = response;
      List<NewsEntry> listNews = [];
      for (int i = 0; i < data.length; i++) {
        var d = data[i];
        if (d != null) {
            listNews.add(NewsEntry.fromJson(d));
        }
      }
      return listNews;
  } 

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('PARALYMPIC NEWS'),
      ),
      drawer: const LeftDrawer(),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          // BAGIAN INI SUDAH BENAR (Create News)
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewsFormPage()),
          );

          if (result == true) {
            setState(() {}); 
          }
        },
      ),
      body: FutureBuilder(
        future: fetchNews(request),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } 
          else if (snapshot.hasError) {
             return Center(
               child: Text('Error: ${snapshot.error}'),
             );
          }
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'There are no news in Paralympic yet.',
                    style: TextStyle(fontSize: 20, color: Color(0xff59A5D8)),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                ],
              ),
            );
          } 
          else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (_, index) => NewsEntryCard(
                news: snapshot.data![index],
                // --- PERBAIKAN DI SINI ---
                onTap: () async { // 1. Tambah async
                  final result = await Navigator.push( // 2. Tambah await & tampung result
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewsDetailPage(
                        news: snapshot.data![index],
                      ),
                    ),
                  );

                  // 3. Jika result true (dari delete/edit), refresh list
                  if (result == true) {
                    setState(() {});
                  }
                },
                // -------------------------
              ),
            );
          }
        },
      ),
    );
  }
}