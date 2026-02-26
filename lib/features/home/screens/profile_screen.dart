import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:fitness_app/features/home/controllers/home_profile_controller.dart';
import 'package:fitness_app/layout/main_layout.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final HomeProfileController _profileController;
  int _tabIndex = 0; // 0 = Public, 1 = Likes

  @override
  void initState() {
    super.initState();
    _profileController = Get.isRegistered<HomeProfileController>()
        ? Get.find<HomeProfileController>()
        : Get.put(HomeProfileController(), permanent: true);
  }

  Future<void> _openEditProfileSheet() async {
    final nameCtrl = TextEditingController(
      text: _profileController.displayName.value,
    );
    final userCtrl = TextEditingController(
      text: _profileController.userName.value,
    );
    final bioCtrl = TextEditingController(text: _profileController.bio.value);
    Uint8List? selectedAvatar;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Center(
                      child: GestureDetector(
                        onTap: () async {
                          final picker = ImagePicker();
                          final picked = await picker.pickImage(
                            source: ImageSource.gallery,
                            imageQuality: 85,
                          );
                          if (picked == null) return;
                          final bytes = await picked.readAsBytes();
                          setSheetState(() => selectedAvatar = bytes);
                        },
                        child: CircleAvatar(
                          radius: 42,
                          backgroundImage: selectedAvatar != null
                              ? MemoryImage(selectedAvatar!)
                              : _profileController.avatarProvider,
                          backgroundColor: const Color(0xFFEAEAEA),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: userCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: bioCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Bio',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                        ),
                        onPressed: () {
                          _profileController.setProfile(
                            name: nameCtrl.text,
                            username: userCtrl.text,
                            userBio: bioCtrl.text,
                            avatar: selectedAvatar,
                          );
                          Get.back();
                        },
                        child: const Text(
                          'Save',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    nameCtrl.dispose();
    userCtrl.dispose();
    bioCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Profile',
      showBottomNav: true,
      currentIndex: 0,
      body: Container(
        color: const Color(0xFFF6F6F6),
        child: SafeArea(
          child: Obx(() {
            final items = _tabIndex == 0
                ? _profileController.mediaItems.toList(growable: false)
                : _profileController.likedMediaItems;

            return Column(
              children: [
                const SizedBox(height: 8),
                Text(
                  _profileController.displayName.value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                CircleAvatar(
                  radius: 48,
                  backgroundImage: _profileController.avatarProvider,
                  backgroundColor: const Color(0xFFEAEAEA),
                ),
                const SizedBox(height: 8),
                Text(
                  _profileController.userName.value,
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _StatItem(
                      label: 'Following',
                      value: _profileController.followingCount.value,
                    ),
                    const SizedBox(width: 26),
                    _StatItem(
                      label: 'Followers',
                      value: _profileController.followerCount.value,
                    ),
                    const SizedBox(width: 26),
                    _StatItem(
                      label: 'Likes',
                      value: _profileController.likesCount,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 220,
                  height: 36,
                  child: OutlinedButton(
                    onPressed: _openEditProfileSheet,
                    child: const Text('Edit profile'),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _profileController.bio.value,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 10),
                _ProfileTabs(
                  selectedIndex: _tabIndex,
                  onTap: (index) => setState(() => _tabIndex = index),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 8,
                    ),
                    itemCount: items.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                          childAspectRatio: 1,
                        ),
                    itemBuilder: (context, index) {
                      final media = items[index];
                      return GestureDetector(
                        onDoubleTap: () =>
                            _profileController.toggleLike(media.id),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (media.bytes != null)
                              Image.memory(media.bytes!, fit: BoxFit.cover)
                            else
                              Image.network(
                                media.imageUrl ?? '',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      color: const Color(0xFFE8E8E8),
                                      child: const Icon(
                                        Icons.image_not_supported,
                                      ),
                                    ),
                              ),
                            Positioned(
                              right: 6,
                              top: 6,
                              child: GestureDetector(
                                onTap: () =>
                                    _profileController.toggleLike(media.id),
                                child: Icon(
                                  media.isLiked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: media.isLiked
                                      ? Colors.red
                                      : Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final int value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$value', style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.black54),
        ),
      ],
    );
  }
}

class _ProfileTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _ProfileTabs({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      height: 34,
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFEF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _TabButton(
            label: 'Public',
            selected: selectedIndex == 0,
            onTap: () => onTap(0),
          ),
          _TabButton(
            label: 'Likes',
            selected: selectedIndex == 1,
            onTap: () => onTap(1),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(2),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.black : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
