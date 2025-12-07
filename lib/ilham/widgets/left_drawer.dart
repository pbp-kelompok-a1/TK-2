import 'package:flutter/material.dart';
import 'package:tk2/abi/screens/ProfilePage.dart';
import 'package:tk2/ilham/screens/menu.dart';
import 'package:tk2/nicho/screens/atlet_page.dart';
import 'package:tk2/bayu/screens/event_page.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            color: Colors.blue,
            padding: const EdgeInsets.only(top: 40, bottom: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 50, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                const Text(
                  "User Placeholder",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // My Profile
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text("My Profile"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),

          const Divider(height: 1, thickness: 0.3, color: Colors.black54),

          // MENU ITEMS
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Homepage'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MyHomePage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.article_outlined),
            title: const Text('News'),
            onTap: () {
              // TODO
            },
          ),
          ListTile(
            leading: const Icon(Icons.sports_handball),
            title: const Text('List of Athletes'),
            onTap: () {
              // Tutup drawer dulu
              Navigator.pop(context);

              // Baru pindah ke halaman list atlet
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AtletPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.event_outlined),
            title: const Text('Events'),
            onTap: () {
              // TODO
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EventPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
