import 'package:flutter/material.dart';
import '../user_session.dart';
import 'navbar.dart';
import 'package:LILI/models/user.dart';
import 'package:LILI/pages/more_info_page.dart';
import 'package:LILI/pages/edit_profile_page.dart';
import 'package:LILI/pages/wave2.dart'; // <-- Import WaveClipper here
import 'package:LILI/pages/signing_page.dart';
import 'package:LILI/services/user_service.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _currentIndex = 3;
  final UserService _userService = UserService();
  bool _isLoading = true;
  String _error = '';
  
  User user = User(
    name: "Loading...",
    email: "",
    dob: "",
    phone: "",
    allergies: [],
  );

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      // TODO: Replace 1 with actual user ID from your auth system
      final userData = await _userService.getUserProfile(UserSession().getUserId());
      
      // Debug print to see what data we're receiving
      print('Received user data: $userData');
      
      setState(() {
        user = User(
          name: userData['name'] ?? '',
          email: userData['email'] ?? '',
          dob: userData['user_birthday'] ?? '',
          phone: userData['phone'] ?? '',
          allergies: [], // Add allergies if available in your backend
          height: userData['height'] != null ? double.parse(userData['height'].toString()) : null,
          weight: userData['weight'] != null ? double.parse(userData['weight'].toString()) : null,
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
          builder: (context, setState) => Padding(
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
        return AlertDialog(
          title: Text("Confirm Logout"),
          content: Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Logout"),
              onPressed: () {
                Navigator.of(context).pop();
                print("User logged out");
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF213555),
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          GestureDetector(
            onTapDown: (details) {
              showMenu(
                context: context,
                position: RelativeRect.fromLTRB(
                  details.globalPosition.dx,
                  details.globalPosition.dy,
                  0,
                  0,
                ),
                items: [
                  PopupMenuItem(
                    child: ListTile(
                      leading: Icon(
                        Icons.notification_important,
                        color: Color(0xFF3E5879),
                      ),
                      title: Text('Project UI is due today.'),
                    ),
                  ),
                  PopupMenuItem(
                    child: ListTile(
                      leading: Icon(Icons.new_releases, color: Colors.orange),
                      title: Text('New task assigned.'),
                    ),
                  ),
                ],
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Icon(Icons.notifications, color: Colors.white),
            ),
          ),
        ],
      ),
      //backgroundColor: Color(0xFFF5F5F5),
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _error.isNotEmpty
                ? Center(child: Text(_error, style: TextStyle(color: Colors.red)))
                : Column(
          children: [
            Stack(
              children: [
                ClipPath(
                  clipper: WaveClipper(),
                  child: Container(height: 250, color: Color(0xFF213555)),
                ),
                Positioned(
                  top: 100,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Color(0xFF213555), width: 4),
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: user.profilePic != null && user.profilePic!.isNotEmpty
                            ? NetworkImage(user.profilePic!)
                            : AssetImage('assets/images/Hana.jpeg') as ImageProvider,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              width: 291,
              height: 130,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width: 110.86,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Name',
                            style: TextStyle(
                              color: Color(0xFF1D2345),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Inter',
                            ),
                          ),
                          Text(
                            user.name,
                            style: TextStyle(
                              color: Color(0xFF3E5879),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Inter',
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Date of Birth',
                            style: TextStyle(
                              color: Color(0xFF1D2345),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Inter',
                            ),
                          ),
                          Text(
                            user.dob,
                            style: TextStyle(
                              color: Color(0xFF3E5879),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Inter',
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Phone',
                            style: TextStyle(
                              color: Color(0xFF1D2345),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Inter',
                            ),
                          ),
                          Text(
                            user.phone,
                            style: TextStyle(
                              color: Color(0xFF3E5879),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 129.33,
                    top: 0,
                    child: Container(
                      width: 161.67,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Email',
                            style: TextStyle(
                              color: Color(0xFF1D2345),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Inter',
                            ),
                          ),
                          Text(
                            user.email,
                            style: TextStyle(
                              color: Color(0xFF3E5879),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Inter',
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Height',
                            style: TextStyle(
                              color: Color(0xFF1D2345),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Inter',
                            ),
                          ),
                          Text(
                            user.height != null ? '${user.height} cm' : 'Not set',
                            style: TextStyle(
                              color: Color(0xFF3E5879),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Inter',
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Weight',
                            style: TextStyle(
                              color: Color(0xFF1D2345),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Inter',
                            ),
                          ),
                          Text(
                            user.weight != null ? '${user.weight} kg' : 'Not set',
                            style: TextStyle(
                              color: Color(0xFF3E5879),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: _navigateToMoreInfo,
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.transparent),
                child: Column(
                  children: [
                    Text(
                      "More Info",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF213555),
                      ),
                    ),
                    Icon(Icons.arrow_downward, color: Color(0xFF213555)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 5),
            ElevatedButton.icon(
              onPressed: _navigateToEditProfile,
              icon: Icon(Icons.edit),
              label: Text("Edit Profile"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF213555),
                foregroundColor: Colors.white,
                fixedSize: Size(260, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 5),
            ElevatedButton.icon(
              onPressed: () {
                showDetailSheet(
                  context,
                  "House Code",
                  ["Code: HJ223FA56", "Location: Main Home", "Owner: Farah"],
                  showCheckboxes: false,
                );
              },
              icon: Icon(Icons.person_add),
              label: Text("Add User"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF213555),
                foregroundColor: Colors.white,
                fixedSize: Size(260, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 5),
            ElevatedButton.icon(
              onPressed: _navigateTosigning_page,
              icon: Icon(Icons.logout),
              label: Text("Log Out"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFF2F2F2),
                foregroundColor: Colors.red,
                fixedSize: Size(260, 40),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1, color: Colors.red),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// _buildButton(
//   'Add User',
//   onPressed: () {
//     Navigator.pushNamed(context, '/add user');
//   },
// ),
