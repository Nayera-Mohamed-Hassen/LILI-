import 'package:flutter/material.dart';

class AddVisaPage extends StatefulWidget {
  @override
  _AddVisaPageState createState() => _AddVisaPageState();
}

class _AddVisaPageState extends State<AddVisaPage> {
  final TextEditingController _cardController = TextEditingController();
  String cardType = 'VISA';

  // Format card number with spaces every 4 digits
  String formatCardNumber(String input) {
    String digitsOnly = input.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i != 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digitsOnly[i]);
    }
    return buffer.toString();
  }

  // Custom button widget
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
        title: Text('Add Visa', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF1F3354),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(height: 70),
            Center(
              child: Image.asset(
                'assets/images/visa.png',
                height: 220,
              ),
            ),
            SizedBox(height: 40),
            DropdownButtonFormField<String>(
              value: cardType,
              decoration: InputDecoration(
                labelText: 'Card Type',
                border: OutlineInputBorder(),
              ),
              items: ['VISA', 'Master Card', 'American Express', 'Discover']
                  .map((type) => DropdownMenuItem(
                value: type,
                child: Text(type),
              ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    cardType = value;
                  });
                }
              },
            ),

            SizedBox(height: 20),
            TextField(
              controller: _cardController,
              keyboardType: TextInputType.number,
              maxLength: 19,
              decoration: InputDecoration(
                labelText: 'Card Number',
                hintText: 'Enter your card number',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                String formatted = formatCardNumber(value);
                if (formatted != value) {
                  _cardController.value = TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(offset: formatted.length),
                  );
                }
              },
            ),

            SizedBox(height: 30),
            _buildButton(
              'Add Card',
              onPressed: () {
                if (_cardController.text.isEmpty || _cardController.text.length < 19) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter a valid card number')),
                  );
                  return;
                }
                Navigator.pop(context, {
                  'color': Color(0xFF1F3354),
                  'type': cardType,
                  'fullNumber': _cardController.text.trim(),
                });
              },
              size: Size(double.infinity, 50),
            ),
          ],
        ),
      ),
    );
  }
}
