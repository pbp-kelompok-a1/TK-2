import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:tk2/ilham/widgets/navbar.dart';
import 'package:tk2/ilham/widgets/left_drawer.dart';
import 'package:tk2/nicho/models/atlet.dart';
import 'package:tk2/delila/models/news_entry.dart';
import 'package:tk2/bayu/models/events.dart';
import 'package:tk2/nicho/screens/atlet_page.dart';
import 'package:tk2/nicho/screens/detail_atlet_page.dart';
import 'package:tk2/delila/screens/news_entry_list.dart';
import 'package:tk2/delila/screens/news_detail.dart';
import 'package:tk2/bayu/screens/event_page.dart';

import 'dart:convert';
import 'dart:typed_data';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  Future<List<AtletList>> fetchAtlet(CookieRequest request) async {
    final response = await request.get("https://angelo-benhanan-paraworld.pbp.cs.ui.ac.id/atlet/json/");
    List<AtletList> listAtlet = [];
    for (var d in response) {
      if (d != null) {
        listAtlet.add(AtletList.fromJson(d));
      }
    }
    return listAtlet;
  }

  Future<List<NewsEntry>> fetchNews(CookieRequest request) async {
    final response = await request.get("https://angelo-benhanan-paraworld.pbp.cs.ui.ac.id/news/json/");
    List<NewsEntry> listNews = [];
    for (var d in response) {
      if (d != null) {
        listNews.add(NewsEntry.fromJson(d));
      }
    }
    return listNews;
  }

  Future<List<Events>> fetchEvents(CookieRequest request) async {
    final response = await request.get("https://angelo-benhanan-paraworld.pbp.cs.ui.ac.id/events/json/");
    List<Events> listEvents = [];
    for (var d in response) {
      if (d != null) {
        listEvents.add(Events.fromJson(d));
      }
    }
    return listEvents;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      drawer: const LeftDrawer(),
      appBar: MainNavbar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image Section
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3BC3FD), Color(0xFF2196F3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/hero.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(color: Color(0xFF3BC3FD));
                      },
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.black.withOpacity(0.3),
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome to ParaWorld',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Discover Paralympic athletes, events, and news',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Athletes Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Featured Athletes',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AtletPage()),
                      );
                    },
                    child: Text('View All'),
                  ),
                ],
              ),
            ),

            SizedBox(height: 12),

            // Athletes Horizontal Scroll
            FutureBuilder<List<AtletList>>(
              future: fetchAtlet(request),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError) {
                  return Container(
                    height: 200,
                    child: Center(child: Text("Error loading athletes")),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Container(
                    height: 200,
                    child: Center(child: Text("No athletes available")),
                  );
                }

                // Ambil maksimal 6 atlet untuk ditampilkan
                List<AtletList> athletes = snapshot.data!.take(6).toList();

                return Container(
                  height: 220,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    itemCount: athletes.length + 1, // +1 untuk card "See More"
                    itemBuilder: (context, index) {
                      // Card "See More" di akhir
                      if (index == athletes.length) {
                        return _buildSeeMoreCard(context);
                      }

                      var athlete = athletes[index];
                      return _buildAthleteCard(athlete, request, context);
                    },
                  ),
                );
              },
            ),

            SizedBox(height: 32),

            // News Section (Placeholder)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Latest News',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NewsEntryListPage()),
                      );
                    },
                    child: Text('View All'),
                  ),
                ],
              ),
            ),

            SizedBox(height: 12),

            // News Cards
            FutureBuilder<List<NewsEntry>>(
              future: fetchNews(request),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    height: 180,
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError) {
                  return Container(
                    height: 180,
                    child: Center(child: Text("Error loading news")),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Container(
                    height: 180,
                    child: Center(child: Text("No news available")),
                  );
                }

                // Ambil maksimal 6 news untuk ditampilkan
                List<NewsEntry> newsList = snapshot.data!.take(6).toList();

                return Container(
                  height: 240,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    itemCount: newsList.length + 1, // +1 untuk card "See More"
                    itemBuilder: (context, index) {
                      // Card "See More" di akhir
                      if (index == newsList.length) {
                        return _buildSeeMoreCard(context, label: 'News');
                      }

                      var news = newsList[index];
                      return _buildNewsCard(news, context);
                    },
                  ),
                );
              },
            ),

            SizedBox(height: 32),

            // Events Section (Placeholder)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Upcoming Events',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EventPage()),
                      );
                    },
                    child: Text('View All'),
                  ),
                ],
              ),
            ),

            SizedBox(height: 12),

            // Events Cards
            FutureBuilder<List<Events>>(
              future: fetchEvents(request),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    height: 180,
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError) {
                  return Container(
                    height: 180,
                    child: Center(child: Text("Error loading events")),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Container(
                    height: 180,
                    child: Center(child: Text("No events available")),
                  );
                }

                // Ambil maksimal 6 events untuk ditampilkan
                List<Events> eventsList = snapshot.data!.take(6).toList();

                return Container(
                  height: 220,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    itemCount: eventsList.length + 1, // +1 untuk card "See More"
                    itemBuilder: (context, index) {
                      // Card "See More" di akhir
                      if (index == eventsList.length) {
                        return _buildSeeMoreCard(context, label: 'Events');
                      }

                      var event = eventsList[index];
                      return _buildEventCard(event);
                    },
                  ),
                );
              },
            ),

            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // Widget untuk Athlete Card
  Widget _buildAthleteCard(AtletList athlete, CookieRequest request, BuildContext context) {
    return Container(
      width: 160,
      margin: EdgeInsets.symmetric(horizontal: 4),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () {
            if (request.loggedIn) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailAtletPage(
                    id: athlete.pk,
                    name: athlete.name,
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Login to view athlete details!"),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar atau Foto Atlet
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Color(0xFF3BC3FD).withOpacity(0.3),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Center(
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Color(0xFF3BC3FD),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      athlete.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      athlete.country,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        if (athlete.goldCount > 0)
                          Text("🥇${athlete.goldCount} ", style: TextStyle(fontSize: 11)),
                        if (athlete.silverCount > 0)
                          Text("🥈${athlete.silverCount} ", style: TextStyle(fontSize: 11)),
                        if (athlete.bronzeCount > 0)
                          Text("🥉${athlete.bronzeCount}", style: TextStyle(fontSize: 11)),
                      ],
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

  // Widget untuk See More Card
  Widget _buildSeeMoreCard(BuildContext context, {String label = 'Athletes'}) {
    return Container(
      width: 140,
      margin: EdgeInsets.symmetric(horizontal: 4),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Color(0xFF3BC3FD), width: 2),
        ),
        child: InkWell(
          onTap: () {
            // Navigate based on label
            if (label == 'Athletes') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AtletPage()),
              );
            } else if (label == 'News') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NewsEntryListPage()),
              );
            } else if (label == 'Events') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EventPage()),
              );
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF3BC3FD),
                size: 40,
              ),
              SizedBox(height: 12),
              Text(
                'See More\n$label',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF3BC3FD),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget untuk News Card
  Widget _buildNewsCard(NewsEntry news, BuildContext context) {
    final request = context.watch<CookieRequest>();
    final currentUsername = (request.jsonData != null && request.jsonData.containsKey('username'))
        ? request.jsonData['username']
        : '';

    return Container(
      width: 280,
      margin: EdgeInsets.symmetric(horizontal: 4),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewsDetailPage(
                  news: news,
                  currentUsername: currentUsername,
                ),
              ),
            );
            // Note: Since this is a StatelessWidget, we can't use setState here
            // If you need to refresh after returning, consider making MyHomePage a StatefulWidget
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              SizedBox(
                width: double.infinity,
                height: 130,
                child: () {
                  // Cek apakah thumbnail kosong
                  if (news.thumbnail == null || news.thumbnail!.trim().isEmpty) {
                    return Container(
                      color: Colors.grey[300],
                      child: Center(
                        child: Icon(Icons.article, size: 40, color: Colors.grey[600]),
                      ),
                    );
                  }

                  final rawThumbnail = news.thumbnail!;

                  // Logic Base64
                  if (rawThumbnail.startsWith('data:image')) {
                    try {
                      final base64String = rawThumbnail.split(',').last;
                      Uint8List decodedBytes = base64Decode(base64String);

                      return Image.memory(
                        decodedBytes,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[300],
                          child: Center(
                            child: Icon(Icons.broken_image, color: Colors.grey[600]),
                          ),
                        ),
                      );
                    } catch (e) {
                      return Container(
                        color: Colors.grey[300],
                        child: Center(
                          child: Icon(Icons.error, color: Colors.grey[600]),
                        ),
                      );
                    }
                  }

                  // Logic URL dengan Proxy
                  final encodedUrl = Uri.encodeComponent(rawThumbnail);
                  final proxyUrl = "https://angelo-benhanan-paraworld.pbp.cs.ui.ac.id/proxy-image/?url=$encodedUrl";

                  return Image.network(
                    proxyUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: Center(
                          child: Icon(Icons.broken_image, size: 40, color: Colors.grey[600]),
                        ),
                      );
                    },
                  );
                }(),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Badge
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        (categoryValues.reverse[news.category] ?? 'Other').toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.indigo.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 6),
                    // Title
                    Text(
                      news.title,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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

  // Widget untuk Event Card
  Widget _buildEventCard(Events event) {
    bool isGlobal = event.eventType.toLowerCase() == "global";
    Color badgeColor = isGlobal ? Color(0xFFE3F2FD) : Color(0xFFC8E6C9);
    Color badgeTextColor = isGlobal ? Color(0xFF1565C0) : Color(0xFF2E7D32);
    String badgeText = isGlobal ? "Global" : "Community";
    bool hasImage = event.pictureUrl != null && event.pictureUrl!.isNotEmpty;

    return Container(
      width: 220,
      margin: EdgeInsets.symmetric(horizontal: 4),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image/Icon
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFF004D40),
              ),
              child: hasImage
                  ? Image.network(
                      event.pictureUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Icon(Icons.broken_image, color: Colors.white, size: 40),
                      ),
                    )
                  : Center(
                      child: Icon(Icons.sports_tennis, color: Colors.white, size: 50),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        color: badgeTextColor,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  // Title
                  Text(
                    event.title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6),
                  // Date & Location
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 12, color: Colors.blue),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          "${event.startTime.day}/${event.startTime.month}/${event.startTime.year}",
                          style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 12, color: Colors.blue),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                          style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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