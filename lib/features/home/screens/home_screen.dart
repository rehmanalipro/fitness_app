import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:fitness_app/routes/app_routes.dart';
import 'package:fitness_app/layout/main_layout.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _avatarBytes;
  String _displayName = 'Mentisa Mayo';

  Future<void> _pickAvatar() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    setState(() {
      _avatarBytes = bytes;
    });
  }

  Future<void> _editName() async {
    final controller = TextEditingController(text: _displayName);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Name'),
          content: TextField(
            controller: controller,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(hintText: 'Enter your name'),
            onSubmitted: (_) => Navigator.of(context).pop(controller.text),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (newName == null) return;
    final trimmed = newName.trim();
    if (trimmed.isEmpty) return;
    setState(() {
      _displayName = trimmed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.of(context).padding.bottom;
    final ImageProvider avatarProvider = _avatarBytes != null
        ? MemoryImage(_avatarBytes!)
        : const NetworkImage("https://i.pravatar.cc/150?img=47");

    return MainLayout(
      title: "Home",
      currentIndex: 0,
      constrainBody: false,
      body: Stack(
        children: [
          // BLACK HEADER
          Container(height: 220, width: double.infinity, color: Colors.black),

          // CONTENT (SCROLLABLE)
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: _editName,
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Welcome",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _displayName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          InkWell(
                            onTap: _pickAvatar,
                            borderRadius: BorderRadius.circular(18),
                            child: CircleAvatar(
                              radius: 18,
                              backgroundImage: avatarProvider,
                            ),
                          ),
                          const SizedBox(width: 10),
                          InkWell(
                            onTap: () => Get.toNamed(AppRoutes.notifications),
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.notifications_none,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // MAIN CARD
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // SELECT CATEGORY (CLICKABLE)
                        InkWell(
                          onTap: () {
                            // TODO: open category modal
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text("Select Category"),
                                Icon(Icons.keyboard_arrow_down),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // START RANDOM CHALLENGE (CENTER)
                        Center(
                          child: SizedBox(
                            width: 260,
                            height: 44,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () =>
                                  Get.toNamed(AppRoutes.challenges),
                              child: const Text(
                                "Start Random Challenge",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          "Current Challenges",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // SCROLLABLE CHALLENGES ONLY
                        SizedBox(
                          height: 200,
                          child: ListView(
                            physics: const BouncingScrollPhysics(),
                            children: const [
                              _ChallengeItem(
                                title: "Push Up",
                                subtitle: "100 Push up a day",
                                duration: "5:00 min",
                                progress: 0.42,
                                imageUrl:
                                    "https://images.pexels.com/photos/416778/pexels-photo-416778.jpeg",
                              ),
                              SizedBox(height: 12),
                              _ChallengeItem(
                                title: "Sit Up",
                                subtitle: "20 Sit up a day",
                                duration: "5:00 min",
                                progress: 0.78,
                                imageUrl:
                                    "https://images.pexels.com/photos/3768916/pexels-photo-3768916.jpeg",
                              ),
                              SizedBox(height: 12),
                              _ChallengeItem(
                                title: "Knee Push Up",
                                subtitle: "20 reps",
                                duration: "5:00 min",
                                progress: 0.35,
                                imageUrl:
                                    "https://images.pexels.com/photos/414029/pexels-photo-414029.jpeg",
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // RECOMMENDED MEAL
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              "Recommended Meal",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "View all",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            children: [
                              Image.network(
                                "https://images.pexels.com/photos/376464/pexels-photo-376464.jpeg",
                                height: 170,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                              const Positioned(
                                left: 12,
                                bottom: 12,
                                right: 12,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Nut Butter Toast With Boiled Eggs",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "164 kcal",
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 120 + bottomSafe),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChallengeItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String duration;
  final double progress;
  final String imageUrl;

  const _ChallengeItem({
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.progress,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              imageUrl,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade200,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            duration,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
