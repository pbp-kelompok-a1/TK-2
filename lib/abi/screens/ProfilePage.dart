import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import '../../ilham/widgets/left_drawer.dart';
import '../../ilham/widgets/navbar.dart';
import '../models/CustomUser.dart';
import '../models/Following.dart';
import '../models/CabangOlahraga.dart';

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
  int? _userId;
  CustomUserElement? _currentUser;
  String _displayName = "";
  String _username = "";
  String? _profilePictureUrl;

  // Stats
  int _followingCount = 0;
  int _commentCount = 0;
  int _eventCount = 0;

  // Following
  List<FollowingElement> _followingList = [];
  List<CabangOlahragaElement> _availableSports = [];

  // Recent activity
  List<Map<String, dynamic>> _recentActivity = [];

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _userId = widget.userId;
    _loadProfileData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);

    final request = context.read<CookieRequest>();

    try {
      // First, get current logged-in user info
      if (_userId == null) {
        final currentUserResponse = await request.get(
            'http://127.0.0.1:8000/following/currentUser/'
        );

        print('DEBUG: Current User Response: $currentUserResponse');

        if (currentUserResponse['user_id'] != null) {
          _userId = currentUserResponse['user_id'];
          _displayName = currentUserResponse['name'] ?? '';
          _username = currentUserResponse['username'] ?? '';
          _profilePictureUrl = currentUserResponse['picture'];
          _nameController.text = _displayName;

          print('DEBUG: Loaded current user - ID: $_userId, Name: $_displayName');
        } else {
          throw Exception('Could not get current user information');
        }
      }

      // Load following data
      final followingResponse = await request.get(
          'http://127.0.0.1:8000/following/showJSONFollowing/'
      );

      print('DEBUG: Following Response: $followingResponse');

      final followingData = Following.fromJson(followingResponse);
      _followingList = followingData.followings
          .where((f) => f.user == _userId)
          .toList();
      _followingCount = _followingList.length;

      print('DEBUG: Following count: $_followingCount');

      // Load available sports for dropdown
      final sportsResponse = await request.get(
          'http://127.0.0.1:8000/following/showJSONCabangOlahraga/'
      );

      final sportsData = CabangOlahraga.fromJson(sportsResponse);
      final followingIds = _followingList.map((f) => f.cabangOlahraga).toSet();
      _availableSports = sportsData.cabangOlahraga
          .where((sport) => !followingIds.contains(sport.id))
          .toList();

      print('DEBUG: Available sports count: ${_availableSports.length}');

      _commentCount = 0;
      _eventCount = 0;
      _recentActivity = [];

      setState(() => _isLoading = false);

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
      final formData = {
        'name': _nameController.text.trim(),
        'update_profile': 'true',
      };

      // If image is selected, convert to base64
      if (_selectedImage != null) {
        final bytes = await _selectedImage!.readAsBytes();
        final base64Image = base64Encode(bytes);
        formData['picture'] = base64Image;
      }

      final response = await request.post(
        'http://127.0.0.1:8000/following/profile/$_userId',
        formData,
      );

      if (response['success'] == true) {
        setState(() {
          _displayName = response['data']['name'];
          if (response['data']['picture'] != null) {
            _profilePictureUrl = response['data']['picture'];
          }
          _isEditMode = false;
          _selectedImage = null;
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
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _followSport(String sportId) async {
    final request = context.read<CookieRequest>();

    try {
      final response = await request.post(
        'http://127.0.0.1:8000/following/profile/$_userId',
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
        'http://127.0.0.1:8000/following/unfollow/$followId/',
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
    return Scaffold(
      drawer: const LeftDrawer(),
      appBar: const MainNavbar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1400),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              // Profile Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
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
              ),
              const SizedBox(height: 20),

              // User Info Sidebar
              _buildUserInfoCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      children: [
        // Profile Picture
        GestureDetector(
          onTap: _isEditMode ? _pickImage : null,
          child: Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: const Color(0xFFE5E0DA),
                backgroundImage: _selectedImage != null
                    ? FileImage(_selectedImage!)
                    : (_profilePictureUrl != null
                    ? NetworkImage(_profilePictureUrl!)
                    : null) as ImageProvider?,
                child: _profilePictureUrl == null && _selectedImage == null
                    ? const Icon(Icons.person, size: 60, color: Colors.grey)
                    : null,
              ),
              if (_isEditMode)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
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
                        _selectedImage = null;
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
        Wrap(
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
    // Find sport name from available sports or following list
    String sportName = follow.cabangOlahraga;

    return Chip(
      backgroundColor: const Color(0xFF38BDF8),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            sportName,
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _unfollowSport(follow.id, sportName),
            child: const Icon(
              Icons.close,
              color: Colors.white,
              size: 18,
            ),
          ),
        ],
      ),
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
            return ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF38BDF8),
                radius: 4,
              ),
              title: Text(activity['description'] ?? ''),
              subtitle: Text(activity['date'] ?? ''),
            );
          }).toList(),
      ],
    );
  }

  Widget _buildUserInfoCard() {
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
            _buildInfoRow(
              'Joined',
              _currentUser?.joinDate != null
                  ? '${_currentUser!.joinDate.day} ${_getMonthName(_currentUser!.joinDate.month)} ${_currentUser!.joinDate.year}'
                  : '-',
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final request = context.read<CookieRequest>();
                  await request.logout('http://127.0.0.1:8000/auth/logout/');

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
          ),
        ),
        Text(
          value,
          style: const TextStyle(color: Colors.black87),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}