import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:tk2/delila/models/news_entry.dart';
import 'package:tk2/delila/screens/newslist_form.dart';
import 'package:tk2/ilham/widgets/left_drawer.dart';
import 'package:tk2/delila/screens/news_detail.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class NewsEntryListPage extends StatefulWidget {
  const NewsEntryListPage({super.key});

  @override
  State<NewsEntryListPage> createState() => _NewsEntryListPageState();
}

class _NewsEntryListPageState extends State<NewsEntryListPage> {
  // --- WARNA UTAMA SESUAI REQUEST (UPDATED) ---
  final Color primaryColor = const Color(0xFF3BC3FD); // Biru cerah baru
  final Color secondaryColor = const Color(0xFF2C3E50);

  // --- STATE ---
  bool isAdmin = false;
  String currentUsername = "Guest"; 
  String selectedCategory = "All"; 
  final List<String> filterOptions = ["All", "Athlete", "Medal", "Event", "Other"];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUserStatus();
    });
  }

  Future<void> _checkUserStatus() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get('https://angelo-benhanan-paraworld.pbp.cs.ui.ac.id/news/get-user-status/'); 
      if (mounted) {
        setState(() {
          isAdmin = response['is_staff'] ?? false;
          currentUsername = response['username'] ?? "Guest";
        });
      }
    } catch (e) {
      print("❌ Gagal cek status user: $e");
    }
  }

  Future<List<NewsEntry>> fetchNews(CookieRequest request) async {
  
      // URL tetap localhost sesuai request
      final response = await request.get('https://angelo-benhanan-paraworld.pbp.cs.ui.ac.id/news/json/');
      
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
      backgroundColor: const Color(0xFFF5F9FC), 
      appBar: AppBar(
        title: const Text(
          'PARALYMPIC NEWS',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: primaryColor.withOpacity(0.5),
      ),
      drawer: const LeftDrawer(),
      
      floatingActionButton: isAdmin 
        ? FloatingActionButton(
            backgroundColor: secondaryColor,
            foregroundColor: Colors.white,
            elevation: 10,
            child: const Icon(Icons.add, size: 30),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NewsFormPage()),
              );
              if (result == true) setState(() {}); 
            },
          )
        : null,

      body: Column(
        children: [
          // --- 1. FILTER SECTION ---
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: SingleChildScrollView( 
              scrollDirection: Axis.horizontal,
              child: Row(
                children: filterOptions.map((category) {
                  final bool isSelected = selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      selectedColor: primaryColor,
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color: isSelected ? primaryColor : Colors.grey.shade300,
                      ),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : secondaryColor,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                      onSelected: (bool selected) {
                        if (selected) {
                          setState(() {
                            selectedCategory = category;
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // --- 2. GRID CONTENT ---
          Expanded(
            child: FutureBuilder(
              future: fetchNews(request),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: primaryColor));
                } 
                else if (snapshot.hasError) {
                   return Center(child: Text('Error: ${snapshot.error}'));
                }
                else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.newspaper, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text('No news available.', style: TextStyle(color: secondaryColor)),
                      ],
                    ),
                  );
                } 
                else {
                  // FILTER LOGIC
                  List<NewsEntry> allNews = snapshot.data!;
                  List<NewsEntry> displayedNews = [];

                  if (selectedCategory == "All") {
                    displayedNews = allNews;
                  } else {
                    displayedNews = allNews.where((news) {
                      String newsCategoryString = news.category.toString().split('.').last.toUpperCase();
                      return newsCategoryString == selectedCategory.toUpperCase();
                    }).toList();
                  }

                  if (displayedNews.isEmpty) {
                    return Center(child: Text("No news found for '$selectedCategory'"));
                  }

                  // --- RESPONSIVE GRID LAYOUT (UPDATED) ---
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = 1; 
                      double width = constraints.maxWidth;

                      // UBAH LOGIKA DI SINI:
                      // Full screen (desktop) -> 3 card
                      // Tablet -> 2 card
                      // Mobile -> 1 card
                      if (width > 1100) {
                        crossAxisCount = 3; 
                      } else if (width > 700) {
                        crossAxisCount = 2; 
                      } else {
                        crossAxisCount = 1; 
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.4, // Aspect ratio disesuaikan dikit
                        ),
                        itemCount: displayedNews.length,
                        itemBuilder: (context, index) {
                          return _HoverableNewsCard(
                            news: displayedNews[index],
                            primaryColor: primaryColor,
                            secondaryColor: secondaryColor,
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NewsDetailPage(
                                    news: displayedNews[index],
                                    currentUsername: currentUsername,
                                  ),
                                ),
                              );
                              if (result == true) setState(() {});
                            },
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// --- WIDGET CARD DENGAN ISI PREVIEW & WARNA BARU ---
class _HoverableNewsCard extends StatefulWidget {
  final NewsEntry news;
  final VoidCallback onTap;
  final Color primaryColor;
  final Color secondaryColor;

  const _HoverableNewsCard({
    required this.news,
    required this.onTap,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  State<_HoverableNewsCard> createState() => _HoverableNewsCardState();
}

class _HoverableNewsCardState extends State<_HoverableNewsCard> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    // Logic Gambar
    Widget buildThumbnail() {
      if (widget.news.thumbnail == null || widget.news.thumbnail!.isEmpty) {
        return Container(
          color: widget.primaryColor.withOpacity(0.2),
          child: Center(child: Icon(Icons.article, size: 50, color: widget.primaryColor)),
        );
      }
      final rawThumbnail = widget.news.thumbnail!;
      if (rawThumbnail.startsWith('data:image')) {
        try {
          final base64String = rawThumbnail.split(',').last;
          Uint8List decodedBytes = base64Decode(base64String);
          return Image.memory(decodedBytes, fit: BoxFit.cover);
        } catch (e) {
          return const Center(child: Icon(Icons.error));
        }
      }
      final encodedUrl = Uri.encodeComponent(rawThumbnail);
      return Image.network(
        "https://angelo-benhanan-paraworld.pbp.cs.ui.ac.id/proxy-image/?url=$encodedUrl",
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => isHovering = true),
      onExit: (_) => setState(() => isHovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          // UBAH DI SINI: Scale hanya 1.02 (dikit aja)
          transform: isHovering ? Matrix4.identity().scaled(1.02) : Matrix4.identity(),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.primaryColor.withOpacity(isHovering ? 0.4 : 0.1),
                blurRadius: isHovering ? 20 : 10,
                offset: isHovering ? const Offset(0, 10) : const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: isHovering ? widget.primaryColor : Colors.transparent,
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Gambar
                Expanded(
                  flex: 4,
                  child: SizedBox(
                    width: double.infinity,
                    child: buildThumbnail(),
                  ),
                ),
                
                // 2. Konten Teks
                Expanded(
                  flex: 4, // Flex dikurangi sedikit
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Kategori Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: widget.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.news.category.toString().split('.').last.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: widget.primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Judul
                        Text(
                          widget.news.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: widget.secondaryColor,
                          ),
                        ),
                        
                        const SizedBox(height: 6),
                        
                        // BAGIAN ISI BERITA (PREVIEW)
                        Expanded(
                          child: Text(
                            widget.news.content, 
                            // UBAH DI SINI: maxLines jadi 2 saja
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              height: 1.3, 
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}