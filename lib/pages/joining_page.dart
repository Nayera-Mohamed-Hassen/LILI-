import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../user_session.dart';

class JoiningPage extends StatefulWidget {
  const JoiningPage({super.key});

  @override
  State<JoiningPage> createState() => _JoiningPageState();
}

class _JoiningPageState extends State<JoiningPage> {
  final TextEditingController _codeController = TextEditingController();
  bool _isJoining = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1F3354), Color(0xFF3E5879)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.08),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 16,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Icon(
                        Icons.group_add_rounded,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Join a House',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Enter a join code to join a household',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _codeController,
                            decoration: InputDecoration(
                              labelText: 'Join Code',
                              labelStyle: const TextStyle(color: Colors.white70),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                              filled: true,
                              fillColor: Colors.white12,
                              prefixIcon: const Icon(Icons.key, color: Colors.white70),
                            ),
                            style: const TextStyle(color: Colors.white),
                            textCapitalization: TextCapitalization.characters,
                            maxLength: 6,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildButton(
                      'Join House',
                      onPressed: _isJoining ? null : _handleJoin,
                    ),
                    const SizedBox(height: 48),
                    Text(
                      'Ask a member of the house for the code! 🏡',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white38, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
    String text, {
    required VoidCallback? onPressed,
    Size? size,
  }) {
    final fixedSize = size ?? const Size(double.infinity, 56);

    return SizedBox(
      width: fixedSize.width,
      height: fixedSize.height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white24,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.15),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Future<void> _handleJoin() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty || code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-character code.')),
      );
      return;
    }
    setState(() => _isJoining = true);
    try {
      // 1. Check if household with this code exists
      final url = Uri.parse('http://10.0.2.2:8000/user/household-by-code/$code');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final houseId = data['house_id'];
        // 2. Update user's house_Id
        final userId = UserSession().getUserId();
        final updateUrl = Uri.parse('http://10.0.2.2:8000/user/update-house');
        final updateResponse = await http.post(
          updateUrl,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "user_id": userId,
            "house_id": houseId,
          }),
        );
        if (updateResponse.statusCode == 200) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Successfully joined the household!')),
            );
            Navigator.pushNamedAndRemoveUntil(context, '/homepage', (route) => false);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to join the household.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No household exists with this code.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isJoining = false);
    }
  }
}
