import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fitness_app/routes/app_routes.dart';
import 'package:fitness_app/layout/main_layout.dart';
import 'package:fitness_app/features/home/controllers/home_profile_controller.dart';
import 'package:fitness_app/features/settings/services/fitness_level_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeProfileController _profileController;
  final FitnessLevelService _fitnessLevelService = FitnessLevelService();
  String _fitnessLevel = 'Beginner';
  bool _loadingLevel = true;

  @override
  void initState() {
    super.initState();
    _profileController = Get.isRegistered<HomeProfileController>()
        ? Get.find<HomeProfileController>()
        : Get.put(HomeProfileController(), permanent: true);
    _loadFitnessLevel();
  }

  Future<void> _loadFitnessLevel() async {
    final level = await _fitnessLevelService.resolveInitialLevel();
    if (!mounted) return;
    setState(() {
      _fitnessLevel = level;
      _loadingLevel = false;
    });
  }

  Future<void> _openChangeFitnessLevel() async {
    await Get.toNamed(AppRoutes.changeFitnessLevel);
    await _loadFitnessLevel();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Home',
      isHome: true,
      showBottomNav: true,
      currentIndex: 0,
      constrainBody: false,
      useScreenPadding: false,
      body: Container(
        color: const Color(0xFFF5F5F5),
        child: SafeArea(
          child: Stack(
            children: [
              // BLACK HEADER
              Container(
                height: 150,
                width: double.infinity,
                color: Colors.black,
              ),

              // CONTENT
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(
                          () => Column(
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
                                _profileController.displayName.value,
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
                            Obx(
                              () => InkWell(
                                onTap: () => Get.toNamed(AppRoutes.profile),
                                borderRadius: BorderRadius.circular(18),
                                child: CircleAvatar(
                                  radius: 18,
                                  backgroundImage:
                                      _profileController.avatarProvider,
                                  backgroundColor: const Color(0xFFEAEAEA),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            InkWell(
                              onTap: () =>
                                  Get.toNamed(AppRoutes.notifications),
                              borderRadius: BorderRadius.circular(10),
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
                          // SELECT CATEGORY (Fitness level)
                          InkWell(
                            onTap: _openChangeFitnessLevel,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _loadingLevel
                                        ? 'Fitness Level'
                                        : 'Fitness Level: $_fitnessLevel',
                                  ),
                                  const Icon(Icons.keyboard_arrow_down),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // RANDOM CHALLENGE BUTTON
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                Get.toNamed(AppRoutes.randomChallenge);
                              },
                              child: const Text(
                                "Start Random Challenge",
                                style: TextStyle(color: Colors.white),
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
                                SizedBox(height: 12), //
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
                    const SizedBox(height: 110),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// CHALLENGE ITEM WIDGET

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
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            imageUrl,
            width: 64,
            height: 64,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 8),
              //   PROGRESS BAR
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFEFEFEF),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF19C4C1),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          duration,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}
