import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SetProfile extends StatefulWidget {
  const SetProfile({super.key});

  @override
  State<SetProfile> createState() => _SetProfileState();
}

class _SetProfileState extends State<SetProfile> {
  File? _profileImage;
  final _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _roleController = TextEditingController();
  final _schoolController = TextEditingController();
  final _locationController = TextEditingController();
  final _bioController = TextEditingController();

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your $fieldName';
    }
    return null;
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() => _profileImage = File(pickedFile.path));
    }
    Navigator.pop(context);
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSheetOption(
              icon: Icons.delete,
              label: 'Remove Photo',
              onTap: () {
                setState(() => _profileImage = null);
                Navigator.pop(context);
              },
              iconColor: Colors.redAccent,
              textColor: Colors.redAccent,
            ),
            _buildSheetOption(
              icon: Icons.camera_alt,
              label: 'Take Photo',
              onTap: () => _pickImage(ImageSource.camera),
            ),
            _buildSheetOption(
              icon: Icons.photo_library,
              label: 'Choose from Gallery',
              onTap: () => _pickImage(ImageSource.gallery),
            ),
            _buildSheetOption(
              icon: Icons.close,
              label: 'Cancel',
              onTap: () => Navigator.pop(context),
              textColor: Colors.grey,
              iconColor: Colors.grey,
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildSheetOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color textColor = Colors.white,
    Color iconColor = Colors.white,
  }) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.grey[800],
      highlightColor: Colors.grey[700],
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFeedback(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  Widget _buildLabeledField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      cursorColor: Colors.white70,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blue.withOpacity(0.6), width: 1.3),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  //  Profile Picture
                  GestureDetector(
                    onTap: _showImageOptions,
                    child: Stack(
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.blueAccent, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.4),
                                blurRadius: 4,
                                spreadRadius: 1,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: _profileImage != null
                                ? Image.file(_profileImage!, fit: BoxFit.cover)
                                : const Icon(Icons.person, size: 55, color: Colors.grey),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 📋 Fields with subtle underline
                  _buildLabeledField(
                    label: 'Username',
                    controller: _usernameController,
                    validator: (value) => _validateRequired(value, 'username'),
                  ),
                  const SizedBox(height: 20),

                  _buildLabeledField(
                    label: 'Role (Optional)',
                    controller: _roleController,
                  ),
                  const SizedBox(height: 20),

                  _buildLabeledField(
                    label: 'School/College',
                    controller: _schoolController,
                    validator: (value) => _validateRequired(value, 'school/college'),
                  ),
                  const SizedBox(height: 20),

                  _buildLabeledField(
                    label: 'Location (Optional)',
                    controller: _locationController,
                  ),
                  const SizedBox(height: 20),

                  _buildLabeledField(
                    label: 'Bio',
                    controller: _bioController,
                    validator: (value) => _validateRequired(value, 'bio'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 28),

                  // ✅ Save Button
                  Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 160,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _showFeedback(
                              'Profile saved successfully',
                              Colors.green,
                              Icons.check_circle,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Save Profile',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
