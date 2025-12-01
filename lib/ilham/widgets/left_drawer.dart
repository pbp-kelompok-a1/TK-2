import 'package:flutter/material.dart';
import 'package:tk2/abi/screens/ProfilePage.dart';
import 'package:tk2/ilham/screens/menu.dart';
import 'package:tk2/ilham/screens/login.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

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
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.grey,
                  ),
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

          if (!Provider.of<CookieRequest>(context, listen: false).loggedIn) ...[
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Login'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPageParaWorld()),
                );
              },
            ),
          ] else ...[
          // My Profile 
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text("My Profile"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfilePage(),
                ));
            },
          ),
          ],

          const Divider(
            height: 1,
            thickness: 0.3,
            color: Colors.black54,
          ),

          // MENU ITEMS
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Homepage'),
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyHomePage(),
                  ));
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
            leading: const Icon(Icons.group_outlined),
            title: const Text('Athletes'),
            onTap: () {
              // TODO
            },
          ),
          ListTile(
            leading: const Icon(Icons.event_outlined),
            title: const Text('Events'),
            onTap: () {
              // TODO
            },
          ),

          if (Provider.of<CookieRequest>(context, listen: false).loggedIn) ...[
            const Divider(
              height: 1,
              thickness: 0.3,
              color: Colors.black54,
            ),
            
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                await Provider.of<CookieRequest>(context, listen: false).logout(
                  "http://localhost:8000/auth/logout/",
                );

                if (!context.mounted) return;

                // Refresh halaman lebih dulu agar Drawer rebuild (logout → login)
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPageParaWorld()),
                );

                // Setelah rebuild selesai baru tampilkan snackbar
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Logout berhasil!"),
                    ),
                  );
                });
              },
            ),
          ],
        ],
      ),
    );
  }
}
