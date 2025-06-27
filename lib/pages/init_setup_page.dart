import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../user_session.dart';
import '../config.dart';

class InitSetupPage extends StatefulWidget {
  final String name;
  final String username;
  final String email;
  final String password;
  final String phone;

  const InitSetupPage({
    super.key,
    required this.name,
    required this.username,
    required this.email,
    required this.password,
    required this.phone,
  });

  @override
  _InitSetupPageState createState() => _InitSetupPageState();
}

class _InitSetupPageState extends State<InitSetupPage> {
  final _weight = TextEditingController();
  final _height = TextEditingController();
  final _alergiesController = TextEditingController();
  late ImagePicker _picker;
  XFile? _image;
  DateTime? _selectedDate;
  String? _selectedGender;
  String? _selectedDiet;
  late TextEditingController _dateController;

  final List<String> diets = [
    'Vegan',
    'Vegetarian',
    'Keto',
    'Gluten-Free',
    'Paleo',
    'Low-Carb',
    'Dairy-Free',
    'Low-Fat',
    'Whole30',
    'Halal',
  ];
  final List<String> genderOptions = ['Male', 'Female'];

  @override
  void initState() {
    super.initState();
    _picker = ImagePicker();
    _dateController = TextEditingController();
  }

  Future<void> _pickImage() async {
    final XFile? pickedImage = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    setState(() {
      _image = pickedImage;
    });
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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Complete\nYour Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Add your details to personalize your experience',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white24,
                          backgroundImage:
                              _image != null
                                  ? FileImage(File(_image!.path))
                                  : null,
                          child:
                              _image == null
                                  ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(
                                        Icons.camera_alt,
                                        size: 32,
                                        color: Colors.white,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Add Photo',
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
                  ),
                  const SizedBox(height: 32),
                  _buildDateField(
                    context,
                    label: 'Birthdate',
                    hint: 'Date of Birth',
                  ),
                  const SizedBox(height: 24),
                  _buildDropdownField(
                    '',
                    genderOptions,
                    _selectedGender,
                    Icons.person_outline,
                    (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                    hint: 'Gender',
                  ),
                  const SizedBox(height: 24),
                  _buildDropdownField(
                    '',
                    diets,
                    _selectedDiet,
                    Icons.restaurant_menu,
                    (value) {
                      setState(() {
                        _selectedDiet = value;
                      });
                    },
                    hint: 'Diet Preference',
                  ),
                  const SizedBox(height: 24),
                  Semantics(
                    label: 'initsetup_height',
                    textField: true,
                    child: _buildTextField(
                      controller: _height,
                      label: 'Height (cm)',
                      icon: Icons.height,
                      keyboardType: TextInputType.number,
                      hint: 'Height (cm)',
                    ),
                  ),
                  const SizedBox(height: 24),
                  Semantics(
                    label: 'initsetup_weight',
                    textField: true,
                    child: _buildTextField(
                      controller: _weight,
                      label: 'Weight (kg)',
                      icon: Icons.monitor_weight,
                      keyboardType: TextInputType.number,
                      hint: 'Weight (kg)',
                    ),
                  ),
                  const SizedBox(height: 24),
                  Semantics(
                    textField: true,
                    child: _buildTextField(
                      controller: _alergiesController,
                      label: 'Allergies',
                      icon: Icons.warning_amber_rounded,
                      maxLines: 3,
                      hint: 'Allergies (comma separated)',
                    ),
                  ),
                  const SizedBox(height: 32),
                  Semantics(
                    label: 'initsetup_finish',
                    child: _buildFinishButton(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(color: Colors.white70),
          hintStyle: const TextStyle(color: Colors.white70),
          prefixIcon: Container(
            margin: const EdgeInsets.only(left: 12, right: 8),
            child: Icon(icon, color: Colors.white70),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildDateField(
    BuildContext context, {
    required String label,
    String? hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: GestureDetector(
        onTap: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: _selectedDate ?? DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: Colors.white,
                    onPrimary: Color(0xFF1F3354),
                    surface: Color(0xFF1F3354),
                    onSurface: Colors.white,
                  ),
                ),
                child: child!,
              );
            },
          );
          if (picked != null) {
            setState(() {
              _selectedDate = picked;
              _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
            });
          }
        },
        child: AbsorbPointer(
          child: TextField(
            controller: _dateController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: label,
              hintText: hint ?? 'Date of Birth',
              labelStyle: const TextStyle(color: Colors.white70),
              hintStyle: const TextStyle(color: Colors.white70),
              prefixIcon: Container(
                margin: const EdgeInsets.only(left: 12, right: 8),
                child: const Icon(Icons.calendar_today, color: Colors.white70),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    List<String> items,
    String? selectedValue,
    IconData icon,
    void Function(String?) onChanged, {
    String? hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        dropdownColor: const Color(0xFF1F3354),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIcon: Container(
            margin: const EdgeInsets.only(left: 12, right: 8),
            child: Icon(icon, color: Colors.white70),
          ),
          hintStyle: const TextStyle(color: Colors.white70),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
        hint: Text(hint!, style: const TextStyle(color: Colors.white70)),
        items:
            items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item, style: const TextStyle(color: Colors.white)),
              );
            }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildFinishButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _handleFinish,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1F3354),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Finish Setup',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Future<void> _handleFinish() async {
    // Validate weight and height
    final height = double.tryParse(_height.text);
    final weight = double.tryParse(_weight.text);
    if (height == null || height <= 0) {
      _showError('Please enter a valid height (positive number)');
      return;
    }
    if (weight == null || weight <= 0) {
      _showError('Please enter a valid weight (positive number)');
      return;
    }
    // Validate birthdate (at least 10 years old)
    if (_selectedDate == null) {
      _showError('Please select your date of birth');
      return;
    }
    final now = DateTime.now();
    final age =
        now.year -
        _selectedDate!.year -
        ((now.month < _selectedDate!.month ||
                (now.month == _selectedDate!.month &&
                    now.day < _selectedDate!.day))
            ? 1
            : 0);
    if (age < 10) {
      _showError('You must be at least 10 years old to sign up');
      return;
    }
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/user/signup'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": widget.name,
          "username": widget.username,
          "email": widget.email,
          "password": widget.password,
          "phone": widget.phone,
          "birthday": _dateController.text,
          "profile_pic": "",
          "height": height,
          "weight": weight,
          "diet": _selectedDiet,
          "gender": _selectedGender,
          "house_id": "",
          "allergy": _alergiesController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userId = data['user_id'];
        if (userId != null && userId is String) {
          UserSession().setUserId(userId);
          UserSession().setUsername(widget.username);
          UserSession().setName(widget.name);
        }
        Navigator.pushNamed(context, '/hosting');
      } else {
        _showError('Signup failed. Please try again.');
      }
    } catch (e) {
      _showError('Connection error. Please check your internet connection.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }
}
