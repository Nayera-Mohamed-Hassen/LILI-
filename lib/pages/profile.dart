import 'package:LILI/pages/login_page.dart';
import 'package:flutter/material.dart';
import '../user_session.dart';
import 'navbar.dart';
import 'package:LILI/models/user.dart';
import 'package:LILI/pages/more_info_page.dart';
import 'package:LILI/pages/edit_profile_page.dart';
import 'package:LILI/pages/wave2.dart'; // <-- Import WaveClipper here
import 'package:LILI/pages/signing_page.dart';
import 'package:LILI/services/user_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:LILI/pages/notifications_page.dart';
import '../services/notification_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/notification.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _currentIndex = 3;
  final UserService _userService = UserService();
  bool _isLoading = true;
  String _error = '';
  final TextEditingController _feedbackController = TextEditingController();
  bool _isSavingFeedback = false;
  String _feedbackStatus = '';
  int _feedbackRating = 0;
  String? _joinCode;
  List<Map<String, dynamic>> _householdUsers = [];
  List<NotificationModel> _latestNotifications = [];
  bool _dropdownOpen = false;
  bool _loadingNotifications = false;

  User user = User(
    name: "Loading...",
    email: "",
    dob: "",
    phone: "",
    allergies: [],
  );

  bool _showProfileToOthers = true;
  bool _enableActivityStatus = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadFeedback();
    _loadJoinCode();
    _loadHouseholdUsers();
    _fetchNotifications();
  }

  Future<void> _loadUserProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      // TODO: Replace 1 with actual user ID from your auth system
      final userData = await _userService.getUserProfile(
        UserSession().getUserId(),
      );

      // Debug print to see what data we're receiving
      print('Received user data: $userData');

      setState(() {
        user = User(
          name: userData['name'] ?? '',
          email: userData['email'] ?? '',
          dob: userData['user_birthday'] ?? '',
          phone: userData['phone'] ?? '',
          allergies: [],
          // Add allergies if available in your backend
          height:
              userData['height'] != null
                  ? double.parse(userData['height'].toString())
                  : null,
          weight:
              userData['weight'] != null
                  ? double.parse(userData['weight'].toString())
                  : null,
        );
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading profile: $e'); // Debug print for errors
      setState(() {
        _error = 'Failed to load profile: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadFeedback() async {
    final userId = UserSession().getUserId();
    if (userId == null || userId.isEmpty) return;
    try {
      final url = Uri.parse('http://10.0.2.2:8000/user/feedback/$userId');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _feedbackController.text = data['feedback'] ?? '';
        _feedbackRating = data['rating'] ?? 0;
      }
    } catch (e) {
      // Optionally handle error
    }
  }

  Future<void> _saveFeedback() async {
    setState(() {
      _isSavingFeedback = true;
      _feedbackStatus = '';
    });
    final userId = UserSession().getUserId();
    if (userId == null || userId.isEmpty) return;
    try {
      final url = Uri.parse('http://10.0.2.2:8000/user/feedback');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "feedback": _feedbackController.text.trim(),
          "rating": _feedbackRating,
        }),
      );
      if (response.statusCode == 200) {
        setState(() {
          _feedbackStatus = 'Feedback saved!';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thank you for your feedback!')),
        );
      } else {
        setState(() {
          _feedbackStatus = 'Failed to save feedback.';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save feedback.')),
        );
      }
    } catch (e) {
      setState(() {
        _feedbackStatus = 'Error saving feedback.';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _isSavingFeedback = false;
      });
    }
  }

  Future<void> _loadJoinCode() async {
    final userId = UserSession().getUserId();
    if (userId == null || userId.isEmpty) return;
    try {
      // Get user's house_Id
      final urlProfile = Uri.parse('http://10.0.2.2:8000/user/profile/$userId');
      final responseProfile = await http.get(urlProfile);
      if (responseProfile.statusCode == 200) {
        final data = jsonDecode(responseProfile.body);
        final houseId = data['house_Id'];
        if (houseId != null && houseId != "") {
          // Fetch household by houseId to get join_code
          final urlHouse = Uri.parse(
            'http://10.0.2.2:8000/user/household/$houseId',
          );
          final responseHouse = await http.get(urlHouse);
          if (responseHouse.statusCode == 200) {
            final houseData = jsonDecode(responseHouse.body);
            setState(() {
              _joinCode = houseData['join_code'] ?? null;
            });
          }
        }
      }
    } catch (e) {
      // Optionally handle error
    }
  }

  Future<void> _loadHouseholdUsers() async {
    final userId = UserSession().getUserId();
    if (userId == null || userId.isEmpty) return;
    try {
      final url = Uri.parse(
        'http://10.0.2.2:8000/user/household-users/$userId',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _householdUsers = List<Map<String, dynamic>>.from(data);
        });
      }
    } catch (e) {
      // Optionally handle error
    }
  }

  void updateUser(User updatedUser) {
    setState(() {
      user = updatedUser;
    });
  }

  void _navigateTosigning_page() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SigningPage()),
    );
  }

  void _navigateToMoreInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MoreInfoPage(user: user)),
    );
  }

  void _navigateToEditProfile() async {
    final updatedUser = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfilePage(user: user)),
    );

    if (updatedUser != null) {
      updateUser(updatedUser);
    }
  }

  void showDetailSheet(
    BuildContext context,
    String title,
    List<String> details, {
    bool showCheckboxes = false,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        List<bool> checked = List.generate(details.length, (index) => false);

        return StatefulBuilder(
          builder:
              (context, setState) => Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...List.generate(details.length, (index) {
                      return showCheckboxes
                          ? CheckboxListTile(
                            value: checked[index],
                            title: Text(details[index]),
                            controlAffinity: ListTileControlAffinity.leading,
                            onChanged: (val) {
                              setState(() {
                                checked[index] = val!;
                              });
                            },
                          )
                          : ListTile(
                            leading: const Icon(Icons.arrow_right),
                            title: Text(details[index]),
                          );
                    }),
                  ],
                ),
              ),
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF1F3354),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 24,
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.logout, color: Colors.white, size: 28),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Confirm Logout',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Are you sure you want to log out?',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF1F3354),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1F3354),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 24,
                          ),
                        ),
                        child: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () async {
                          // Set isLoggedIn to false in the database
                          final userId = UserSession().getUserId();
                          if (userId != null && userId.isNotEmpty) {
                            try {
                              await logoutUser(userId);
                            } catch (e) {
                              // Optionally handle error
                            }
                          }
                          // Clear the user session
                          UserSession().setUserId('');
                          UserSession().setRecipeCount(1);

                          // Clear persistent login
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.remove('user_id');
                          await prefs.remove('house_id');
                          await prefs.remove('username');
                          await prefs.remove('name');

                          // Close the dialog
                          Navigator.of(context).pop();

                          // Navigate to the signing page and remove all previous routes
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => LoginPage(),
                            ),
                            (Route<dynamic> route) => false,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> logoutUser(String userId) async {
    final url = Uri.parse('http://10.0.2.2:8000/user/logout');
    await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"user_id": userId}),
    );
  }

  void _showResetPasswordDialog() {
    final _newPasswordController = TextEditingController();
    final _confirmPasswordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF1F3354),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 24,
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.lock_reset, color: Colors.white, size: 28),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Reset Password',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      TextField(
                        controller: _newPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'New Password',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Confirm Password',
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1F3354),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 24,
                          ),
                        ),
                        onPressed: () async {
                          final newPassword =
                              _newPasswordController.text.trim();
                          final confirmPassword =
                              _confirmPasswordController.text.trim();
                          if (newPassword.isEmpty || confirmPassword.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please fill in both fields'),
                              ),
                            );
                            return;
                          }
                          if (newPassword != confirmPassword) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Passwords do not match'),
                              ),
                            );
                            return;
                          }
                          // Call backend to update password
                          try {
                            final userId = UserSession().getUserId();
                            final response = await resetPassword(
                              userId,
                              newPassword,
                            );
                            if (response) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Password updated successfully',
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to update password'),
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        },
                        child: const Text(
                          'Update',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool> resetPassword(String? userId, String newPassword) async {
    if (userId == null || userId.isEmpty) return false;
    final url = Uri.parse('http://10.0.2.2:8000/user/reset-password');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"user_id": userId, "new_password": newPassword}),
    );
    return response.statusCode == 200;
  }

  void _showPrivacySheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        bool showProfile = _showProfileToOthers;
        bool activityStatus = _enableActivityStatus;
        return StatefulBuilder(
          builder:
              (context, setState) => Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Privacy Settings',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SwitchListTile(
                      value: showProfile,
                      onChanged: (val) => setState(() => showProfile = val),
                      title: const Text('Show my profile to others'),
                      subtitle: const Text(
                        'Allow your profile to be visible to other users.',
                      ),
                    ),
                    SwitchListTile(
                      value: activityStatus,
                      onChanged: (val) => setState(() => activityStatus = val),
                      title: const Text('Enable activity status'),
                      subtitle: const Text(
                        'Let others see when you are active.',
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _showProfileToOthers = showProfile;
                              _enableActivityStatus = activityStatus;
                            });
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Privacy settings updated'),
                              ),
                            );
                          },
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
        );
      },
    );
  }

  void _fetchNotifications() async {
    setState(() => _loadingNotifications = true);
    try {
      final notifs = await NotificationService().fetchNotifications(
        UserSession().getUserId().toString(),
      );
      setState(() {
        _latestNotifications = notifs.take(5).toList();
        _loadingNotifications = false;
      });
    } catch (e) {
      setState(() => _loadingNotifications = false);
    }
  }

  Widget _buildNotificationDropdown() {
    return Positioned(
      right: 10,
      top: 60,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 320,
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_loadingNotifications)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                )
              else if (_latestNotifications.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('No notifications'),
                )
              else
                ..._latestNotifications.map(
                  (notif) => ListTile(
                    leading: Icon(
                      _iconForType(notif.type),
                      color: notif.isRead ? Colors.grey : Colors.blue,
                    ),
                    title: Text(
                      notif.title,
                      style: TextStyle(
                        fontWeight:
                            notif.isRead ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    onTap: () async {
                      await NotificationService().markAsRead(notif.id);
                      _fetchNotifications();
                      setState(() => _dropdownOpen = false);
                      _handleNotificationTap(notif);
                    },
                  ),
                ),
              Divider(),
              if (_latestNotifications.any((n) => !n.isRead))
                TextButton.icon(
                  icon: Icon(Icons.mark_email_read),
                  label: Text('Mark All as Read'),
                  onPressed: () async {
                    final userId = UserSession().getUserId().toString();
                    final success = await NotificationService().markAllAsRead(
                      userId,
                    );
                    if (success) {
                      _fetchNotifications();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('All notifications marked as read!'),
                        ),
                      );
                    }
                  },
                ),
              TextButton.icon(
                icon: Icon(Icons.arrow_forward),
                label: Text('See all notifications'),
                onPressed: () {
                  setState(() => _dropdownOpen = false);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => NotificationsPage(
                            userId: UserSession().getUserId().toString(),
                          ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleNotificationTap(NotificationModel notif) {
    if (notif.type == 'task' && notif.data['task_id'] != null) {
      Navigator.pushNamed(
        context,
        '/task home',
        arguments: notif.data['task_id'],
      );
    } else if (notif.type == 'recipe' && notif.data['recipe_id'] != null) {
      Navigator.pushNamed(
        context,
        '/Recipe',
        arguments: notif.data['recipe_id'],
      );
    } else if (notif.type == 'inventory' && notif.data['item_name'] != null) {
      Navigator.pushNamed(
        context,
        '/inventory',
        arguments: notif.data['item_name'],
      );
    } else if (notif.type == 'spending' && notif.data['category'] != null) {
      Navigator.pushNamed(
        context,
        '/Expenses ',
        arguments: notif.data['category'],
      );
    }
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'task':
        return FontAwesomeIcons.clipboardCheck;
      case 'recipe':
        return FontAwesomeIcons.utensils;
      case 'inventory':
        return FontAwesomeIcons.boxOpen;
      case 'spending':
        return FontAwesomeIcons.wallet;
      case 'system':
        return FontAwesomeIcons.userEdit;
      default:
        return FontAwesomeIcons.bell;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [const Color(0xFF1F3354), const Color(0xFF3E5879)],
              ),
            ),
            child: SafeArea(
              child:
                  _isLoading
                      ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                      : _error.isNotEmpty
                      ? Center(
                        child: Text(
                          _error,
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                      : CustomScrollView(
                        slivers: [
                          SliverAppBar(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            pinned: true,
                            expandedHeight: 200,
                            automaticallyImplyLeading: false,
                            flexibleSpace: FlexibleSpaceBar(
                              background: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 4,
                                        ),
                                      ),
                                      child: CircleAvatar(
                                        radius: 50,
                                        backgroundColor: Colors.white24,
                                        child: Text(
                                          user.name.isNotEmpty
                                              ? user.name[0].toUpperCase()
                                              : '?',
                                          style: const TextStyle(
                                            fontSize: 40,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      user.name,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  _buildHouseholdUsersCard(),
                                  const SizedBox(height: 24),
                                  _buildInfoCard(),
                                  const SizedBox(height: 24),
                                  _buildActionButtons(),
                                  const SizedBox(height: 24),
                                  _buildSettingsSection(),
                                  const SizedBox(height: 24),
                                  _buildFeedbackCard(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
            ),
          ),
          // Notification bell and dropdown overlay
          Positioned(
            top: 30,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() => _dropdownOpen = !_dropdownOpen);
                    if (!_dropdownOpen) _fetchNotifications();
                  },
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 2,
                          ),
                        ),
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          FontAwesomeIcons.bell,
                          size: 28,
                          color: Colors.white,
                        ),
                      ),
                      if (_latestNotifications.any((n) => !n.isRead))
                        Positioned(
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            constraints: BoxConstraints(
                              minWidth: 12,
                              minHeight: 12,
                            ),
                            child: Text(
                              '!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (_dropdownOpen) _buildNotificationDropdown(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow(Icons.email, 'Email', user.email),
            const Divider(height: 24),
            _buildInfoRow(Icons.phone, 'Phone', user.phone),
            const Divider(height: 24),
            _buildInfoRow(Icons.cake, 'Birthday', user.dob),
            if (user.height != null) ...[
              const Divider(height: 24),
              _buildInfoRow(Icons.height, 'Height', '${user.height} cm'),
            ],
            if (user.weight != null) ...[
              const Divider(height: 24),
              _buildInfoRow(
                Icons.monitor_weight,
                'Weight',
                '${user.weight} kg',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1F3354).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF1F3354)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              Text(
                value.isNotEmpty ? value : 'Not set',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            'Edit Profile',
            Icons.edit,
            _navigateToEditProfile,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionButton(
            'More Info',
            Icons.info_outline,
            _navigateToMoreInfo,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F3354),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Icon(icon), const SizedBox(width: 8), Text(label)],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _buildSettingsTile(
            'Add User',
            Icons.person_add,
            onTap: () {
              showDetailSheet(context, "Household Join Code", [
                _joinCode != null ? "Code: $_joinCode" : "No code available",
              ], showCheckboxes: false);
            },
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            'Reset Password',
            Icons.lock_reset,
            onTap: _showResetPasswordDialog,
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            'Help & Support',
            Icons.help_outline,
            onTap: _showHelpSupportDialog,
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            'Logout',
            Icons.logout,
            isDestructive: true,
            onTap: _showLogoutDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    String title,
    IconData icon, {
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    final color = isDestructive ? Colors.red : const Color(0xFF1F3354);

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showHelpSupportDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF1F3354),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 24,
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.help_outline, color: Colors.white, size: 28),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Help & Support',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Need help or have questions?'),
                        SizedBox(height: 12),
                        Text(
                          '• For technical support, app issues, or feedback, please contact us:',
                        ),
                        SizedBox(height: 8),
                        SelectableText(
                          'Email: support@liliapp.com',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '• You can also reach us through the in-app feedback section below.',
                        ),
                        SizedBox(height: 12),
                        Text('• For urgent issues, call us at:'),
                        SelectableText(
                          '+1-800-555-LILI',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16),
                        Text('Thank you for using LILI!'),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1F3354),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Close',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeedbackCard() {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.feedback, color: Color(0xFF1F3354)),
                SizedBox(width: 8),
                Text(
                  'Your Feedback',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F3354),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ...List.generate(
                  5,
                  (index) => IconButton(
                    icon: Icon(
                      _feedbackRating > index ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: () {
                      setState(() {
                        _feedbackRating = index + 1;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Text(_feedbackRating > 0 ? '$_feedbackRating/5' : 'Rate us'),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _feedbackController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Let us know your thoughts or suggestions...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFF1F3354)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFF1F3354)),
                ),
                fillColor: Colors.white,
                filled: true,
              ),
              style: const TextStyle(color: Color(0xFF1F3354)),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: _isSavingFeedback ? null : _saveFeedback,
                  icon:
                      _isSavingFeedback
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Icon(Icons.save),
                  label: const Text('Save'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F3354),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            if (_feedbackStatus.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _feedbackStatus,
                  style: TextStyle(
                    color:
                        _feedbackStatus.contains('saved')
                            ? Colors.green
                            : Colors.red,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHouseholdUsersCard() {
    final myUserId = UserSession().getUserId();
    if (_householdUsers.isEmpty) {
      return Card(
        elevation: 4,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: const [
              Icon(Icons.group, color: Color(0xFF1F3354)),
              SizedBox(width: 12),
              Text(
                'No other members in your household.',
                style: TextStyle(fontSize: 16, color: Color(0xFF1F3354)),
              ),
            ],
          ),
        ),
      );
    }
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.group, color: Color(0xFF1F3354)),
                SizedBox(width: 8),
                Text(
                  'Household Members',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F3354),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._householdUsers.asMap().entries.map((entry) {
              final i = entry.key;
              final member = entry.value;
              final isMe = member['user_id'] == myUserId;
              return Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 0,
                    ),
                    leading:
                        member['profile_pic'] != null &&
                                member['profile_pic'].toString().isNotEmpty
                            ? CircleAvatar(
                              backgroundImage: NetworkImage(
                                member['profile_pic'],
                              ),
                              radius: 26,
                            )
                            : const CircleAvatar(
                              backgroundColor: Color(0xFF3E5879),
                              radius: 26,
                              child: Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                    title: Row(
                      children: [
                        Text(
                          member['name'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (isMe)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3E5879),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'You',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '@${member['username'] ?? ''}',
                          style: const TextStyle(fontSize: 13),
                        ),
                        Text(
                          member['email'] ?? '',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.info_outline,
                            color: Color(0xFF1F3354),
                          ),
                          tooltip: 'View Profile',
                          onPressed: () => _showMemberProfileDialog(member),
                        ),
                        if (!isMe)
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: Colors.red,
                            ),
                            tooltip: 'Remove from household',
                            onPressed: () => _confirmRemoveMember(member),
                          ),
                      ],
                    ),
                  ),
                  if (i < _householdUsers.length - 1)
                    const Divider(
                      height: 16,
                      thickness: 1,
                      indent: 8,
                      endIndent: 8,
                    ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showMemberProfileDialog(Map<String, dynamic> member) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return FutureBuilder<http.Response>(
          future: http.get(
            Uri.parse('http://10.0.2.2:8000/user/profile/${member['user_id']}'),
          ),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const AlertDialog(
                content: SizedBox(
                  height: 80,
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }
            if (snapshot.data!.statusCode != 200) {
              return AlertDialog(
                title: const Text('Error'),
                content: const Text('Failed to load user info.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              );
            }
            final data = jsonDecode(snapshot.data!.body);
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  data['profile_pic'] != null &&
                          data['profile_pic'].toString().isNotEmpty
                      ? CircleAvatar(
                        backgroundImage: NetworkImage(data['profile_pic']),
                        radius: 24,
                      )
                      : const CircleAvatar(
                        backgroundColor: Color(0xFF3E5879),
                        radius: 24,
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      data['name'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Username: @${data['username'] ?? ''}'),
                    Text('Email: ${data['email'] ?? ''}'),
                    Text('Phone: ${data['phone'] ?? ''}'),
                    Text('Birthday: ${data['user_birthday'] ?? ''}'),
                    Text(
                      'Height: ${data['height'] != null ? data['height'].toString() : ''}',
                    ),
                    Text(
                      'Weight: ${data['weight'] != null ? data['weight'].toString() : ''}',
                    ),
                    Text('Diet: ${data['diet'] ?? ''}'),
                    Text('Gender: ${data['gender'] ?? ''}'),
                    // Add more fields if needed
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmRemoveMember(Map<String, dynamic> member) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Remove Member'),
          content: Text(
            'Are you sure you want to remove ${member['name']} from the household?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                Navigator.of(context).pop();
                await _removeMember(member['user_id']);
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _removeMember(String userId) async {
    try {
      final url = Uri.parse('http://10.0.2.2:8000/user/remove-from-household');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_id": userId}),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Member removed from household.')),
        );
        _loadHouseholdUsers();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to remove member.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}

// _buildButton(
//   'Add User',
//   onPressed: () {
//     Navigator.pushNamed(context, '/add user');
//   },
// ),
