import 'package:flutter/material.dart';
import 'package:tk2/delila/models/news_entry.dart';

class NewsEntryCard extends StatelessWidget {
  final NewsEntry news;
  final VoidCallback onTap;

  const NewsEntryCard({
    super.key,
    required this.news,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: InkWell(
        onTap: onTap,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                        child: const Center(child: Icon(Icons.broken_image, size: 50)),
                      ),
                    );
                  }(),
                ),

                const SizedBox(height: 8),

                // Title
                Text(
                  news.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                // Category (enum → string)
                Text(
                  categoryValues.reverse[news.category]!.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.indigo.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 6),

                // Content preview
                Text(
                  news.content.length > 100
                      ? '${news.content.substring(0, 100)}…'
                      : news.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
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