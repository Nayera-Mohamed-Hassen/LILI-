import 'package:flutter/material.dart';

class ForgetPasswordResetPage extends StatefulWidget {
  const ForgetPasswordResetPage({super.key});

  @override
  _ForgetPasswordResetPageState createState() =>
      _ForgetPasswordResetPageState();
}

class _ForgetPasswordResetPageState extends State<ForgetPasswordResetPage> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        leading: BackButton(),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 400,
              height: 200,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(color: const Color(0xFFF2F2F2)),
              child: Stack(
                children: [
                  Positioned(
                    top: 100,
                    child: Text(
                      'Reset Password',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF213555),
                        fontSize: 44,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                        height: 1.20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            _buildTextField(_newPasswordController, 'New Password'),
            const SizedBox(height: 20),
            _buildTextField(_confirmPasswordController, 'Confirm Password'),
            const SizedBox(height: 30),
            _buildButton(
              'Save Changes',
              onPressed: () {
                if (_newPasswordController.text.isEmpty ||
                    _confirmPasswordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill in both fields')),
                  );
                } else {
                  showDialog(
                    context: context,
                    builder:
                        (ctx) => AlertDialog(
                          title: Text('Success'),
                          content: Text('Password saved successfully!'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/login');
                              },
                              child: Text('OK'),
                            ),
                          ],
                        ),
                  );
                }
              },
            ),
            const SizedBox(height: 10),
            _buildButton(
              'Discard Changes',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
    String text, {
    required VoidCallback onPressed,
    Size? size,
  }) {
    final fixedSize = size ?? const Size(430, 50);

    return SizedBox(
      width: fixedSize.width,
      height: fixedSize.height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3E5879),
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
