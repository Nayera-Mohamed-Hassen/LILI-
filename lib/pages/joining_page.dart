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
      appBar: AppBar(
        leading: BackButton(),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF2F2F2),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 350,
                height: 200,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(color: const Color(0xFFF2F2F2)),
                child: Stack(
                  children: [
                    Positioned(
                      // left: 10,
                      top: 100,
                      child: Text(
                        'Scan the QR code',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF213555),
                          fontSize: 40,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          height: 1.20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Align(
                alignment: Alignment.center,
                child: IconButton(
                  icon: Icon(
                    Icons.camera_alt,
                    size: 30,
                    color: Color(0xFF1D2345),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (ctx) => AlertDialog(
                            title: Text('Scanning'),
                            content: Text('Scanning the QR code...'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: Text('OK'),
                              ),
                            ],
                          ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _codeController,
                decoration: InputDecoration(
                  labelText: 'Enter Join Code',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.key),
                ),
                textCapitalization: TextCapitalization.characters,
                maxLength: 6,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isJoining ? null : _handleJoin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF3E5879),

                  // const Color(0xFF3E5879)
                  minimumSize: Size(315, 55),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Text(
                  'Join House',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ],
          ),
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
