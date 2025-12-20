import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:tk2/ilham/widgets/comment.dart';

class TestCommentPage extends StatelessWidget {
  const TestCommentPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Comment Widget'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mock News Article Header
            Container(
              width: double.infinity,
              height: 200,
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.newspaper, size: 80, color: Colors.grey),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mock Title
                  const Text(
                    'Test News Article for Comment Testing',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Mock Metadata
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'TEST',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'by Test Author',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Text(
                        '21 Dec 2024, 10:00',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),

                  const Divider(height: 32),

                  // Mock Content
                  const Text(
                    'This is a test news article created specifically for testing the comment widget functionality. '
                    'You can test adding, editing, and deleting comments here without affecting real news data. '
                    'The news_id for this test article is 99.',
                    style: TextStyle(fontSize: 16, height: 1.6),
                    textAlign: TextAlign.justify,
                  ),

                  const SizedBox(height: 32),

                  // Info Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, 
                              color: Colors.blue.shade700, 
                              size: 20
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Testing Information',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'News ID: 99\n'
                          'Backend URL: http://localhost:8000\n'
                          'Test all comment features below!',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Separator Line
                  const Divider(
                    thickness: 1,
                    color: Colors.grey,
                  ),

                  const SizedBox(height: 16),

                  // Authentication Status Debug
                  Builder(
                    builder: (context) {
                      final request = Provider.of<CookieRequest>(context);
                      return Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: request.loggedIn 
                                ? Colors.green.shade50 
                                : Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: request.loggedIn 
                                  ? Colors.green.shade200 
                                  : Colors.orange.shade200
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      request.loggedIn ? Icons.check_circle : Icons.warning,
                                      color: request.loggedIn 
                                        ? Colors.green.shade700 
                                        : Colors.orange.shade700,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        request.loggedIn 
                                          ? '✓ Authenticated - Ready to comment'
                                          : '⚠ Not authenticated - Please login first',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: request.loggedIn 
                                            ? Colors.green.shade700 
                                            : Colors.orange.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (request.loggedIn) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Cookies: ${request.cookies}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (!request.loggedIn) ...[
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: () async {
                                // Quick test login
                                final response = await request.login(
                                  'http://localhost:8000/auth/login/',
                                  {
                                    'username': 'test_comment', // Ganti dengan user test kamu
                                    'password': 'testyahooyahoo', // Ganti dengan password test
                                  },
                                );
                                
                                if (context.mounted) {
                                  if (response['status'] == true) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Login successful!')),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Login failed: ${response['message']}')),
                                    );
                                  }
                                }
                              },
                              icon: const Icon(Icons.login),
                              label: const Text('Test Login'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // COMMENT SECTION - INI YANG KITA TEST
                  const CommentWidget(
                    newsId: 99, // News ID khusus untuk testing
                    baseUrl: 'http://localhost:8000',
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