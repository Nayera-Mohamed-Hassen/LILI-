import 'package:flutter/material.dart';

import 'home_page.dart';
import 'main_menu.dart';
import 'emergency.dart';
import 'profile.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CustomBottomNavBar(),
    );
  }
}

class CustomBottomNavBar extends StatefulWidget {
  @override
  _CustomBottomNavBarState createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _controller;
  late Animation<double> _positionAnimation;
  double _notchX = -135.0;

  final List<Widget> _pages = [
    HomePage(),
    MainMenuPage(),
    EmergencyPage(),
    ProfilePage(),
  ];

  final List<double> _circleOffsets = [
    -135.0,
    -45.0,
    45.0,
    135.0,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _positionAnimation = Tween<double>(
      begin: _circleOffsets[0],
      end: _circleOffsets[0],
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _notchX = _circleOffsets[_selectedIndex];
  }

  void _onItemTapped(int index) {
    final newOffset = _circleOffsets[index];
    _positionAnimation = Tween<double>(
      begin: _notchX,
      end: newOffset,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward(from: 0);
    setState(() {
      _selectedIndex = index;
      _notchX = newOffset;
    });
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.home;
      case 1:
        return Icons.menu;
      case 2:
        return Icons.warning_amber_rounded;
      case 3:
        return Icons.settings;
      default:
        return Icons.home;
    }
  }

  @override
  Widget build(BuildContext context) {
    double centerX = MediaQuery.of(context).size.width / 2;
    Color iconColor = Color(0xFFF5EFE7); // Light Beige color for icons

    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE7),
      body: Stack(
        children: [
          _pages[_selectedIndex],
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedBuilder(
              animation: _positionAnimation,
              builder: (context, child) {
                double notchX = centerX + _positionAnimation.value;

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipPath(
                      clipper: MovingCurveClipper(notchX: notchX),
                      child: Container(
                        height: 65,
                        color: const Color(0xFF1F3354),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(4, (index) {
                            bool isSelected = index == _selectedIndex;
                            return Opacity(
                              opacity: isSelected ? 0.0 : 1.0,
                              child: GestureDetector(
                                onTap: () => _onItemTapped(index),
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  margin: const EdgeInsets.only(top: 8),
                                  // No border circle around icons
                                  child: Icon(
                                    _getIconForIndex(index),
                                    color: isSelected ? iconColor : Color(0xFFF5EFE7),
                                    size: 32, // Bigger icon size
                                  ),
                                  alignment: Alignment.center,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: notchX - 28,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Color(0xFFF5EFE7),
                          shape: BoxShape.circle,
                          boxShadow: [

                          ],
                        ),
                        child: Icon(
                          _getIconForIndex(_selectedIndex),
                          color: const Color(0xFF1F3354),
                          size: 36, // Slightly bigger icon for selected
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class MovingCurveClipper extends CustomClipper<Path> {
  final double notchX;
  MovingCurveClipper({required this.notchX});

  @override
  Path getClip(Size size) {
    const double dipRadius = 45;
    const double dipDepth = 120;

    final Path path = Path()
      ..moveTo(0, 0)
      ..lineTo(notchX - dipRadius, 0)
      ..quadraticBezierTo(
        notchX,
        dipDepth,
        notchX + dipRadius,
        0,
      )
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(MovingCurveClipper oldClipper) =>
      oldClipper.notchX != notchX;
}
