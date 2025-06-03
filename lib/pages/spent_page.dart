import 'package:flutter/material.dart';

class SpentPage extends StatefulWidget {
  final double spent;

  const SpentPage({Key? key, required this.spent}) : super(key: key);

  @override
  _SpentPageState createState() => _SpentPageState();
}

class _SpentPageState extends State<SpentPage> {
  final TextEditingController _amountController = TextEditingController();
  String selectedCategory = 'Grocery';
  
  final List<Map<String, dynamic>> categories = [
    {'name': 'Grocery', 'icon': Icons.store},
    {'name': 'Shopping', 'icon': Icons.shopping_bag_outlined},
    {'name': 'Transport', 'icon': Icons.directions_car},
    {'name': 'Bills', 'icon': Icons.receipt_long},
    {'name': 'Food', 'icon': Icons.fastfood},
    {'name': 'Entertainment', 'icon': Icons.movie_outlined},
    {'name': 'Health', 'icon': Icons.medical_services_outlined},
    {'name': 'Education', 'icon': Icons.school_outlined},
  ];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Add Expense',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Amount',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: TextField(
                            controller: _amountController,
                            style: TextStyle(color: Colors.white, fontSize: 24),
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.attach_money, color: Colors.white70),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              hintText: '0.00',
                              hintStyle: TextStyle(color: Colors.white38),
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                        Text(
                          'Category',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 16),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            final isSelected = selectedCategory == category['name'];
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedCategory = category['name'];
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? Colors.white.withOpacity(0.2)
                                      : Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected 
                                        ? Colors.white
                                        : Colors.white24,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      category['icon'],
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      category['name'],
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    final amount = double.tryParse(_amountController.text);
                    if (amount != null && amount > 0) {
                      Navigator.pop(context, {
                        'amount': amount,
                        'category': selectedCategory,
                      });
                    }
                  },
                  child: Text(
                    'Add Expense',
                    style: TextStyle(
                      color: Color(0xFF1F3354),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
