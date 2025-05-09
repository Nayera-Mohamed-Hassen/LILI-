import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user.dart';
import 'wave.dart';

class EditProfilePage extends StatefulWidget {
  final User user;
  EditProfilePage({required this.user});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late ImagePicker _picker;
  XFile? _image;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user.name);
    emailController = TextEditingController(text: widget.user.email);
    phoneController = TextEditingController(text: widget.user.phone);
    addressController = TextEditingController(text: widget.user.address);
    _picker = ImagePicker();
  }

  Future<void> _pickImage() async {
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = pickedImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF213555),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () => print('Notification icon pressed'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ClipPath(
              clipper: CustomClipPath(),
              child: Container(
                height: 150,
                width: double.infinity,
                color: Color(0xFF213555),
                alignment: Alignment.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _image != null
                          ? FileImage(File(_image!.path))
                          : null,
                      child: _image == null
                          ? Icon(Icons.camera_alt, size: 40, color: Colors.white)
                          : null,
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildTextField("Name", nameController),
                  _buildTextField("Email", emailController),
                  _buildTextField("Phone", phoneController),
                  _buildTextField("Address", addressController),
                  SizedBox(height: 30),
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF213555),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                          fixedSize: Size(260, 40),
                        ),
                        child: Text("Discard", style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          final updatedUser = widget.user.copyWith(
                            name: nameController.text,
                            email: emailController.text,
                            phone: phoneController.text,
                            address: addressController.text,
                          );
                          Navigator.pop(context, updatedUser);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF213555),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                          fixedSize: Size(260, 40),
                        ),
                        child: Text("Save Changes", style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}