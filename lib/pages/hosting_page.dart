import 'package:flutter/material.dart';

class HostingPage extends StatelessWidget {
  const HostingPage({super.key});

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
          child: Stack(
            children: [
              // Back Button
              Positioned(
                top: 16,
                left: 16,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFFF2F2F2)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),

              // Main Content
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // LILI Logo/Icon
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.08),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(24),
                        child: const Icon(
                          Icons.home_rounded,
                          size: 64,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Welcome to LILI',
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
                        'Host or join a house to get started',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 18),
                      ),
                      const SizedBox(height: 64),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/host house');
                        },
                        icon: const Icon(Icons.add_home, color: Colors.white),
                        label: const Text(
                          'Host House',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white24,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          shadowColor: Colors.black.withOpacity(0.15),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/joining');
                        },
                        icon: const Icon(Icons.group_add, color: Colors.white),
                        label: const Text(
                          'Join House',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white24,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          shadowColor: Colors.black.withOpacity(0.15),
                        ),
                      ),
                      const SizedBox(height: 48),
                      const Text(
                        'LILI helps you manage your home, tasks, and more! 🏡',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white38, fontSize: 16),
                      ),
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
}
