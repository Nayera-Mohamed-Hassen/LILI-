import 'package:flutter/material.dart';

class IncomePage extends StatefulWidget {
  final double income;

  IncomePage({required this.income});

  @override
  _IncomePageState createState() => _IncomePageState();
}

class _IncomePageState extends State<IncomePage> {
  final TextEditingController _amountController = TextEditingController();

  void _submitIncome() {
    final amount = double.tryParse(_amountController.text);
    if (amount != null && amount > 0) {
      Navigator.pop(context, {'amount': amount});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enter a valid income amount')),
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
        title: Text('Add Income', style: TextStyle(color: Colors.white)),
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
                'assets/images/income.png',
                height: 220,
              ),
            ),
            SizedBox(height: 40),
            Text('Total Income: \$${widget.income.toStringAsFixed(2)}',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
            SizedBox(height: 40),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(labelText: 'Enter income amount'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 30),
            _buildButton(
              'Add Income',
              onPressed: _submitIncome,
              size: Size(double.infinity, 50),
            ),
          ],
        ),
      ),
    );
  }
}
