import 'package:flutter/material.dart';

class MainNavbar extends StatelessWidget implements PreferredSizeWidget {
  const MainNavbar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: const Color(0xFF3BC3FD),
      elevation: 4,
      titleSpacing: 0,
      title: Row(
        children: [
          // HAMBURG
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white, size: 30),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),

          const SizedBox(width: 8),

          // header
          Row(
            children: [
              Image.asset(
                "assets/images/logo2.png",
                height: 45,
              ),
              const SizedBox(width: 8),
              const Text(
                "PARAWORLD",
                style: TextStyle(
                  color: Color(0xFFF5F1CE),
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
