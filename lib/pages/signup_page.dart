import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'init_setup_page.dart';
import '../config.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phoneNumber = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _username = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

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
                  // IconButton(
                  //   icon: const Icon(Icons.arrow_back, color: Colors.white),
                  //   onPressed: () => Navigator.pop(context),
                  // ),
                  const SizedBox(height: 32),
                  const Text(
                    'Create\nAccount',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Sign up to get started',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 48),
                  _buildTextField(
                    controller: _name,
                    label: 'Full Name',
                    icon: Icons.person_outline,
                    key: const Key('Full Name'),
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(
                    controller: _username,
                    label: 'Username',
                    icon: Icons.account_circle_outlined,
                    key: const Key('Username'),
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(
                    controller: _email,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    key: const Key('Email'),
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(
                    controller: _phoneNumber,
                    label: 'Phone Number',
                    icon: Icons.phone_outlined,
                    key: const Key('Phone Number'),
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(
                    controller: _passwordController,
                    label: 'Password',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    isPasswordVisible: _isPasswordVisible,
                    onTogglePassword: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                    key: const Key('Password'),
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    isPasswordVisible: _isConfirmPasswordVisible,
                    onTogglePassword: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                    key: const Key('Confirm Password'),
                  ),
                  const SizedBox(height: 32),
                  Semantics(
                    label: 'register_button',
                    child: _buildNextButton(key: const Key('register_button')),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account? ",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Login here',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 38),
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
    bool isPassword = false,
    bool? isPasswordVisible,
    VoidCallback? onTogglePassword,
    Key? key,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: TextField(
        key: key,
        controller: controller,
        style: const TextStyle(color: Colors.white),
        obscureText: isPassword && !(isPasswordVisible ?? false),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIcon: Container(
            margin: const EdgeInsets.only(left: 12, right: 8),
            child: Icon(icon, color: Colors.white70),
          ),
          suffixIcon:
              isPassword
                  ? IconButton(
                    icon: Icon(
                      (isPasswordVisible ?? false)
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.white70,
                    ),
                    onPressed: onTogglePassword,
                  )
                  : null,
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

  Widget _buildNextButton({Key? key}) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        key: key,
        onPressed: _handleNext,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1F3354),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Next',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _handleNext() async {
    if (_name.text.isEmpty ||
        _username.text.isEmpty ||
        _email.text.isEmpty ||
        _phoneNumber.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }
    // Email validation
    final emailRegex = RegExp(r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!emailRegex.hasMatch(_email.text)) {
      _showError('Please enter a valid email address');
      return;
    }
    // Phone validation (simple, 10-15 digits)
    final phoneRegex = RegExp(r'^\+?\d{10,15}$');
    if (!phoneRegex.hasMatch(_phoneNumber.text)) {
      _showError('Please enter a valid phone number');
      return;
    }
    // Password validation (min 8 chars, at least one letter and one number)
    final password = _passwordController.text;
    if (password.length < 8 ||
        !RegExp(r'[A-Za-z]').hasMatch(password) ||
        !RegExp(r'\d').hasMatch(password)) {
      _showError(
        'Password must be at least 8 characters and include a letter and a number',
      );
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Passwords do not match');
      return;
    }
    // Uniqueness check before proceeding
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/user/check-uniqueness'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": _username.text,
        "email": _email.text,
        "phone": _phoneNumber.text,
      }),
    );
    final result = jsonDecode(response.body)["result"];
    if (result == "username") {
      _showError('Username already exists. Please choose another.');
      return;
    } else if (result == "email") {
      _showError('Email already exists. Please use another.');
      return;
    } else if (result == "phone") {
      _showError('Phone number already exists. Please use another.');
      return;
    } else if (result != "ok") {
      _showError('Error checking uniqueness. Please try again.');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => InitSetupPage(
              name: _name.text,
              username: _username.text,
              email: _email.text,
              password: _passwordController.text,
              phone: _phoneNumber.text,
            ),
      ),
    );
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
}
