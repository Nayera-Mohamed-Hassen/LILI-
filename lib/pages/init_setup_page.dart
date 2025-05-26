import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class InitSetupPage extends StatefulWidget {
  final String name;
  final String email;
  final String password;
  final String phone;

  const InitSetupPage({
    super.key,
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
  });

  @override
  _InitSetupPageState createState() => _InitSetupPageState();
}

class _InitSetupPageState extends State<InitSetupPage> {
  // final _diet = TextEditingController();
  final _weight = TextEditingController();
  final _height = TextEditingController();
  final _illnessController = TextEditingController();
  final _alergiesController = TextEditingController();
  late ImagePicker _picker;
  XFile? _image;
  DateTime? _selectedDate;
  String? _selectedGender;
  String? _selectedDiet;
  late TextEditingController _dateController;

  @override
  void initState() {
    super.initState();
    // nameController = TextEditingController(text: widget.user.name);
    // emailController = TextEditingController(text: widget.user.email);
    // phoneController = TextEditingController(text: widget.user.phone);
    // addressController = TextEditingController(text: widget.user.address);
    _picker = ImagePicker();
    _dateController = TextEditingController();
  }

  final List<String> diets = [
    'Vegan',
    'Vegetarian',
    'Keto',
    'Gluten-Free',
    'Paleo',
    'Low-Carb',
    'Dairy-Free',
    'Low-Fat',
    'Whole30',
    'Halal',
  ];
  final List<String> genderOptions = ['Male', 'Female'];

  Future<void> _pickImage() async {
    final XFile? pickedImage = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    setState(() {
      _image = pickedImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Set Up',
                  style: TextStyle(
                    color: const Color(0xFF213555),
                    fontSize: 48,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  backgroundImage:
                      _image != null ? FileImage(File(_image!.path)) : null,
                  child:
                      _image == null
                          ? Icon(
                            Icons.camera_alt,
                            size: 40,
                            color: Colors.white,
                          )
                          : null,
                ),
              ),
              const SizedBox(height: 20),
              _buildDatePickerField(context),
              const SizedBox(height: 16),
              _buildDropdownField('Gender', genderOptions, _selectedGender, (
                value,
              ) {
                setState(() {
                  _selectedGender = value;
                });
              }),
              const SizedBox(height: 20),
              _buildDropdownField('Diet', diets, _selectedDiet, (value) {
                setState(() {
                  _selectedDiet = value;
                });
              }),
              const SizedBox(height: 20),
              _buildTextField(_weight, 'Weight'),
              const SizedBox(height: 20),
              _buildTextField(_height, 'Height'),
              const SizedBox(height: 20),
              _buildTextField(_alergiesController, 'Alergies', maxLines: 4),
              const SizedBox(height: 20),
              _buildButton(
                'Next',
                onPressed: () async {
                  final url = Uri.parse(
                    'http://10.0.2.2:8000/user/signup',
                  ); // update your URL

                  final response = await http.post(
                    url,
                    headers: {"Content-Type": "application/json"},
                    body: jsonEncode({
                      "name": widget.name,
                      "email": widget.email,
                      "password": widget.password,
                      "phone": widget.phone,
                      "birthday": _dateController.text,
                      "profile_pic": "", // add image upload support later
                      "height": double.tryParse(_height.text),
                      "weight": double.tryParse(_weight.text),
                      "diet": _selectedDiet,
                      "gender": _selectedGender,
                      "house_id": 1,
                    }),
                  );

                  if (response.statusCode == 200) {
                    Navigator.pushNamed(context, '/hosting');
                  } else {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Signup failed')));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
    String text, {
    required VoidCallback onPressed,
    Size? size,
  }) {
    final fixedSize = size ?? const Size(430, 60);

    return SizedBox(
      width: fixedSize.width,
      height: fixedSize.height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3E5879),
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    List<String> items,
    String? selectedValue,
    void Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.white,
      ),
      items:
          items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
      onChanged: onChanged,
    );
  }

  @override
  void dispose() {
    _dateController.dispose(); // Don't forget to dispose the controller
    super.dispose();
  }

  Widget _buildDatePickerField(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
          setState(() {
            _selectedDate = pickedDate;
            // Update the controller with the formatted date
            _dateController.text = DateFormat(
              'yyyy-MM-dd',
            ).format(_selectedDate!);
          });
        }
      },
      child: AbsorbPointer(
        child: TextField(
          controller: _dateController, // Bind the controller
          decoration: InputDecoration(
            labelText: 'Birthdate',
            hintText:
                _selectedDate != null
                    ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                    : 'Select date',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ),
    );
  }
}
