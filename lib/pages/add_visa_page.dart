import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddVisaPage extends StatefulWidget {
  @override
  _AddVisaPageState createState() => _AddVisaPageState();
}

class _AddVisaPageState extends State<AddVisaPage> {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String selectedType = 'VISA';

  final List<Map<String, dynamic>> cardTypes = [
    {'name': 'VISA', 'icon': Icons.credit_card},
    {'name': 'Master Card', 'icon': Icons.credit_card},
    {'name': 'American Express', 'icon': Icons.credit_card},
  ];

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  String _formatCardNumber(String text) {
    if (text.length < 4) return text;
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(text[i]);
    }
    return buffer.toString().trim();
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
                      'Add Card',
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
                          'Card Type',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: cardTypes.map((type) {
                            final isSelected = selectedType == type['name'];
                            return Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedType = type['name'];
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.only(right: type != cardTypes.last ? 12 : 0),
                                  padding: EdgeInsets.symmetric(vertical: 16),
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
                                    children: [
                                      Icon(
                                        type['icon'],
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        type['name'],
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 24),
                        _buildInputField(
                          label: 'Card Number',
                          controller: _cardNumberController,
                          keyboardType: TextInputType.number,
                          maxLength: 16,
                          formatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (value) {
                            if (value.length <= 16) {
                              final formatted = _formatCardNumber(value.replaceAll(' ', ''));
                              if (formatted != value) {
                                _cardNumberController.value = TextEditingValue(
                                  text: formatted,
                                  selection: TextSelection.collapsed(offset: formatted.length),
                                );
                              }
                            }
                          },
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInputField(
                                label: 'Expiry Date',
                                controller: _expiryController,
                                keyboardType: TextInputType.number,
                                maxLength: 5,
                                hintText: 'MM/YY',
                                formatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(4),
                                ],
                                onChanged: (value) {
                                  if (value.length == 2 && !value.contains('/')) {
                                    _expiryController.text = '$value/';
                                    _expiryController.selection = TextSelection.fromPosition(
                                      TextPosition(offset: _expiryController.text.length),
                                    );
                                  }
                                },
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: _buildInputField(
                                label: 'CVV',
                                controller: _cvvController,
                                keyboardType: TextInputType.number,
                                maxLength: 4,
                                formatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        _buildInputField(
                          label: 'Cardholder Name',
                          controller: _nameController,
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.words,
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
                    if (_cardNumberController.text.isNotEmpty &&
                        _expiryController.text.isNotEmpty &&
                        _cvvController.text.isNotEmpty &&
                        _nameController.text.isNotEmpty) {
                      Navigator.pop(context, {
                        'type': selectedType,
                        'fullNumber': _cardNumberController.text,
                        'color': Color(0xFF1F3354),
                      });
                    }
                  },
                  child: Text(
                    'Add Card',
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

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    List<TextInputFormatter>? formatters,
    int? maxLength,
    String? hintText,
    void Function(String)? onChanged,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
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
            controller: controller,
            style: TextStyle(color: Colors.white, fontSize: 16),
            keyboardType: keyboardType,
            inputFormatters: formatters,
            maxLength: maxLength,
            textCapitalization: textCapitalization,
            decoration: InputDecoration(
              counterText: '',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.white38),
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
