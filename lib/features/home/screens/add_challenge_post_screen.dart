import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:fitness_app/features/home/controllers/challenges_feed_controller.dart';
import 'package:fitness_app/layout/main_layout.dart';

class AddChallengePostScreen extends StatefulWidget {
  const AddChallengePostScreen({super.key});

  @override
  State<AddChallengePostScreen> createState() => _AddChallengePostScreenState();
}

class _AddChallengePostScreenState extends State<AddChallengePostScreen> {
  final _nameCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String? _selectedCategory;
  String? _selectedFitnessLevel;

  Uint8List? _imageBytes;
  String? _videoPath;
  bool _isVideo = false;
  bool _isLoading = false;

  final List<String> _categories = [
    'Strength',
    'Cardio',
    'Core',
    'Flexibility',
    'HIIT',
    'Yoga',
  ];
  final List<String> _fitnessLevels = ['Beginner', 'Intermediate', 'Advanced'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _timeCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _imageBytes = bytes;
      _videoPath = null;
      _isVideo = false;
    });
  }

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final picked = await picker.pickVideo(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() {
      _videoPath = picked.path;
      _imageBytes = null;
      _isVideo = true;
    });
  }

  void _showMediaPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Upload Image'),
              onTap: () {
                Get.back();
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Upload Video'),
              onTap: () {
                Get.back();
                _pickVideo();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    final time = _timeCtrl.text.trim();
    final desc = _descCtrl.text.trim();

    if (name.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter challenge name',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (_selectedCategory == null) {
      Get.snackbar(
        'Error',
        'Please select a category',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (_selectedFitnessLevel == null) {
      Get.snackbar(
        'Error',
        'Please select fitness level',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _isLoading = true);

    final controller = Get.isRegistered<ChallengesFeedController>()
        ? Get.find<ChallengesFeedController>()
        : Get.put(ChallengesFeedController(), permanent: true);

    // await so we know if backend saved it
    await controller.addMyPost(
      title: name,
      target: time.isNotEmpty ? time : name,
      category: _selectedCategory!,
      fitnessLevel: _selectedFitnessLevel!,
      description: desc,
      imageBytes: _imageBytes,
      videoPath: _videoPath,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);
    Get.back(result: true);
    Get.snackbar(
      'Posted',
      'Challenge posted successfully!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Add Challenge',
      showAppBar: true,
      showBackButton: true,
      showBottomNav: false,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Challenge Name
            _buildTextField(_nameCtrl, 'Challenge Name'),
            const SizedBox(height: 12),

            // Time
            _buildTextField(_timeCtrl, 'Time (e.g. 5:00 min)'),
            const SizedBox(height: 12),

            // Select Category
            _buildDropdown(
              hint: 'Select Category',
              value: _selectedCategory,
              items: _categories,
              onChanged: (v) => setState(() => _selectedCategory = v),
            ),
            const SizedBox(height: 12),

            // Fitness Level
            _buildDropdown(
              hint: 'Fitness Level',
              value: _selectedFitnessLevel,
              items: _fitnessLevels,
              onChanged: (v) => setState(() => _selectedFitnessLevel = v),
            ),
            const SizedBox(height: 12),

            // Upload Image / Video
            GestureDetector(
              onTap: _showMediaPicker,
              child: Container(
                width: double.infinity,
                height: _imageBytes != null || _videoPath != null ? null : 100,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFD9D9D9)),
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xFFFAFAFA),
                ),
                child: _buildMediaPreview(),
              ),
            ),
            const SizedBox(height: 12),

            // Description
            TextField(
              controller: _descCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Description',
                hintStyle: const TextStyle(color: Color(0xFFBBBBBB)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: 24),

            // Post Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Post',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFBBBBBB)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD9D9D9)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(hint, style: const TextStyle(color: Color(0xFFBBBBBB))),
          value: value,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildMediaPreview() {
    if (_imageBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            Image.memory(
              _imageBytes!,
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => setState(() => _imageBytes = null),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(4),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ),
          ],
        ),
      );
    }
    if (_videoPath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            Container(
              height: 180,
              color: Colors.black87,
              child: const Center(
                child: Icon(
                  Icons.play_circle_fill,
                  color: Colors.white,
                  size: 56,
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => setState(() {
                  _videoPath = null;
                  _isVideo = false;
                }),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(4),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  File(_videoPath!).path.split('/').last,
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 20),
        Icon(Icons.upload_file, size: 28, color: Color(0xFFBBBBBB)),
        SizedBox(height: 6),
        Text(
          'Upload Image / Video',
          style: TextStyle(color: Color(0xFFBBBBBB), fontSize: 13),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
