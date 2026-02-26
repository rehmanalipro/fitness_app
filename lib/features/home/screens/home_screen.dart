import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:fitness_app/core/widgets/fallback_network_image.dart';
import 'package:fitness_app/features/home/controllers/home_profile_controller.dart';
import 'package:fitness_app/routes/app_routes.dart';
import 'package:fitness_app/layout/main_layout.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeProfileController _profileController = Get.put(
    HomeProfileController(),
    permanent: true,
  );

  Future<void> _editName() async {
    final controller = TextEditingController(
      text: _profileController.displayName.value,
    );
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
    _profileController.setDisplayName(newName);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final bottomSafe = mediaQuery.padding.bottom;
    final topSafe = mediaQuery.padding.top;
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final maxContentWidth = isLandscape ? 860.0 : 390.0;
    final sidePadding = isLandscape ? 16.0 : 20.0;
    final panelTop = isLandscape ? 96.0 : 125.0;

    return MainLayout(
      title: "Home",
      currentIndex: 0,
      constrainBody: false,
      useScreenPadding: false,
      body: Stack(
        children: [
          Container(color: Colors.black),
          Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: math.min(maxContentWidth, screenSize.width),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: sidePadding),
                child: Column(
                  children: [
                    SizedBox(height: topSafe + 14),
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
                              Obx(
                                () => Text(
                                  _profileController.displayName.value,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 33,
                                    fontWeight: FontWeight.w700,
                                    height: 1.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            InkWell(
                              onTap: () => Get.toNamed(AppRoutes.profile),
                              borderRadius: BorderRadius.circular(18),
                              child: Obx(
                                () => CircleAvatar(
                                  radius: 18,
                                  backgroundImage:
                                      _profileController.avatarProvider,
                                  backgroundColor: const Color(0xFFEAEAEA),
                                  child:
                                      _profileController.avatarProvider == null
                                      ? const Icon(
                                          Icons.person,
                                          size: 20,
                                          color: Colors.black54,
                                        )
                                      : null,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            InkWell(
                              onTap: () => Get.toNamed(AppRoutes.notifications),
                              child: const Icon(
                                Icons.notifications_none,
                                size: 22,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: panelTop,
            left: 0,
            right: 0,
            bottom: 0,
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: math.min(maxContentWidth, screenSize.width),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: sidePadding),
                  child: SizedBox.expand(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          14,
                          16,
                          14,
                          24 + bottomSafe,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () {},
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: const [
                                    Text("Select Category"),
                                    Icon(Icons.keyboard_arrow_down),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "Choose Random Challenge",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Center(
                              child: SizedBox(
                                width: 260,
                                height: 36,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(9),
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
                            const SizedBox(height: 18),
                            const Text(
                              "Current Challenges",
                              style: TextStyle(
                                fontSize: 21,
                                color: Color(0xFF444444),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const _ChallengeItem(
                              title: "Push Up",
                              subtitle: "100 Push up a day",
                              duration: "5:00 min",
                              progress: 0.42,
                              imageUrl:
                                  "https://images.pexels.com/photos/416778/pexels-photo-416778.jpeg",
                            ),
                            const SizedBox(height: 12),
                            const _ChallengeItem(
                              title: "Sit Up",
                              subtitle: "20 Sit up a day",
                              duration: "5:00 min",
                              progress: 0.78,
                              imageUrl:
                                  "https://images.pexels.com/photos/3768916/pexels-photo-3768916.jpeg",
                            ),
                            const SizedBox(height: 12),
                            const _ChallengeItem(
                              title: "Knee Push Up",
                              subtitle: "20 reps",
                              duration: "5:00 min",
                              progress: 0.35,
                              imageUrl:
                                  "https://images.pexels.com/photos/414029/pexels-photo-414029.jpeg",
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text(
                                  "Recommended Meal",
                                  style: TextStyle(
                                    fontSize: 23,
                                    color: Color(0xFF676767),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  "View all",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF9A9A9A),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Stack(
                                children: [
                                  const FallbackNetworkImage(
                                    imageUrl:
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                    ),
                  ),
                ),
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
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          FallbackNetworkImage(
            imageUrl: imageUrl,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            borderRadius: BorderRadius.circular(10),
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
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
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
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
