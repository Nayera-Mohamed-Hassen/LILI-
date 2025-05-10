import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class HostHousePage extends StatefulWidget {
  const HostHousePage({super.key});

  @override
  _HostHousePageState createState() => _HostHousePageState();
}

class _HostHousePageState extends State<HostHousePage> {
  // final _diet = TextEditingController();
  final _houseName = TextEditingController();

  late ImagePicker _picker;
  XFile? _image;

  @override
  void initState() {
    super.initState();
    // nameController = TextEditingController(text: widget.user.name);
    // emailController = TextEditingController(text: widget.user.email);
    // phoneController = TextEditingController(text: widget.user.phone);
    // addressController = TextEditingController(text: widget.user.address);
    _picker = ImagePicker();
  }

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
      appBar: AppBar(
        leading: BackButton(),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
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
                  'Host House',
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
              _buildTextField(_houseName, 'House Name'),
              const SizedBox(height: 20),
              _buildButton(
                'Add User',
                onPressed: () {
                  Navigator.pushNamed(context, '/add user');
                },
              ),
              const SizedBox(height: 20),
              _buildButton(
                'Host House',
                onPressed: () {
                  if (_houseName.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please fill in all fields')),
                    );
                  } else {
                    Navigator.pushNamed(context, '/homepage');
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
}
