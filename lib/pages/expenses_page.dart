import 'package:flutter/material.dart';
import 'dart:ui';
import 'add_visa_page.dart';
import 'spent_page.dart';
import 'income_page.dart';
import '../services/transaction_service.dart';

class ExpensesPage extends StatefulWidget {
  final String userId;

  const ExpensesPage({Key? key, required this.userId}) : super(key: key);

  @override
  _ExpensesPageState createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  double currentBalance = 0.0;
  List<Map<String, dynamic>> expenses = [];
  List<Map<String, dynamic>> cards = [];
  bool _isBalanceRevealed = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Load transactions
      final transactions = await TransactionService.getTransactions(
        widget.userId,
      );

      // Calculate current balance
      double totalIncome = 0.0;
      double totalExpenses = 0.0;
      List<Map<String, dynamic>> recentExpenses = [];

      for (var transaction in transactions) {
        if (transaction['transaction_type'] == 'income') {
          totalIncome += transaction['amount'];
        } else {
          totalExpenses += transaction['amount'];
          recentExpenses.add({
            'icon': _getIconForCategory(transaction['category']),
            'title': transaction['category'],
            'time': _formatDate(transaction['date']),
            'amount': transaction['amount'],
          });
        }
      }

      // Load cards
      final userCards = await TransactionService.getCards(widget.userId);
      final formattedCards =
          userCards
              .map(
                (card) => {
                  'color': Color(0xFF1F3354),
                  'type': card['card_type'],
                  'fullNumber': card['card_number'],
                  'expiryDate': card['expiry_date'],
                  'cvv': card['cvv'] ?? '***',
                  // Provide default if CVV is excluded from backend
                  'cardholderName': card['cardholder_name'],
                },
              )
              .toList();

      setState(() {
        currentBalance = totalIncome - totalExpenses;
        expenses = recentExpenses;
        cards = formattedCards;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Just now';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes} min ago';
      } else if (difference.inDays < 1) {
        return '${difference.inHours} hours ago';
      } else if (difference.inDays < 30) {
        return '${difference.inDays} days ago';
      } else {
        return '${date.year}-${date.month}-${date.day}';
      }
    } catch (e) {
      return 'Just now';
    }
  }

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

  Future<void> _addExpense(String category, double amount) async {
    try {
      await TransactionService.addTransaction(
        userId: widget.userId,
        amount: amount,
        category: category,
        transactionType: 'expense',
      );
      await _loadData(); // Reload data after adding expense
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error adding expense: $e')));
    }
  }

  Future<void> _addIncome(double amount, String source) async {
    try {
      await TransactionService.addTransaction(
        userId: widget.userId,
        amount: amount,
        category: source,
        transactionType: 'income',
        source: source,
      );
      await _loadData(); // Reload data after adding income
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error adding income: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [const Color(0xFF1F3354), const Color(0xFF3E5879)],
            ),
          ),
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: const Color(0xFF1F3354),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Expenses Manager',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFF1F3354), const Color(0xFF3E5879)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text(
                //   'Expenses Manager',
                //   style: TextStyle(
                //     color: Colors.white,
                //     fontSize: 32,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
                //SizedBox(height: 20),
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
                              filter: ImageFilter.blur(
                                sigmaX: 10.0,
                                sigmaY: 10.0,
                              ),
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
                          if (result != null &&
                              result is Map<String, dynamic>) {
                            await _addIncome(
                              result['amount'],
                              result['source'],
                            );
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
                          if (result != null &&
                              result is Map<String, dynamic>) {
                            await _addExpense(
                              result['category'],
                              result['amount'],
                            );
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.remove_circle_outline,
                              color: Colors.white,
                            ),
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
                          try {
                            await TransactionService.addCard(
                              userId: widget.userId,
                              cardType: result['type'],
                              cardNumber: result['fullNumber'],
                              expiryDate: result['expiryDate'],
                              cvv: result['cvv'],
                              cardholderName: result['cardholderName'],
                            );
                            await _loadData(); // Reload data after adding card
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error adding card: $e')),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
                SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        cards
                            .map(
                              (card) => Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: CardTile(
                                  color: card['color'],
                                  type: card['type'],
                                  fullNumber: card['fullNumber'],
                                  expiryDate: card['expiryDate'],
                                  cvv: card['cvv'],
                                  cardholderName: card['cardholderName'],
                                ),
                              ),
                            )
                            .toList(),
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
                            child: Icon(item['icon'], color: Colors.white),
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
  final String expiryDate;
  final String cvv;
  final String cardholderName;

  const CardTile({
    required this.color,
    required this.type,
    required this.fullNumber,
    required this.expiryDate,
    required this.cardholderName,
    required this.cvv,
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
      return _formatCardNumber(widget.fullNumber);
    } else {
      String lastFour = widget.fullNumber.substring(
        widget.fullNumber.length - 4,
      );
      return "**** **** **** " + lastFour;
    }
  }

  String get _displayCVV {
    return _isRevealed ? widget.cvv : "***";
  }

  String _formatCardNumber(String number) {
    String formatted = "";
    for (int i = 0; i < number.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formatted += " ";
      }
      formatted += number[i];
    }
    return formatted;
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
            SizedBox(height: 10),
            Text(
              _displayNumber,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'VALID THRU',
                      style: TextStyle(color: Colors.white60, fontSize: 10),
                    ),
                    Text(
                      widget.expiryDate,
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CVV',
                      style: TextStyle(color: Colors.white60, fontSize: 10),
                    ),
                    Text(
                      _displayCVV,
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CARDHOLDER NAME',
                  style: TextStyle(color: Colors.white60, fontSize: 10),
                ),
                Text(
                  widget.cardholderName.toUpperCase(),
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              'Tap to reveal/hide sensitive information',
              style: TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
