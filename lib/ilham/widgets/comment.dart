import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:tk2/ilham/models/comment_model.dart'; 

// Main Comment Widget
class CommentWidget extends StatefulWidget {
  final int newsId;
  final String baseUrl; 

  const CommentWidget({
    Key? key,
    required this.newsId,
    required this.baseUrl,
  }) : super(key: key);

  @override
  State<CommentWidget> createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  List<CommentModel> comments = [];
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

  // GET request ke Django untuk load comments
  Future<void> loadComments() async {
    setState(() => isLoading = true);

    try {
      final request = context.read<CookieRequest>();
      
      final response = await request.get(
        '${widget.baseUrl}/comment/json/${widget.newsId}/',
      );

      if (response is List) {
        setState(() {
          comments = response.map((json) => CommentModel.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load comments: $e')),
        );
      }
    }
  }

  // POST request untuk add comment
  Future<void> addComment(String content) async {
    if (content.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a comment before submitting!')),
      );
      return;
    }

    try {
      final request = context.read<CookieRequest>();

      final response = await request.post(
        '${widget.baseUrl}/comment/add_flutter/${widget.newsId}/',
        {'content': content},
      );

      if (response['success'] == true) {
        _commentController.clear();
        setState(() => showCommentInput = false);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'Comment added successfully!')),
          );
        }
        
        await loadComments(); // Reload comments
      } else {
        throw Exception(response['error'] ?? 'Failed to add comment');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
    }
  }

  // POST request untuk edit comment
  Future<void> editComment(int commentId, String newContent) async {
    if (newContent.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment cannot be empty!')),
      );
      return;
    }

    try {
      final request = context.read<CookieRequest>();

      final response = await request.post(
        '${widget.baseUrl}/comment/edit_flutter/$commentId/',
        {'content': newContent},
      );

      if (response['success'] == true) {
        setState(() => editingCommentId = null);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'Comment updated successfully!')),
          );
        }
        
        await loadComments();
      } else {
        throw Exception(response['error'] ?? 'Failed to edit comment');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to edit comment: $e')),
        );
      }
    }
  }

  // POST request untuk delete comment
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
      final request = context.read<CookieRequest>();

      final response = await request.post(
        '${widget.baseUrl}/comment/delete_flutter/$commentId/',
        {},
      );

      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'Comment deleted successfully!')),
          );
        }
        
        await loadComments();
      } else {
        throw Exception(response['error'] ?? 'Failed to delete comment');
      }
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
    final request = context.watch<CookieRequest>();
    final isAuthenticated = request.loggedIn;

    return Container(
      constraints: const BoxConstraints(maxWidth: 1152),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add Comment Button / Login Prompt
          if (isAuthenticated)
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
      child: GestureDetector(
        onTap: () {
          // TODO: Navigate to login page
        },
        child: RichText(
          text: const TextSpan(
            style: TextStyle(color: Colors.grey, fontSize: 14),
            children: [
              TextSpan(text: 'Login to add a comment'),
            ],
          ),
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

  Widget _buildCommentItem(CommentModel comment, bool isEditing) {
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
              comment.user,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            Text('•', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
            Text(
              comment.date,
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