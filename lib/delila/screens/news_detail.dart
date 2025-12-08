import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:tk2/delila/models/news_entry.dart';
import 'package:tk2/delila/screens/edit_news_page.dart';

class NewsDetailPage extends StatelessWidget {
  final NewsEntry news;

  const NewsDetailPage({super.key, required this.news});

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
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

                final response = await request.postJson(
                  "http://localhost:8000/news/delete-flutter/$newsId/",
                  "{}",
                );

                if (context.mounted) {
                  Navigator.pop(context); // close dialog

                  if (response['status'] == 'success') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("News deleted")),
                    );
                    Navigator.pop(context, true); // balik ke list + refresh
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Failed to delete")),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('News Detail'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            SizedBox(
              width: double.infinity,
              height: 250,
              child: () {
                if (news.thumbnail == null || news.thumbnail!.trim().isEmpty) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(child: Icon(Icons.image, size: 50)),
                  );
                }

                final proxyUrl =
                    "http://localhost:8000/proxy-image/?url=${Uri.encodeComponent(news.thumbnail!)}";

                return Image.network(
                  proxyUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 50),
                    ),
                  ),
                );
              }(),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    news.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Category + Author + Date
                  Row(
                    children: [
                      // CATEGORY PILL
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
                          categoryValues.reverse[news.category]!.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo.shade700,
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // AUTHOR
                      Text(
                        "by ${authorValues.reverse[news.author]!}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(width: 12),

                      // DATE
                      Text(
                        _formatDate(news.createdAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),

                  const Divider(height: 32),

                  // CONTENT
                  Text(
                    news.content,
                    style: const TextStyle(fontSize: 16, height: 1.6),
                    textAlign: TextAlign.justify,
                  ),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // EDIT BUTTON
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditNewsPage(news: news),
                            ),
                          ).then((changed) {
                            if (changed == true) {
                              Navigator.pop(context); // refresh detail page
                            }
                          });
                        },
                        child: const Text(
                          "Edit",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),

                      // DELETE BUTTON
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () {
                          _confirmDelete(context, news.id);
                        },
                        child: const Text(
                          "Delete",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
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
