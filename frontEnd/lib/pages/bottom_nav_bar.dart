// lib/pages/bottom_nav_bar.dart

import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTabTapped;

  const BottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTabTapped,
  }) : super(key: key);

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // Custom Bottom Navigation Bar with only icons
        Container(
          height: 56, // Standard bottom nav height
          decoration: BoxDecoration(
            color: Color(0xFF213555), // Navy blue
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              4, // Number of tabs
                  (index) {
                return IconButton(
                  icon: Icon(
                    _getIcon(index),
                    color: widget.currentIndex == index
                        ? Color(0xFFF5EFE7) // Beige for selected icon
                        : Color(0xFF213555), // Navy blue for unselected icons
                    size: 24, // Adjust icon size as needed
                  ),
                  onPressed: () {
                    widget.onTabTapped(index);
                  },
                );
              },
            ),
          ),
        ),

        // Beige circle extending into the app's background
        Positioned(
          top: -24, // Slightly higher than the navy circle
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              4, // Number of tabs
                  (index) {
                return AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  width: widget.currentIndex == index ? 64 : 0,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFF5EFE7), // Beige
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 16),
                );
              },
            ),
          ),
        ),

        // Navy circle extending into the app's background
        Positioned(
          top: -16, // Slightly lower than the beige circle
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              4, // Number of tabs
                  (index) {
                return AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  width: widget.currentIndex == index ? 48 : 0,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF213555), // Navy blue
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 16),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  IconData _getIcon(int index) {
    switch (index) {
      case 0:
        return Icons.home;
      case 1:
        return Icons.menu;
      case 2:
        return Icons.warning;
      case 3:
        return Icons.settings;
      default:
        return Icons.home;
    }
  }
}