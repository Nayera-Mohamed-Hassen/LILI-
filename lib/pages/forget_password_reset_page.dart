import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config.dart';

class ForgetPasswordResetPage extends StatefulWidget {
  const ForgetPasswordResetPage({super.key});

  @override
  _ForgetPasswordResetPageState createState() => _ForgetPasswordResetPageState();
}

class _ForgetPasswordResetPageState extends State<ForgetPasswordResetPage> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _email;
  String? _code;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
    if (args != null) {
      _email = args['email'];
      _code = args['code'];
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
                    'Reset\nPassword',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Enter your new password',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 48),
                  _buildPasswordField(
                    _newPasswordController,
                    'New Password',
                    'Enter your new password',
                  ),
                  const SizedBox(height: 24),
                  _buildPasswordField(
                    _confirmPasswordController,
                    'Confirm Password',
                    'Re-enter your new password',
                  ),
                  const SizedBox(height: 32),
                  _buildResetButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    TextEditingController controller,
    String label,
    String hint,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: TextField(
        controller: controller,
        obscureText: true,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
          prefixIcon: Container(
            margin: const EdgeInsets.only(left: 12, right: 8),
            child: const Icon(Icons.lock_outline, color: Colors.white70),
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

  Widget _buildResetButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleReset,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white24,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.white24),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Reset Password',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Future<void> _handleReset() async {
    if (_email == null || _code == null) {
      _showError('Invalid reset attempt. Please try again from the beginning.');
      return;
    }

    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      _showError('Please fill in both password fields');
      return;
    }

    if (newPassword != confirmPassword) {
      _showError('Passwords do not match');
      return;
    }

    if (newPassword.length < 6) {
      _showError('Password must be at least 6 characters long');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/user/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _email,
          'code': _code,
          'new_password': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        // Show success dialog and navigate to login
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Success'),
            content: const Text('Your password has been reset successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                },
                child: const Text('Login'),
              ),
            ],
          ),
        );
      } else {
        final error = jsonDecode(response.body)['detail'];
        _showError(error ?? 'Failed to reset password');
      }
    } catch (e) {
      _showError('Failed to reset password. Please try again.');
    } finally {
      setState(() => _isLoading = false);
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
}
