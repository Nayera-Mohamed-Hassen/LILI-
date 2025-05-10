import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../models/user.dart';
import 'wave2.dart'; // Import the wave clipper here

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
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                ClipPath(
                  clipper: WaveClipper(), // Use WaveClipper for the wave-style clip
                  child: Container(
                    height: 250,
                    width: double.infinity,
                    color: Color(0xFF213555),
                  ),
                ),
                Positioned(
                  top: 100, // Position the profile image correctly
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
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
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildTextField(nameController, "Name"),
                  _buildTextField(emailController, "Email"),
                  _buildTextField(phoneController, "Phone"),
                  _buildTextField(addressController, "Address", maxLines: 3),
                  SizedBox(height: 30),
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF213555),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

  Widget _buildTextField(
      TextEditingController controller,
      String label, {
        int maxLines = 1,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}
