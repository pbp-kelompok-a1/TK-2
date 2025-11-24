import 'package:flutter/material.dart';
import 'package:tk2/ilham/widgets/navbar.dart';
import 'package:tk2/ilham/widgets/left_drawer.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const LeftDrawer(),
      appBar: MainNavbar(),
      body: const Center(
        child: Text("Main Page Content"),
      ),
    );
  }
}