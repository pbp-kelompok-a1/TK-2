// comment_widget.dart
import 'package:flutter/material.dart';

// Model untuk Comment (sesuai dengan Django model)
class Comment {
  final int id;
  final int newsId;  // foreign key ke Berita
  final int userId;  // foreign key ke User
  final String username;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isEdited;
  final bool isOwner;
  final bool canDelete;

  Comment({
    required this.id,
    required this.newsId,
    required this.userId,
    required this.username,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.isEdited,
    required this.isOwner,
    required this.canDelete,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      newsId: json['news'],
      userId: json['user_id'],
      username: json['user'] ?? json['username'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isEdited: json['is_edited'] ?? false,
      isOwner: json['is_owner'] ?? false,
      canDelete: json['can_delete'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'news': newsId,
      'user_id': userId,
      'user': username,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_edited': isEdited,
      'is_owner': isOwner,
      'can_delete': canDelete,
    };
  }

  // Helper untuk format tanggal
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 7) {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}

// Main Comment Widget
class CommentWidget extends StatefulWidget {
  final int newsId;
  final bool isAuthenticated;
  final String currentUsername;

  const CommentWidget({
    Key? key,
    required this.newsId,
    required this.isAuthenticated,
    required this.currentUsername,
  }) : super(key: key);

  @override
  State<CommentWidget> createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  List<Comment> comments = [];
  bool isLoading = true;
  bool showCommentInput = false;
  final TextEditingController _commentController = TextEditingController();
  int? editingCommentId;

  @override
  void initState() {
    super.initState();
    loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // TODO: Implementasi GET request ke Django
  // Expected Django response format:
  // [
  //   {
  //     "id": 1,
  //     "news": 123,
  //     "user_id": 5,
  //     "user": "username",
  //     "content": "Comment text",
  //     "created_at": "2024-01-15T10:30:00Z",
  //     "updated_at": "2024-01-15T10:30:00Z",
  //     "is_edited": false,
  //     "is_owner": true,
  //     "can_delete": true
  //   }
  // ]
  Future<void> loadComments() async {
    setState(() => isLoading = true);

    try {
      // TODO: Import package http: import 'package:http/http.dart' as http;
      // TODO: Import dart:convert untuk json.decode
      
      // final response = await http.get(
      //   Uri.parse('https://your-domain.com/comment/json/${widget.newsId}/'),
      //   headers: {
      //     'Content-Type': 'application/json',
      //     // TODO: Jika pakai authentication, tambahkan header:
      //     // 'Authorization': 'Bearer $token',
      //     // atau
      //     // 'Cookie': 'sessionid=$sessionId',
      //   },
      // );
      // 
      // if (response.statusCode == 200) {
      //   final List<dynamic> data = json.decode(response.body);
      //   setState(() {
      //     comments = data.map((json) => Comment.fromJson(json)).toList();
      //     isLoading = false;
      //   });
      // } else {
      //   throw Exception('Failed to load comments');
      // }

      // Dummy data untuk testing
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        comments = []; // Replace dengan data dari response
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load comments: $e')),
        );
      }
    }
  }

  // TODO: Implementasi POST request untuk add comment
  // Django akan membuat record baru di database dengan:
  // - news: widget.newsId (dari ForeignKey)
  // - user: dari request.user (authenticated user)
  // - content: dari form data
  // - created_at & updated_at: auto-generated
  Future<void> addComment(String content) async {
    if (content.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a comment before submitting!')),
      );
      return;
    }

    try {
      // TODO: Import package http dan dart:convert
      
      // final response = await http.post(
      //   Uri.parse('https://your-domain.com/comment/add/${widget.newsId}/'),
      //   headers: {
      //     'Content-Type': 'application/x-www-form-urlencoded',
      //     // TODO: Tambahkan CSRF token jika diperlukan:
      //     // 'X-CSRFToken': csrfToken,
      //     // TODO: Tambahkan auth header:
      //     // 'Cookie': 'sessionid=$sessionId',
      //   },
      //   body: {'content': content},
      // );
      //
      // if (response.statusCode == 200 || response.statusCode == 201) {
      //   final result = json.decode(response.body);
      //   if (result['success'] == true) {
      //     _commentController.clear();
      //     setState(() => showCommentInput = false);
      //     await loadComments();
      //   } else {
      //     throw Exception(result['message'] ?? 'Failed to add comment');
      //   }
      // } else {
      //   throw Exception('Server error: ${response.statusCode}');
      // }

      // Dummy implementation
      await Future.delayed(const Duration(milliseconds: 500));
      _commentController.clear();
      setState(() => showCommentInput = false);
      await loadComments();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
    }
  }

  // TODO: Implementasi POST request untuk edit comment
  Future<void> editComment(int commentId, String newContent) async {
    if (newContent.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment cannot be empty!')),
      );
      return;
    }

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() => editingCommentId = null);
      await loadComments();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to edit comment: $e')),
        );
      }
    }
  }

  // TODO: Implementasi POST request untuk delete comment
  Future<void> deleteComment(int commentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text('Are you sure you want to delete this comment?'),
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

    if (confirmed != true) return;

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      await loadComments();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete comment: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1152),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add Comment Button / Login Prompt
          if (widget.isAuthenticated)
            _buildAddCommentSection()
          else
            _buildLoginPrompt(),

          const SizedBox(height: 24),

          // Comments Header
          _buildCommentsHeader(),

          const SizedBox(height: 24),

          // Comments List
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            )
          else if (comments.isEmpty)
            _buildEmptyState()
          else
            _buildCommentsList(),
        ],
      ),
    );
  }

  Widget _buildAddCommentSection() {
    return Column(
      children: [
        if (!showCommentInput)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => setState(() => showCommentInput = true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF38BDF8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text('Add Comment', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        if (showCommentInput) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Write your comment here...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 2),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => addComment(_commentController.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF38BDF8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text('Submit Comment', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _commentController.clear();
                    setState(() => showCommentInput = false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.grey[700],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.grey, fontSize: 14),
          children: [
            const TextSpan(text: 'Login to add a comment'),
            // TODO: Implement navigation to login page
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.comment, size: 24),
        const SizedBox(width: 8),
        const Text(
          'Comments',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF38BDF8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${comments.length}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(Icons.comment_outlined, size: 96, color: Colors.grey[400]),
          const SizedBox(height: 12),
          const Text(
            'No comments yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            'Be the first to share your thoughts!',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: comments.length,
      separatorBuilder: (_, __) => const Divider(height: 32),
      itemBuilder: (context, index) {
        final comment = comments[index];
        final isEditing = editingCommentId == comment.id;

        return _buildCommentItem(comment, isEditing);
      },
    );
  }

  Widget _buildCommentItem(Comment comment, bool isEditing) {
    final editController = TextEditingController(text: comment.content);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User info
        Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              comment.username,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            Text('•', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
            Text(
              comment.formattedDate,  // Menggunakan helper dari model
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            if (comment.isEdited)
              Text(
                '(edited)',
                style: TextStyle(color: Colors.grey[400], fontSize: 12, fontStyle: FontStyle.italic),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // Comment content or edit field
        if (isEditing)
          Column(
            children: [
              TextField(
                controller: editController,
                maxLines: 3,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => editComment(comment.id, editController.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF38BDF8),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Text('Save', style: TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => setState(() => editingCommentId = null),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[400],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Text('Cancel', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ],
          )
        else
          Text(
            comment.content,
            style: TextStyle(color: Colors.grey[700], fontSize: 14),
          ),

        // Action buttons
        if (!isEditing && (comment.isOwner || comment.canDelete)) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: [
              if (comment.isOwner)
                TextButton(
                  onPressed: () => setState(() => editingCommentId = comment.id),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF38BDF8),
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Edit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                ),
              if (comment.canDelete)
                TextButton(
                  onPressed: () => deleteComment(comment.id),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Delete', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                ),
            ],
          ),
        ],
      ],
    );
  }
}