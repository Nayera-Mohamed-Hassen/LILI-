import 'package:flutter/material.dart';

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    final double waveHeight = size.height * 0.5; // Controls wave depth

    // Start at bottom-left (mirrored from original)
    path.moveTo(-100, size.height / 2);

    // First downward curve (1/5 width)
    path.quadraticBezierTo(
      size.width * 0.1,
      size.height / 4 + waveHeight,
      // Control point (peak downward)
      size.width * 0.2,
      size.height / 1.8, // End point (back to baseline)
    );

    // Upward curve (3/5 width)
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height / 1.9 - waveHeight,
      // Control point (peak upward)
      size.width * 0.8,
      size.height / 1.9, // End point (back to baseline)
    );

    // Final downward curve (last 1/5 width)
    path.quadraticBezierTo(
      size.width * 0.9,
      size.height / 4 + waveHeight,
      // Control point (peak downward)
      size.width + 80,
      size.height / 1.8, // End at bottom-right
    );

    // Close path (optional, depends on usage)
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class RecipePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Recipe Page')),
      body: Stack(
        children: [
          ClipPath(
            clipper: WaveClipper(),
            child: Container(
              height: 250, // Adjust this height to your needs
              color: Color(0xFF1F3354), // Wave color (dark blue)
            ),
          ),
          Flex(
            direction: Axis.vertical,
            children: [
              SizedBox(height: 90),
              Center(
                child: ClipOval(
                  child: Image.asset(
                    'assets/recipes/Chicken Alfredo.jpg',
                    width: 180, // Must be square (width = height)
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
