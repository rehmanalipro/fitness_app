import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:fitness_app/features/auth/services/auth_service.dart';
import 'package:fitness_app/layout/main_layout.dart';
import 'package:fitness_app/features/home/controllers/home_profile_controller.dart';

class ProfileSettingScreen extends StatefulWidget {
  const ProfileSettingScreen({super.key});

  @override
  State<ProfileSettingScreen> createState() => _ProfileSettingScreenState();
}

class _ProfileSettingScreenState extends State<ProfileSettingScreen> {
  late final HomeProfileController _profileController;
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _loadingAuth = true;
  bool _saving = false;
  bool _obscurePassword = true;
  List<String> _usernameSuggestions = [];

  @override
  void initState() {
    super.initState();
    _profileController = Get.isRegistered<HomeProfileController>()
        ? Get.find<HomeProfileController>()
        : Get.put(HomeProfileController(), permanent: true);
    _nameController = TextEditingController(
      text: _profileController.displayName.value,
    );
    // Strip @ from username
    final currentUsername = _profileController.userName.value;
    _usernameController = TextEditingController(
      text: currentUsername.startsWith('@') ? currentUsername.substring(1) : currentUsername,
    );
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _loadAuthData();
    _nameController.addListener(_generateUsernameSuggestions);
  }

  void _generateUsernameSuggestions() {
    final name = _nameController.text.trim().toLowerCase().replaceAll(' ', '_');
    if (name.isEmpty) { setState(() => _usernameSuggestions = []); return; }
    final rng = Random();
    setState(() {
      _usernameSuggestions = [
        name,
        '${name}_fit',
        '${name}_${rng.nextInt(999)}',
        'fit_$name',
        '${name}_official',
      ].toSet().toList(); // unique
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadAuthData() async {
    final email = await _authService.getEmail();
    final password = await _authService.getPassword();
    if (!mounted) return;
    setState(() {
      _emailController.text = email ?? '';
      _passwordController.text = password ?? '';
      _loadingAuth = false;
    });
  }

  Future<void> _pickProfileImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;

    await _profileController.uploadAvatarToApi(picked.path);
    await _profileController.loadProfileFromApi(force: true);
    if (!mounted) return;
    if (_profileController.syncError.value != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_profileController.syncError.value!)),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile image updated')));
    }
  }

  Future<void> _saveProfile() async {
    if (_saving) return;
    setState(() => _saving = true);

    final name = _nameController.text.trim();
    final username = _usernameController.text.trim();

    // Save to backend
    final saved = await _profileController.saveProfileToApi(
      name: name,
      username: username,
      userBio: _profileController.bio.value,
    );

    await _authService.saveEmail(_emailController.text.trim());
    if (_passwordController.text.trim().isNotEmpty) {
      await _authService.savePassword(_passwordController.text);
    }
    if (!mounted) return;
    setState(() => _saving = false);
    if (saved) {
      Get.back();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_profileController.syncError.value ?? 'Save failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Profile Settings',
      showAppBar: true,
      showBackButton: true,
      showBottomNav: false,
      currentIndex: 5,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    Obx(
                      () => CircleAvatar(
                        radius: 40,
                        backgroundImage: _profileController.avatarProvider,
                        backgroundColor: const Color(0xFFEAEAEA),
                        child: _profileController.avatarProvider == null
                            ? const Icon(
                                Icons.person,
                                size: 32,
                                color: Colors.black54,
                              )
                            : null,
                      ),
                    ),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: InkWell(
                        onTap: _pickProfileImage,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Display Name',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Enter your name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Username',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  hintText: 'e.g. john_fit',
                  prefixText: '@',
                  border: OutlineInputBorder(),
                ),
              ),
              if (_usernameSuggestions.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text('Suggestions:', style: TextStyle(fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: _usernameSuggestions.map((s) => GestureDetector(
                    onTap: () => setState(() => _usernameController.text = s),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFD0D0D0)),
                      ),
                      child: Text('@$s', style: const TextStyle(fontSize: 12)),
                    ),
                  )).toList(),
                ),
              ],
              const SizedBox(height: 14),
              const Text(
                'Email',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                readOnly: _loadingAuth,
                decoration: const InputDecoration(
                  hintText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Password',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                readOnly: _loadingAuth,
                decoration: InputDecoration(
                  hintText: 'Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  onPressed: _saving ? null : _saveProfile,
                  child: Text(
                    _saving ? 'Saving...' : 'Save',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
