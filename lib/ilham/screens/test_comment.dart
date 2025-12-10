import 'package:flutter/material.dart';
import 'package:tk2/ilham/widgets/comment.dart';

class CommentTestScreen extends StatelessWidget {
  const CommentTestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comment Test'),
        backgroundColor: Color(0xFF38BDF8),
        foregroundColor: Colors.white,
      ),
      body: CommentWidget(
        newsId: 1,              // kasih angka static aja cukup
        isAuthenticated: true,  // biar bisa langsung test comment
        currentUsername: "tester",
      ),
    );
  }
}

class CommentTestRoute {
  static Route<void> route() {
    return MaterialPageRoute(
      builder: (_) => const CommentTestScreen(),
    );
  }
}
