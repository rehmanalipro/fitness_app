import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fitness_app/routes/app_routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWeb = constraints.maxWidth >= 900;
        final double maxContentWidth = isWeb ? 600 : double.infinity;
        final double headerHeight = isWeb ? 260 : 220;
        final double bottomSafe = MediaQuery.of(context).padding.bottom;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          body: SafeArea(
            child: Stack(
              children: [
                // HEADER BACKGROUND
                Container(
                  height: headerHeight,
                  width: double.infinity,
                  color: Colors.black,
                ),

                // CONTENT
                SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxContentWidth),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),

                            // HEADER ROW
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      "Welcome",
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      "Mentisa Mayo",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor: Colors.white,
                                      child: CircleAvatar(
                                        radius: 16,
                                        backgroundImage: NetworkImage(
                                          "https://i.pravatar.cc/150?img=47",
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Container(
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
                                  ],
                                ),
                              ],
                            ), //

                            const SizedBox(height: 24),

                            // WHITE CARD
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Current Challenges",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
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
                                    subtitle: "20 Sit up a day",
                                    duration: "5:00 min",
                                    progress: 0.42,
                                    imageUrl:
                                        "https://images.pexels.com/photos/414029/pexels-photo-414029.jpeg",
                                  ),

                                  const SizedBox(height: 20),

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                          height: isWeb ? 240 : 170,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                        Positioned(
                                          left: 12,
                                          bottom: 12,
                                          right: 12,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: const [
                                              Text(
                                                "Nut Butter Toast With Boiled Eggs",
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
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

                            SizedBox(height: 120 + bottomSafe + 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // FAB
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.black,
            onPressed: () => Get.toNamed(AppRoutes.addAction),
            child: const Icon(Icons.add, color: Colors.white),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,

          // BOTTOM BAR
          bottomNavigationBar: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const _NavItem(
                      icon: Icons.home,
                      label: "Home",
                      active: true,
                    ),
                    _NavItem(
                      icon: Icons.restaurant,
                      label: "Food Log",
                      onTap: () => Get.toNamed(AppRoutes.foodLog),
                    ),
                    _NavItem(
                      icon: Icons.fitness_center,
                      label: "Challenges",
                      onTap: () => Get.toNamed(AppRoutes.challenges),
                    ),
                    const SizedBox(width: 40),
                    _NavItem(
                      icon: Icons.leaderboard,
                      label: "Leaderboard",
                      onTap: () => Get.toNamed(AppRoutes.leaderboard),
                    ),
                    _NavItem(
                      icon: Icons.menu_book,
                      label: "Guides",
                      onTap: () => Get.toNamed(AppRoutes.guides),
                    ),
                    _NavItem(
                      icon: Icons.settings,
                      label: "Settings",
                      onTap: () => Get.toNamed(AppRoutes.settings),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    this.active = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: active ? Colors.black : Colors.grey),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: active ? Colors.black : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

