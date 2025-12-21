import 'package:flutter/material.dart';
import 'package:tk2/delila/models/news_entry.dart';
import 'dart:convert'; // Wajib untuk base64Decode
import 'dart:typed_data';

class NewsEntryCard extends StatelessWidget {
  final NewsEntry news;
  final VoidCallback onTap;

  const NewsEntryCard({super.key, required this.news, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          elevation: 2,
          clipBehavior:
              Clip.antiAlias, // Memastikan gambar mengikuti border radius card
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- THUMBNAIL ---
              SizedBox(
                width: double.infinity,
                height: 200,
                child: () {
                  // 1. Cek apakah thumbnail kosong
                  if (news.thumbnail == null ||
                      news.thumbnail!.trim().isEmpty) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(child: Icon(Icons.image, size: 50)),
                    );
                  }

                  final rawThumbnail = news.thumbnail!;

                  // 2. LOGIC KHUSUS BASE64 (Ini solusi masalahmu!)
                  if (rawThumbnail.startsWith('data:image')) {
                    try {
                      // Kita harus buang bagian header "data:image/jpeg;base64,"
                      // dan ambil isinya saja (setelah tanda koma)
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
                      print("Error decoding base64: $e");
                      return const Center(child: Icon(Icons.error));
                    }
                  }

                  // 3. LOGIC URL BIASA (Pakai Proxy Django)
                  // Hanya jalan kalau thumbnail BUKAN base64 (misal: http://...)
                  final encodedUrl = Uri.encodeComponent(rawThumbnail);

                  // Ingat: Web pakai 127.0.0.1, Emulator pakai 10.0.2.2
                  final proxyUrl =
                      "https://angelo-benhanan-paraworld.pbp.cs.ui.ac.id/news/proxy-image/?url=$encodedUrl";

                  return Image.network(
                    proxyUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Debugging
                      print("Gagal load proxy: $proxyUrl");
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
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- TITLE ---
                    Text(
                      news.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // --- CATEGORY ---
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        (categoryValues.reverse[news.category] ?? 'Other')
                            .toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.indigo.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // --- CONTENT PREVIEW ---
                    Text(
                      news.content,
                      maxLines: 3, // Batasi 3 baris
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
