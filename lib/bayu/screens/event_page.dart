import 'package:flutter/material.dart';

import '../../ilham/widgets/left_drawer.dart';
import '../../ilham/widgets/navbar.dart';
import '../models/events.dart';


class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  // MASIH HARDCODE, BLOM TERINTEGRASI DENGAN DJANGO
  final List<Events> _dummyEvents = [
    Events(
      id: "1",
      title: "Roland Garros",
      description: "The French Open, also known as Roland-Garros...",
      sportBranch: "Tennis",
      location: "Paris, France",
      pictureUrl: "https://upload.wikimedia.org/wikipedia/en/thumb/8/82/Roland-Garros_Logo.svg/1200px-Roland-Garros_Logo.svg.png",
      startTime: DateTime(2025, 12, 10, 2, 55),
      endTime: null,
      eventType: "Community",
      creator: 1,
      cabangOlahraga: "Tennis",
      createdAt: DateTime.now(),
    ),

    Events(
      id: "2",
      title: "Wimbledon",
      description: "UK straweberyy cream",
      sportBranch: "Tennis",
      location: "wimbledon",
      pictureUrl: "", // tes kosongan
      startTime: DateTime(2026, 06, 15, 14, 00),
      endTime: null,
      eventType: "Global",
      creator: 2,
      cabangOlahraga: "Football",
      createdAt: DateTime.now(),
    ),
  ];

  String _selectedFilter = "All Events";

  @override
  Widget build(BuildContext context) {
    List<Events> displayedEvents = _dummyEvents;

    if (_selectedFilter == "Global ") {
      displayedEvents = _dummyEvents.where((event) => event.eventType == "Global").toList();
    } else if (_selectedFilter == "Community Events") {
      displayedEvents = _dummyEvents.where((event) => event.eventType == "Community").toList();
    }

    return Scaffold(
      drawer: const LeftDrawer(),
      appBar: const MainNavbar(),
      body: SingleChildScrollView(
        child: Column (
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBanner(),
            const SizedBox(height: 20),

            _buildTabsSection(displayedEvents.length),
            const SizedBox(height: 20),

            Padding (
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column (
                children: displayedEvents.map((event) => _buildCard(event)).toList(),
              ),
            ),
            const SizedBox(height: 40),
          ],
        )
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
              // LINK BUAT KE CREATE EVENT
              // TODO: Buat screen create event
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
    bool isCommunity = event.eventType == "Community";

    return Card (
      elevation : 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column (
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // buat image di cardnya
          Container (
            height: 150,
            width: double.infinity,
            decoration: const BoxDecoration (
              color: Color(0xFF004D40),
              borderRadius: BorderRadius.only (
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),

            child: const Center (
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
                    Container (
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC8E6C9),
                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: const Text (
                        "Community Tournament",
                        style: TextStyle(color: Color(0xFF2E7D32), fontSize: 10, fontWeight: FontWeight.bold),
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