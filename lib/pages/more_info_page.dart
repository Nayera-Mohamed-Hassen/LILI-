import 'package:flutter/material.dart';
import '../../../../models/user.dart';
import 'package:LILI/pages/profile.dart';
import 'package:LILI/services/user_service.dart';

class MoreInfoPage extends StatefulWidget {
  final User user;

  MoreInfoPage({required this.user});

  @override
  _MoreInfoPageState createState() => _MoreInfoPageState();
}

class _MoreInfoPageState extends State<MoreInfoPage> {
  List<String> _allergies = [];
  bool _isLoadingAllergies = true;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _fetchAllergies();
  }

  Future<void> _fetchAllergies() async {
    setState(() {
      _isLoadingAllergies = true;
    });
    try {
      final userId = widget.user.email.isNotEmpty ? widget.user.email : null;
      // Try to get userId from profile if available
      // If you have userId in User, use that instead
      final id = userId ?? '';
      if (id.isNotEmpty) {
        _allergies = await _userService.getUserAllergies(id);
      }
    } catch (e) {
      _allergies = [];
    } finally {
      setState(() {
        _isLoadingAllergies = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1F3354),
              const Color(0xFF3E5879),
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                expandedHeight: 200,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 4),
                              ),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.white24,
                                child: Text(
                                  widget.user.name.isNotEmpty ? widget.user.name[0].toUpperCase() : '?',
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
                              widget.user.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildInfoCard(),
                      const SizedBox(height: 24),
                      _buildHealthCard(),
                      const SizedBox(height: 24),
                      _buildPreferencesCard(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F3354),
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.email, 'Email', widget.user.email),
            const Divider(height: 24),
            _buildInfoRow(Icons.phone, 'Phone', widget.user.phone),
            const Divider(height: 24),
            _buildInfoRow(Icons.cake, 'Birthday', widget.user.dob),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthCard() {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Health Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F3354),
              ),
            ),
            const SizedBox(height: 16),
            if (widget.user.height != null)
              _buildInfoRow(Icons.height, 'Height', '${widget.user.height} cm'),
            if (widget.user.height != null) const Divider(height: 24),
            if (widget.user.weight != null)
              _buildInfoRow(Icons.monitor_weight, 'Weight', '${widget.user.weight} kg'),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesCard() {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Preferences & Restrictions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F3354),
              ),
            ),
            const SizedBox(height: 16),
            _isLoadingAllergies
                ? const Center(child: CircularProgressIndicator())
                : _buildInfoRow(
                    Icons.no_food,
                    'Allergies',
                    _allergies.isEmpty ? 'None' : _allergies.join(", "),
                  ),
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
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
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
}
