import 'package:flutter/material.dart';
import 'dart:ui';
import 'add_visa_page.dart';
import 'spent_page.dart';
import 'income_page.dart';

class ExpensesPage extends StatefulWidget {
  @override
  _ExpensesPageState createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  double currentBalance = 2090.20;

  List<Map<String, dynamic>> expenses = [
    {'icon': Icons.store, 'title': 'Grocery', 'time': '10 min ago', 'amount': 35.0},
    {'icon': Icons.shopping_bag_outlined, 'title': 'Shopping', 'time': '14 min ago', 'amount': 12.0},
  ];

  List<Map<String, dynamic>> cards = [
    {
      'color': Color(0xFF1F3354),
      'type': 'VISA',
      'fullNumber': '1234 5678 9012 3456',
    },
    {
      'color': Color(0xFF1F3354),
      'type': 'Master Card',
      'fullNumber': '9876 5432 1098 7654',
    },
  ];

  bool _isBalanceRevealed = false;

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Grocery':
        return Icons.store;
      case 'Shopping':
        return Icons.shopping_bag_outlined;
      case 'Transport':
        return Icons.directions_car;
      case 'Bills':
        return Icons.receipt_long;
      case 'Food':
        return Icons.fastfood;
      default:
        return Icons.category;
    }
  }

  void _addExpense(String category, double amount) {
    setState(() {
      currentBalance -= amount;
      expenses.insert(0, {
        'icon': _getIconForCategory(category),
        'title': category,
        'time': 'Just now',
        'amount': amount
      });
    });
  }

  void _addIncome(double amount) {
    setState(() {
      currentBalance += amount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1F3354),
              const Color(0xFF3E5879),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Expenses Manager',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Current balance',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 5),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isBalanceRevealed = !_isBalanceRevealed;
                    });
                  },
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Text(
                        '\$ ${currentBalance.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (!_isBalanceRevealed)
                        Positioned.fill(
                          child: ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                              child: Container(
                                color: Colors.black.withOpacity(0),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // Income and Spent Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.1),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.white24),
                          ),
                        ),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => IncomePage(income: 0),
                            ),
                          );
                          if (result != null && result is Map<String, dynamic>) {
                            _addIncome(result['amount']);
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_circle_outline, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Income',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.1),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.white24),
                          ),
                        ),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SpentPage(spent: 0),
                            ),
                          );
                          if (result != null && result is Map<String, dynamic>) {
                            _addExpense(result['category'], result['amount']);
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.remove_circle_outline, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Spent',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Your cards',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add, color: Colors.white),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => AddVisaPage()),
                        );
                        if (result != null && result is Map<String, dynamic>) {
                          setState(() {
                            cards.add(result);
                          });
                        }
                      },
                    ),
                  ],
                ),
                SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: cards.map((card) => Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: CardTile(
                        color: card['color'],
                        type: card['type'],
                        fullNumber: card['fullNumber'],
                      ),
                    )).toList(),
                  ),
                ),

                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Expenses',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                Expanded(
                  child: ListView.builder(
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final item = expenses[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        color: Colors.white.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.white24),
                        ),
                        child: ListTile(
                          leading: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              item['icon'],
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            item['title'],
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            item['time'],
                            style: TextStyle(color: Colors.white60),
                          ),
                          trailing: Text(
                            '-\$${item['amount'].toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CardTile extends StatefulWidget {
  final Color color;
  final String type;
  final String fullNumber;

  const CardTile({
    required this.color,
    required this.type,
    required this.fullNumber,
  });

  @override
  _CardTileState createState() => _CardTileState();
}

class _CardTileState extends State<CardTile> {
  bool _isRevealed = false;

  void _toggleReveal() {
    setState(() {
      _isRevealed = !_isRevealed;
    });
  }

  String get _displayNumber {
    if (_isRevealed) {
      return widget.fullNumber;
    } else {
      final parts = widget.fullNumber.split(' ');
      for (int i = 0; i < parts.length - 1; i++) {
        parts[i] = '****';
      }
      return parts.join(' ');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleReveal,
      child: Container(
        width: 300,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.type,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  widget.type == 'VISA' ? Icons.credit_card : Icons.credit_card,
                  color: Colors.white,
                  size: 32,
                ),
              ],
            ),
            SizedBox(height: 30),
            Text(
              _displayNumber,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Tap to reveal/hide',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
