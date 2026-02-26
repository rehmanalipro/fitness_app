import 'dart:typed_data';

import 'package:fitness_app/features/home/controllers/challenges_feed_controller.dart';
import 'package:fitness_app/layout/main_layout.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AddChallengePostScreen extends StatefulWidget {
  const AddChallengePostScreen({super.key});

  @override
  State<AddChallengePostScreen> createState() => _AddChallengePostScreenState();
}

class _AddChallengePostScreenState extends State<AddChallengePostScreen> {
  final _nameController = TextEditingController();
  final _timeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  String _category = 'Medium';
  String _fitnessLevel = 'Beginner';
  String? _selectedImageName;
  Uint8List? _selectedImageBytes;

  @override
  void dispose() {
    _nameController.dispose();
    _timeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _postChallenge() {
    if (_nameController.text.trim().isEmpty ||
        _timeController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty) {
      Get.snackbar(
        'Missing Fields',
        'Please fill all required fields',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final controller = Get.find<ChallengesFeedController>();
    controller.addMyPost(
      title: _nameController.text.trim(),
      target: _timeController.text.trim(),
      category: _category,
      fitnessLevel: _fitnessLevel,
      description: _selectedImageName == null
          ? _descriptionController.text.trim()
          : '${_descriptionController.text.trim()}\nImage: $_selectedImageName',
      imageBytes: _selectedImageBytes,
    );
    Get.back();
  }

  Future<void> _pickImage(ImageSource source) async {
    final file = await _imagePicker.pickImage(source: source, imageQuality: 85);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() {
      _selectedImageName = file.name;
      _selectedImageBytes = bytes;
    });
  }

  Future<void> _openImagePickerSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Add Challenge',
      showAppBar: true,
      showBackButton: true,
      showBottomNav: false,
      currentIndex: 2,
      constrainBody: false,
      body: Container(
        color: const Color(0xFFF5F5F5),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 24),
          child: Column(
            children: [
              _InputBox(
                child: TextField(
                  controller: _nameController,
                  style: const TextStyle(fontSize: 13),
                  decoration: _fieldDecoration('Challenge Name'),
                ),
              ),
              const SizedBox(height: 10),
              _InputBox(
                child: TextField(
                  controller: _timeController,
                  style: const TextStyle(fontSize: 13),
                  decoration: _fieldDecoration('Time'),
                ),
              ),
              const SizedBox(height: 10),
              _InputBox(
                child: DropdownButtonFormField<String>(
                  initialValue: _category,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF9A9A9A),
                  ),
                  decoration: _fieldDecoration('Select Category'),
                  items: const ['Easy', 'Medium', 'Hard']
                      .map(
                        (item) =>
                            DropdownMenuItem(value: item, child: Text(item)),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _category = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 10),
              _InputBox(
                child: DropdownButtonFormField<String>(
                  initialValue: _fitnessLevel,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF9A9A9A),
                  ),
                  decoration: _fieldDecoration('Fitness Level'),
                  items: const ['Beginner', 'Intermediate', 'Advanced']
                      .map(
                        (item) =>
                            DropdownMenuItem(value: item, child: Text(item)),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _fitnessLevel = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 10),
              _InputBox(
                child: InkWell(
                  onTap: _openImagePickerSheet,
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    height: 44,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _selectedImageName == null
                              ? 'Upload Image'
                              : _selectedImageName!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF7C7C7C),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.file_upload_outlined,
                          size: 16,
                          color: Color(0xFF8B8B8B),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_selectedImageBytes != null) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    _selectedImageBytes!,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              _InputBox(
                height: 98,
                child: TextField(
                  controller: _descriptionController,
                  maxLines: 4,
                  style: const TextStyle(fontSize: 13),
                  decoration: _fieldDecoration('Discription'),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed: _postChallenge,
                  child: const Text(
                    'Post',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9C9C9C)),
      border: InputBorder.none,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
    );
  }
}

class _InputBox extends StatelessWidget {
  final Widget child;
  final double height;

  const _InputBox({required this.child, this.height = 44});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD6D6D6)),
      ),
      child: child,
    );
  }
}
