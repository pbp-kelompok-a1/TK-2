import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../../ilham/widgets/left_drawer.dart';
import '../../ilham/widgets/navbar.dart';
import '../models/events.dart';
import '../screens/event_form.dart';


class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  String _selectedFilter = "All Events";

  Future<List<Events>> fetchEvents(CookieRequest request) async {
    final response = await request.get('http://127.0.0.1:8000/events/json/');

    var data = response;

    List<Events> listEvents = [];
    for (var d in data) {
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
      appBar: const MainNavbar(),
      body: FutureBuilder (
        future: fetchEvents(request),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (!snapshot.hasData) {
              return const Column(
                children: [
                  Text (
                    "No events found.",
                    style: TextStyle(color: Color(0xff59A5D8), fontSize: 20),
                  ),
                  SizedBox(height: 8),
                ],
              );
            } else {
              // filtering logic
              List<Events> events = snapshot.data!;

              if (_selectedFilter == "Global Events") {
                events = events.where((e) => e.eventType == "Global").toList();
              } else if (_selectedFilter == "Community Events") {
                events = events.where((e) => e.eventType == "Community").toList();
              }

              return SingleChildScrollView(
                child: Column (
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBanner(),
                    const SizedBox(height: 20),

                    _buildTabsSection(events.length),
                    const SizedBox(height: 20),

                    Padding (
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column (
                        children: events.map((event) => _buildCard(event)).toList(),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              );
            }
          }
        }
      )
    );
  }

  Widget _buildBanner() {
    return Container (
      margin: const EdgeInsets.all(20),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      decoration: BoxDecoration (
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [Color(0xFF007bff), Color(0xFF00c6ff)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Column (
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text (
            "Upcoming Sports Tournaments",
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),
          const Text (
            "View major Global Events and user-submitted Community Tournaments.",
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),

          const SizedBox(height: 20),
          ElevatedButton.icon (
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EventFormPage()),
              ).then((_) {
                setState(() {});
              });
            },

            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            label: const Text("Create Community Tournament Community Tournaments.", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C853),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabsSection(int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              _buildTabItem("All Events"),
              _buildTabItem("Global Events"),
              _buildTabItem("Community Events"),
            ],
          ),
          const Divider(),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "Showing $count Tournaments",
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title) {
    bool isActive = _selectedFilter == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = title;
        });
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 20, bottom: 10),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.blue : Colors.grey[700],
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            decoration: isActive ? TextDecoration.underline : TextDecoration.none,
            decorationColor: Colors.blue,
          ),
        ),
      ),
    );
  }


  Widget _buildCard(Events event) {
    bool isGlobal = event.eventType == "Global";

    // global menggunakan biru, community menggunakan hijau
    Color badgeColor = isGlobal ? const Color(0xFFE3F2FD) : const Color(0xFFC8E6C9);
    Color badgeTextColor = isGlobal ? const Color(0xFF1565C0) : const Color(0xFF2E7D32);
    String badgeText = isGlobal ? "Global Event" : "Community Tournament";

    // cek kalo ada image apa tidak
    bool hasImage = event.pictureUrl != null && event.pictureUrl!.isNotEmpty;

    return Card (
      elevation : 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column (
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // buat image di cardnya
          Container(
            height: 150,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF004D40),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            // kalo ada image, tampilkan imagenya, kalau tidak gunakan icon
            child: hasImage
                ? ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12)),
              child: Image.network(
                event.pictureUrl!,
                fit: BoxFit.cover,
                // Handle error kalo url rusak
                errorBuilder: (context, error, stackTrace) =>
                const Center(child: Icon(Icons.broken_image, color: Colors.white, size: 64)),
              ),
            )
                : const Center(
              child: Icon(Icons.sports_tennis, color: Colors.white, size: 64),
            ),
          ),


          // Card body
          Padding (
            padding: const EdgeInsets.all(16.0),
            child: Column (
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row (
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeColor, // Uses the variable we made at top
                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: Text (
                        badgeText,
                        style: TextStyle(color: badgeTextColor, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),

                    Text (
                      "By ${event.creator}",
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // judul
                Text (
                  event.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),

                // Description
                Text (
                  event.description,
                  style: const TextStyle(color: Colors.black87),
                ),
                const SizedBox(height: 15),

                // Tanggal
                Row (
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.blue),
                    const SizedBox(width:  8),
                    Text (
                      "${event.startTime.day}-${event.startTime.month}-${event.startTime.year}",
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Lokasi
                Row (
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text (
                      event.location,
                      style: const TextStyle(fontSize:12),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Edit/Delete button
                const Row (
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("Edit", style: TextStyle(color: Colors.blue, fontSize: 12)),
                    SizedBox(width: 10),
                    Text("Delete", style: TextStyle(color: Colors.red, fontSize: 12)),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}