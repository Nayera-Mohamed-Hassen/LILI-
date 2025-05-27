import 'package:flutter/material.dart';
import 'spent_page.dart';
import 'income_page.dart';
import 'dart:ui';
import 'add_visa_page.dart';

class ExpensesPage extends StatefulWidget {
  @override
  _ExpensesPageState createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  double currentBalance = 2090.20;
  double income = 2090.20;
  double spent = 1290.00;

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

  void _addSpentExpense(String category, double amount) {
    setState(() {
      spent += amount;
      currentBalance -= amount;
      expenses.insert(0, {
        'icon': _getIconForCategory(category),
        'title': category,
        'time': 'Just now',
        'amount': amount
      });
    });
  }

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

  @override
  Widget build(BuildContext context) {
    final Color blue = Color(0xFF0B50FF);

    return Scaffold(

      appBar: AppBar(
        title: Text('Expenses Manager', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF1F3354),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Current balance', style: TextStyle(fontWeight: FontWeight.bold)),
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
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
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

              // Income vs Spent
              Container(
                decoration: BoxDecoration(
                  color:  Color(0xFF1F3354),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => IncomePage(income: income),

                          ),
                        );
                        if (result != null && result is Map<String, dynamic>) {
                          setState(() {
                            income += result['amount'];
                            currentBalance += result['amount'];
                          });
                        }
                      },
                      child: Column(
                        children: [
                          Text('Income ', style: TextStyle(color: Colors.white70,fontSize: 18,fontWeight: FontWeight.bold),),
                          SizedBox(height: 8),

                        ],
                      ),
                    ),

                    Container(width: 1, height: 40, color: Colors.white24),
                    GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SpentPage(spent: spent),

                          ),
                        );
                        if (result != null && result is Map<String, dynamic>) {
                          _addSpentExpense(result['category'], result['amount']);
                        }
                      },
                      child: Column(
                        children: [
                          Text('Spent', style: TextStyle(color: Colors.white70,fontSize: 18,fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),

                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Your cards', style: TextStyle(fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: Icon(Icons.add, color: Color(0xFF1F3354)),
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
                  children: cards
                      .map((card) => Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: CardTile(
                      color: card['color'],
                      type: card['type'],
                      fullNumber: card['fullNumber'],
                    ),
                  ))
                      .toList(),
                ),
              ),

              SizedBox(height: 30),
              // Expenses title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Expenses', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),

              // Expense list
              Expanded(
                child: ListView.builder(
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final item = expenses[index];
                    return ExpenseTile(
                      icon: item['icon'],
                      title: item['title'],
                      time: item['time'],
                      amount: item['amount'],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CardTile extends StatefulWidget {
  final Color color;
  final String type;
  final String fullNumber; // full card number

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
      // Mask all but last 4 digits, preserve spaces
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
        height: 180,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card type
            Text(
              widget.type,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            Spacer(),
            Center(
              child: Text(
                _displayNumber,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  letterSpacing: 4,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Courier',
                ),
              ),
            ),
            Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: Icon(
                _isRevealed ? Icons.visibility : Icons.visibility_off,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExpenseTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String time;
  final double amount;

  const ExpenseTile({required this.icon, required this.title, required this.time, required this.amount});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: Colors.black87),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(time),
      trailing: Text('\$${amount.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
