import 'dart:convert';

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

  String _currentUsername = "";
  bool _isAdmin = false;
  @override
  void initState() {
    super.initState();
    // Check role langsung saat page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUserRole();
    });
  }

  // check role dari django
  Future<void> _checkUserRole() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get("http://127.0.0.1:8000/events/user-status/");

      if (mounted) {
        setState(() {
          _isAdmin = response['is_superuser'] ?? false;
          _currentUsername = response['username'] ?? "";
        });
      }
    } catch (e) {
      print("Error fetching user role: $e");
    }
  }

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

                  //Debug lagi
                  if (events.isNotEmpty) {
                    print("Current Filter: '$_selectedFilter'");
                    print("Sample Event Type from DB: '${events[0].eventType}'");
                  }

                  if (_selectedFilter == "Global Events") {
                    events = events.where((e) =>
                    e.eventType.toString().toLowerCase().trim() == "global"
                    ).toList();
                  } else if (_selectedFilter == "Community Events") {
                    events = events.where((e) =>
                    e.eventType.toString().toLowerCase().trim() == "community"
                    ).toList();
                  }

                  return SingleChildScrollView(
                    child: Column (
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBanner(request), // Pass request here
                        const SizedBox(height: 20),

                        _buildTabsSection(events.length),
                        const SizedBox(height: 20),

                        Padding (
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column (
                            // Pass request di isni
                            children: events.map((event) => _buildCard(event, request)).toList(),
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

  Widget _buildBanner(CookieRequest request) {
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

          // Logic for displaying buttons
          if (!request.loggedIn) ...[
            const Text(
              "Log in to create tournaments.",
              style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
            )
          ] else ...[
            Wrap (
                spacing: 10,
                runSpacing: 10,
                children: [
                  // Community Event Button (Authorized only)
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EventFormPage(isGlobal: false)),
                      ).then((_) {
                        setState(() {});
                      });
                    },
                    icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                    label: const Text("Create Community Tournament", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C853),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),

                  //  Global Event Button (Admin Only)
                  if (_isAdmin)
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const EventFormPage(isGlobal: true)),
                        ).then((_) {
                          setState(() {});
                        });
                      },
                      icon: const Icon(Icons.star, color: Colors.white),
                      label: const Text("Create Global", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE65100),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                ]
            )
          ]
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


  Widget _buildCard(Events event, CookieRequest request) {
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
                        color: badgeColor,
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
                if (request.loggedIn && (_isAdmin || event.creator == _currentUsername))
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // --- EDIT BUTTON ---
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EventFormPage(event: event),
                            ),
                          ).then((_) {
                            setState(() {}); // Refresh list
                          });
                        },
                      ),

                      // --- DELETE BUTTON ---
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Event'),
                              content: const Text('Are you sure you want to delete this event?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true && context.mounted) {

                            try {
                              // DEBUG: JANGAN LUP AHAPUS
                              print("Attempting to delete event ID: ${event.id}");

                              final response = await request.postJson(
                                "http://127.0.0.1:8000/events/delete-flutter/${event.id}/",
                                jsonEncode(<String, dynamic>{}),
                              );

                              // DEBUG: JANGAN LUPA HAPUS
                              print("Server Response: $response");

                              if (context.mounted) {
                                if (response['status'] == 'success') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Event deleted successfully!")),
                                  );

                                  setState(() {});
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Failed: ${response['message']}")),
                                  );
                                }
                              }
                            } catch (e) {
                              print("Error during delete: $e");
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Error: $e")),
                                );
                              }
                            }
                          }
                        },
                      ),
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