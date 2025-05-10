import 'dart:ui';
import 'package:flutter/material.dart';

class BudgetPage extends StatefulWidget {
  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  final GlobalKey _fabKey = GlobalKey();
  bool _showBalance = false; // Default is hidden

  void _showPopupMenu() async {
    final RenderBox renderBox =
    _fabKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy - 130,
        offset.dx + size.width,
        offset.dy,
      ),
      color: Color(0xFFF5EFE7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      items: [
        PopupMenuItem<String>(value: 'Item', child: Text('Add new card')),
        PopupMenuItem<String>(value: 'category', child: Text('Add new expenses')),
      ],
    );

    if (selected == 'Item') {
      Navigator.pushNamed(context, '/new item inventory');
    } else if (selected == 'category') {
      Navigator.pushNamed(context, '/new category inventory');
    }
  }

  final Color blueCard = Color(0xFF213555);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5EFE7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  BackButton(),
                  CircleAvatar(radius: 40),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good Morning!',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF213555),
                        ),
                      ),
                      Text(
                        'Sandra',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF213555),
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  GestureDetector(
                    onTapDown: (details) {
                      showMenu(
                        context: context,
                        position: RelativeRect.fromLTRB(
                          details.globalPosition.dx,
                          details.globalPosition.dy,
                          0,
                          0,
                        ),
                        items: [
                          PopupMenuItem(
                            child: ListTile(
                              leading: Icon(Icons.notification_important, color: Color(0xFF3E5879)),
                              title: Text('You exceeded the card limit.'),
                            ),
                          ),
                          PopupMenuItem(
                            child: ListTile(
                              leading: Icon(Icons.new_releases, color: Colors.orange),
                              title: Text('New task assigned.'),
                            ),
                          ),
                        ],
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF1F3354),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(Icons.notifications, color: Color(0xFFF5EFE7)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),

              // Account Card
              Container(
                decoration: BoxDecoration(
                  color: blueCard,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Total balance", style: TextStyle(fontSize: 16, color: Colors.white)),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ImageFiltered(
                            imageFilter: ImageFilter.blur(
                              sigmaX: _showBalance ? 0 : 6,
                              sigmaY: _showBalance ? 0 : 6,
                            ),
                            child: Text(
                              "\$40,500.80",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _showBalance ? Icons.visibility : Icons.visibility_off,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _showBalance = !_showBalance;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30),
              Text(
                "Transaction",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF213555),
                ),
              ),
              SizedBox(height: 10),
              _transactionItem("Transfer to Firmansyah A.", "-\$20", "04:03 PM"),
              _transactionItem("Receive from Adam S.", "+\$1,300", "02:15 PM"),
              _transactionItem("Transfer to Rina", "-\$20", "01:10 PM"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _transactionItem(String title, String amount, String time) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: TextStyle(fontSize: 16)),
      subtitle: Text(time),
      trailing: Text(
        amount,
        style: TextStyle(
          color: amount.startsWith('+') ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
