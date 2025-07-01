import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../user_session.dart';

class EditProfilePage extends StatefulWidget {
  final User user;

  EditProfilePage({required this.user});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController heightController;
  late TextEditingController weightController;
  late TextEditingController allergyController;
  late ImagePicker _picker;
  XFile? _image;
  String? selectedGender;
  String? selectedDiet;
  List<String> allergies = [];
  bool _isLoading = false;
  final UserService _userService = UserService();

  final List<String> dietOptions = [
    'vegan',
    'vegetarian',
    'pescatarian',
    'omnivore',
    'other',
  ];

  final List<String> genderOptions = ['male', 'female', 'other'];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user.name);
    emailController = TextEditingController(text: widget.user.email);
    phoneController = TextEditingController(text: widget.user.phone);
    heightController = TextEditingController(
      text: widget.user.height?.toString() ?? '',
    );
    weightController = TextEditingController(
      text: widget.user.weight?.toString() ?? '',
    );
    allergyController = TextEditingController();
    selectedGender = widget.user.gender;
    selectedDiet = widget.user.diet;
    allergies = List.from(widget.user.allergies);
    _picker = ImagePicker();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    heightController.dispose();
    weightController.dispose();
    allergyController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedImage = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    setState(() {
      _image = pickedImage;
    });
  }

  void _addAllergy() {
    final allergy = allergyController.text.trim();
    if (allergy.isNotEmpty && !allergies.contains(allergy)) {
      setState(() {
        allergies.add(allergy);
        allergyController.clear();
      });
    }
  }

  void _removeAllergy(String allergy) {
    setState(() {
      allergies.remove(allergy);
    });
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);

    try {
      String? userId = UserSession().getUserId();
      if (userId == null || userId.isEmpty) {
        throw Exception('Invalid user ID');
      }

      // If a new image is picked, upload it as base64
      if (_image != null) {
        final bytes = await File(_image!.path).readAsBytes();
        final base64Image = base64Encode(bytes);
        await _userService.updateProfilePicture(userId: userId, base64Image: base64Image);
      }

      await _userService.updateProfile(
        userId: userId,
        name: nameController.text,
        email: emailController.text,
        phone: phoneController.text,
        height:
            heightController.text.isNotEmpty
                ? double.parse(heightController.text)
                : null,
        weight:
            weightController.text.isNotEmpty
                ? double.parse(weightController.text)
                : null,
        diet: selectedDiet,
        gender: selectedGender,
        birthday: widget.user.dob,
        allergies: allergies,
      );

      final updatedUser = User(
        name: nameController.text,
        email: emailController.text,
        phone: phoneController.text,
        dob: widget.user.dob,
        height:
            heightController.text.isNotEmpty
                ? double.parse(heightController.text)
                : null,
        weight:
            weightController.text.isNotEmpty
                ? double.parse(weightController.text)
                : null,
        diet: selectedDiet,
        gender: selectedGender,
        allergies: allergies,
        profilePic: _image != null ? base64Encode(await File(_image!.path).readAsBytes()) : widget.user.profilePic,
      );

      Navigator.pop(context, updatedUser);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
    } finally {
      setState(() => _isLoading = false);
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
            colors: [const Color(0xFF1F3354), const Color(0xFF3E5879)],
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
                            GestureDetector(
                              onTap: _pickImage,
                              child: Container(
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
                                  backgroundImage:
                                      _image != null
                                          ? FileImage(File(_image!.path))
                                          : (widget.user.profilePic != null && widget.user.profilePic!.isNotEmpty
                                              ? MemoryImage(base64Decode(widget.user.profilePic!))
                                              : null),
                                  child:
                                      _image == null
                                          ? Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.camera_alt,
                                                size: 32,
                                                color: Colors.white,
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                'Change',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          )
                                          : null,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Edit Profile',
                              style: TextStyle(
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
                      _buildPersonalInfoCard(),
                      const SizedBox(height: 16),
                      _buildHealthInfoCard(),
                      const SizedBox(height: 16),
                      _buildAllergiesCard(),
                      const SizedBox(height: 24),
                      _buildSaveButton(),
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

  Widget _buildPersonalInfoCard() {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F3354),
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: nameController,
              label: 'Name',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: emailController,
              label: 'Email',
              icon: Icons.email_outlined,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: phoneController,
              label: 'Phone',
              icon: Icons.phone_outlined,
            ),
            const SizedBox(height: 16),
            _buildDropdownField(
              label: 'Gender',
              value: selectedGender,
              items: genderOptions,
              onChanged: (value) => setState(() => selectedGender = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthInfoCard() {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Health Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F3354),
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: heightController,
              label: 'Height (cm)',
              icon: Icons.height,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: weightController,
              label: 'Weight (kg)',
              icon: Icons.monitor_weight_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildDropdownField(
              label: 'Diet',
              value: selectedDiet,
              items: dietOptions,
              onChanged: (value) => setState(() => selectedDiet = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllergiesCard() {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Allergies',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F3354),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: allergyController,
                    label: 'Add Allergy',
                    icon: Icons.warning_amber_outlined,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add_circle_outline),
                  onPressed: _addAllergy,
                  color: Color(0xFF1F3354),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  allergies.map((allergy) {
                    return Chip(
                      label: Text(allergy),
                      onDeleted: () => _removeAllergy(allergy),
                      backgroundColor: Colors.white70,
                      deleteIconColor: Color(0xFF1F3354),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: 16, color: Color(0xFF1F3354)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Color(0xFF1F3354).withOpacity(0.7)),
        prefixIcon: Icon(icon, color: Color(0xFF1F3354)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF1F3354).withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF1F3354).withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF1F3354)),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items:
          items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Color(0xFF1F3354).withOpacity(0.7)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF1F3354).withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF1F3354).withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF1F3354)),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white24,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white24),
          ),
          elevation: 0,
        ),
        child:
            _isLoading
                ? SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                : Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
      ),
    );
  }
}
