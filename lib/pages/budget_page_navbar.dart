import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:LILI/pages/my_card_page.dart';
import 'package:LILI/pages/budget_home_page.dart';
import 'budgetAnalysis.dart';

class BudgetPageNavbar extends StatefulWidget {
  @override
  State<BudgetPageNavbar> createState() => _BudgetPageNavbarState();
}

class _BudgetPageNavbarState extends State<BudgetPageNavbar> {
  final GlobalKey _fabKey = GlobalKey();

  void _showPopupMenu() async {
    final RenderBox renderBox =
        _fabKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy - 130, // Show above FAB
        offset.dx + size.width,
        offset.dy,
      ),
      color: Color(0xFFF5EFE7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      items: [
        PopupMenuItem<String>(
          value: 'category',
          child: Text('Add new category'),
        ),
        PopupMenuItem<String>(
          value: 'expenses',
          child: Text('Add new expenses'),
        ),
      ],
    );

    if (selected == 'category') {
      Navigator.pushNamed(context, '/create new category budget');
    } else if (selected == 'expenses') {
      Navigator.pushNamed(context, '/add new expenses');
    }
  }

  final Color blueCard = Color(0xFF213555);
  final Color greenCard = Color(0xFFB2EBF2);
  final Color blackCard = Color(0xFF2A3F47);

  bool _showBalance = true;
  int _selectedIndex = 0;
  final items = [
    Icon(Icons.money_rounded, size: 30, color: Color(0xFFF5EFE7)),
    Icon(Icons.credit_card, size: 30, color: Color(0xFFF5EFE7)),
    Icon(Icons.analytics_outlined, size: 30, color: Color(0xFFF5EFE7)),
  ];

  // List of pages
  final List<Widget> _pages = [
    // Container(color: Colors.blue), // BudgetPage (Replace with actual page)
    BudgetPage(),
    MyCardPage(),
    AnalysisPage(),
    // MyCardPage (Replace with actual page)
    // AnalyticsPage(),           // AnalyticsPage (Replace with actual page)
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex =
          index; // Update the selected index when navigation item is tapped
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5EFE7),
      body: SafeArea(
        child:
            _pages[_selectedIndex], // Display the page based on the selected index
      ),
      floatingActionButton: FloatingActionButton(
        key: _fabKey,
        backgroundColor: Color(0xFF1F3354),
        child: Icon(Icons.add, size: 30, color: Color(0xFFF5EFE7)),
        onPressed: _showPopupMenu,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        // Current selected index
        height: 60,
        backgroundColor: Colors.transparent,
        color: Color(0xFF1F3354),
        buttonBackgroundColor: Color(0xFF1F3354),
        items: items,
        onTap: _onItemTapped, // Handle item taps to switch pages
      ),
    );
  }
}
