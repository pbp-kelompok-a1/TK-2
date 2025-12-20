import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../../ilham/widgets/left_drawer.dart';
import '../../ilham/widgets/navbar.dart';
import '../models/CabangOlahraga.dart';
import '../models/Following.dart';

class ProfilePage extends StatefulWidget {
  final int? userId;

  const ProfilePage({super.key, this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = true;
  bool _isEditMode = false;

  // User data
  String _displayName = "";
  String _username = "";
  String? _profilePictureUrl;
  DateTime? _joinDate;

  // Stats
  int _followingCount = 0;
  int _commentCount = 0;
  int _eventCount = 0;

  // Following sports
  List<FollowingElement> _followingList = [];
  List<CabangOlahragaElement> _availableSports = [];

  // Recent activity
  List<RecentActivity> _recentActivity = [];

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  Uint8List? _selectedImageBytes;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String? _getValidImageUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) return path;

    const String baseUrl = 'http://localhost:8000';
    if (path.startsWith('/')) {
      return '$baseUrl$path';
    }
    return '$baseUrl/$path';
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);

    final request = context.read<CookieRequest>();

    try {
      final response = await request.get(
        'http://localhost:8000/following/profile2/',
      );

      print('DEBUG: Profile Response: $response');

      if (response != null && response['success'] == true) {
        setState(() {
          _displayName = response['name'] ?? '';
          _username = response['username'] ?? '';
          _profilePictureUrl = response['profilePicture'];
          _followingCount = response['followingCount'] ?? 0;
          _commentCount = response['commentCount'] ?? 0;
          _eventCount = response['eventCount'] ?? 0;

          if (response['join_date'] != null) {
            _joinDate = DateTime.parse(response['join_date']);
          }

          if (response['following'] != null) {
            _followingList = (response['following'] as List)
                .map((f) => FollowingElement.fromJson(f))
                .toList();
          }

          if (response['available_sports'] != null) {
            _availableSports = (response['available_sports'] as List)
                .map((s) => CabangOlahragaElement.fromJson(s))
                .toList();
          }

          if (response['recentActivity'] != null) {
            _recentActivity = (response['recentActivity'] as List)
                .map((a) => RecentActivity.fromJson(a))
                .toList();
          }

          _nameController.text = _displayName;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load profile data');
      }
    } catch (e, stackTrace) {
      print('DEBUG: Error loading profile: $e');
      print('DEBUG: Stack trace: $stackTrace');

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load profile: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _updateProfile() async {
    final request = context.read<CookieRequest>();

    try {
      final formData = <String, dynamic>{
        'name': _nameController.text.trim(),
        'update_profile': 'true',
      };

      if (_selectedImageBytes != null) {
        final base64Image = base64Encode(_selectedImageBytes!);
        formData['picture'] = 'data:image/jpeg;base64,$base64Image';
      }

      final response = await request.post(
        'http://localhost:8000/following/profile2/',
        formData,
      );

      print('DEBUG: Update response: $response');

      if (!mounted) return;

      if (response['success'] == true) {
        setState(() {
          _displayName = response['data']['name'];
          if (response['data']['picture'] != null) {
            _profilePictureUrl = response['data']['picture'];
            _selectedImageBytes = null;
          }
          _isEditMode = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception(response['error'] ?? 'Failed to update profile');
      }
    } catch (e) {
      print('DEBUG: Update error: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 500,
      maxHeight: 500,
      imageQuality: 80,
    );

    if (image != null) {
      final Uint8List bytes = await image.readAsBytes();

      setState(() {
        _selectedImageBytes = bytes;
      });

      await _updateProfile();
    }
  }

  Future<void> _followSport(String sportId) async {
    final request = context.read<CookieRequest>();

    try {
      final response = await request.post(
        'http://localhost:8000/following/profile2/',
        {'cabangOlahraga': sportId},
      );

      if (response['success'] == true) {
        await _loadProfileData();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sport added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add sport: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _unfollowSport(String followId, String sportName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unfollow Sport'),
        content: Text('Are you sure you want to unfollow $sportName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Unfollow', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final request = context.read<CookieRequest>();

    try {
      final response = await request.post(
        'http://localhost:8000/following/unfollow2/$followId/',
        {},
      );

      if (response['success'] == true) {
        await _loadProfileData();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sport unfollowed successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to unfollow sport: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      drawer: const LeftDrawer(),
      appBar: const MainNavbar(),
      backgroundColor: Colors.grey[50],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadProfileData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1400),
              margin: const EdgeInsets.all(20),
              child: isMobile
                  ? Column(
                children: [
                  _buildProfileCard(),
                  const SizedBox(height: 20),
                  _buildSidebarCard(),
                ],
              )
                  : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildProfileCard(),
                  ),
                  const SizedBox(width: 20),
                  // Sidebar
                  Expanded(
                    flex: 1,
                    child: _buildSidebarCard(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 30),
            _buildStats(),
            const SizedBox(height: 40),
            _buildFollowingSports(),
            const SizedBox(height: 20),
            _buildAddSportForm(),
            const SizedBox(height: 40),
            _buildRecentActivity(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      children: [
        // Profile Picture
        GestureDetector(
          onTap: _pickImage,
          child: Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: const Color(0xFFE5E0DA),
                backgroundImage: _selectedImageBytes != null
                    ? MemoryImage(_selectedImageBytes!)
                    : (_getValidImageUrl(_profilePictureUrl) != null
                    ? NetworkImage(_getValidImageUrl(_profilePictureUrl)!)
                    : null) as ImageProvider?,
                child: _profilePictureUrl == null && _selectedImageBytes == null
                    ? const Icon(Icons.person, size: 60, color: Colors.grey)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF38BDF8),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 30),

        // Profile Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!_isEditMode) ...[
                Text(
                  _displayName,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => setState(() {
                    _isEditMode = true;
                    _nameController.text = _displayName;
                  }),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF38BDF8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Edit Profile'),
                ),
              ] else ...[
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFF38BDF8),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Save'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => setState(() {
                        _isEditMode = false;
                        _selectedImageBytes = null;
                        _nameController.text = _displayName;
                      }),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Text(
                '@$_username',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Sports Followed', _followingCount),
          _buildStatItem('Comments Made', _commentCount),
          _buildStatItem('Events Created', _eventCount),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildFollowingSports() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Following Sports',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        _followingList.isEmpty
            ? const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'No sports followed yet',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        )
            : Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _followingList.map((follow) {
            return _buildSportChip(follow);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSportChip(FollowingElement follow) {
    final sport = _availableSports.firstWhere(
          (s) => s.id == follow.cabangOlahraga,
      orElse: () => CabangOlahragaElement(id: '', name: 'Unknown Sport'),
    );

    return Chip(
      backgroundColor: const Color(0xFF38BDF8),
      deleteIconColor: Colors.white,
      label: Text(
        sport.name,
        style: const TextStyle(color: Colors.white),
      ),
      onDeleted: () => _unfollowSport(follow.id, sport.name),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _buildAddSportForm() {
    if (_availableSports.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add New Sport',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Select a sport to follow',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              items: _availableSports.map((sport) {
                return DropdownMenuItem(
                  value: sport.id,
                  child: Text(sport.name),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  _followSport(value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        if (_recentActivity.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'No recent activity',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ..._recentActivity.map((activity) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF38BDF8),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: '@$_username ',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          TextSpan(text: activity.description),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
      ],
    );
  }

  Widget _buildSidebarCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Info',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildInfoRow('Joined', _formatJoinDate()),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final request = context.read<CookieRequest>();
                  await request.logout('http://localhost:8000/auth/logout/');

                  if (mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/login',
                          (route) => false,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF38BDF8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  String _formatJoinDate() {
    if (_joinDate == null) return '-';

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    return '${_joinDate!.day} ${months[_joinDate!.month - 1]} ${_joinDate!.year}';
  }
}

class RecentActivity {
  final String type;
  final String description;
  final String date;

  RecentActivity({
    required this.type,
    required this.description,
    required this.date,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    String desc = '';
    if (json['type'] == 'Event') {
      desc = 'posted an event: ${json['description']}';
    } else if (json['type'] == 'Comment') {
      desc = 'made a comment';
    }

    return RecentActivity(
      type: json['type'].toString(),
      description: desc,
      date: json['date'].toString(),
    );
  }
}