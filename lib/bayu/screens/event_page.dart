import 'package:flutter/material.dart';

import '../../ilham/widgets/left_drawer.dart';
import '../../ilham/widgets/navbar.dart';


class EventPage extends StatelessWidget {
  const EventPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const LeftDrawer(),
      appBar: MainNavbar(),
      body: const Center(
        child: Text("Event Page"),
      ),
    );
  }
}