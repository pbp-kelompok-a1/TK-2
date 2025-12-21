import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:tk2/delila/models/news_entry.dart';
import 'package:tk2/delila/screens/edit_news_page.dart';
import 'package:tk2/delila/screens/news_entry_list.dart';
import 'package:tk2/ilham/widgets/comment.dart';
import 'dart:convert';
import 'dart:typed_data';

class NewsDetailPage extends StatelessWidget {
  final NewsEntry news;
  final String currentUsername; // 1. Tambah variabel ini

  // 2. Wajibkan di constructor
  const NewsDetailPage({
    super.key, 
    required this.news, 
    required this.currentUsername
  });

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} '
        '${date.year}, ${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  void _confirmDelete(BuildContext context, int newsId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete News"),
          content: const Text("Are you sure you want to delete this news?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                final request = context.read<CookieRequest>();
                Navigator.pop(context); 

                final response = await request.postJson(
                  "http://localhost:8000/news/delete-flutter/$newsId/",
                  "{}",
                );

                if (context.mounted) {
                  if (response['status'] == 'success' ||
                      response['status'] == 'ok') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("News deleted successfully"),
                      ),
                    );
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NewsEntryListPage(),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Failed to delete news")),
                    );
                  }
                }
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 3. LOGIKA PENGECEKAN AUTHOR
    // Kita ambil string nama author dari enum/model
    String authorName = authorValues.reverse[news.author] ?? 'Unknown';
    
    // Cek apakah user yang login sama dengan pembuat berita
    bool isOwner = currentUsername == authorName;

    return Scaffold(
      appBar: AppBar(
        title: const Text('News Detail'),
        backgroundColor: const Color(0xFF3BC3FD),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- THUMBNAIL SECTION ---
            SizedBox(
              width: double.infinity,
              height: 200,
              child: () {
                if (news.thumbnail == null || news.thumbnail!.trim().isEmpty) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(child: Icon(Icons.image, size: 50)),
                  );
                }

                final rawThumbnail = news.thumbnail!;

                if (rawThumbnail.startsWith('data:image')) {
                  try {
                    final base64String = rawThumbnail.split(',').last;
                    Uint8List decodedBytes = base64Decode(base64String);

                    return Image.memory(
                      decodedBytes,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: const Center(child: Icon(Icons.broken_image)),
                      ),
                    );
                  } catch (e) {
                    return const Center(child: Icon(Icons.error));
                  }
                }

                final encodedUrl = Uri.encodeComponent(rawThumbnail);
                final proxyUrl =
                    "http://localhost:8000/proxy-image/?url=$encodedUrl";

                return Image.network(
                  proxyUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 50),
                      ),
                    );
                  },
                );
              }(),
            ),

            Padding(
              // --- UPDATE DI SINI: Memberi jarak horizontal lebih (24.0) ---
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- TITLE ---
                  Text(
                    news.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // --- METADATA ROW ---
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          (categoryValues.reverse[news.category] ?? 'Other')
                              .toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "by ${news.author ?? 'Unknown'}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatDate(news.createdAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),

                  const Divider(height: 32),

                  // --- CONTENT ---
                  Text(
                    news.content,
                    style: const TextStyle(fontSize: 16, height: 1.6),
                    textAlign: TextAlign.justify,
                  ),

                  const SizedBox(height: 24),

                  // --- BUTTONS (HANYA MUNCUL JIKA isOwner TRUE) ---
                  if (isOwner) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Edit Button
                        ElevatedButton.icon(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 18,
                          ),
                          label: const Text(
                            "Edit",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3BC3FD),
                          ),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditNewsPage(news: news),
                              ),
                            );

                            if (context.mounted && result == true) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const NewsEntryListPage(),
                                ),
                              );
                            }
                          },
                        ),

                        // Delete Button
                        ElevatedButton.icon(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 18,
                          ),
                          label: const Text(
                            "Delete",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () => _confirmDelete(context, news.id),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],

                  // --- SEPARATOR LINE ---
                  const Divider(
                    thickness: 1,
                    color: Colors.grey,
                  ),

                  const SizedBox(height: 16),

                  // --- COMMENT SECTION ---
                  CommentWidget(
                    newsId: news.id,
                    baseUrl: 'http://localhost:8000', 
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}