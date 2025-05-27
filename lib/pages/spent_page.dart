import 'package:flutter/material.dart';

class SpentPage extends StatefulWidget {
  final double spent;

  SpentPage({required this.spent});

  @override
  _SpentPageState createState() => _SpentPageState();
}

class _SpentPageState extends State<SpentPage> {
  String? selectedCategory;
  final TextEditingController _amountController = TextEditingController();

  final List<String> categories = ['Grocery', 'Transport', 'Bills', 'Shopping', 'Food', 'Other'];

  void _submitSpent() {
    final amount = double.tryParse(_amountController.text);
    if (selectedCategory != null && amount != null && amount > 0) {
      Navigator.pop(context, {'category': selectedCategory, 'amount': amount});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Select category and enter valid amount')),
      );
    }
  }

  Widget _buildButton(
      String text, {
        required VoidCallback onPressed,
        Size? size,
        Color? backgroundColor,
        Color? textColor,
      }) {
    final fixedSize = size ?? const Size(200, 60);
    final bgColor = backgroundColor ?? const Color(0xFF3E5879);
    final txtColor = textColor ?? Colors.white;

    return SizedBox(
      width: fixedSize.width,
      height: fixedSize.height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(color: txtColor, fontSize: 18),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Expense", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF1F3354),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(height: 70),
            Center(
              child: Image.asset(
                'assets/images/expenses.png',
                height: 220,
              ),
            ),
            SizedBox(height: 40),
            Text('Total Spent: \$${widget.spent.toStringAsFixed(2)}',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
            SizedBox(height: 40),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              hint: Text("Select Category"),
              onChanged: (val) => setState(() => selectedCategory = val),
              items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Amount Spent'),
            ),
            SizedBox(height: 30),
            _buildButton(
              "Add Expense",
              onPressed: _submitSpent,
              size: Size(double.infinity, 50),
            ),
          ],
        ),
      ),
    );
  }
}
