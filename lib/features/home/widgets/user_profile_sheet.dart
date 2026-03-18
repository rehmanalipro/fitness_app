import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fitness_app/features/home/controllers/home_profile_controller.dart';

/// Reusable bottom sheet that shows a user's mini-profile.
/// Same style as the leaderboard user detail sheet.
void showUserProfileSheet(
  BuildContext context, {
  required String userId,
  required String name,
  required String handle,
  String? avatarUrl,
  int points = 0,
}) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _UserProfileSheet(
      userId: userId,
      name: name,
      handle: handle,
      avatarUrl: avatarUrl,
      points: points,
    ),
  );
}

class _UserProfileSheet extends StatelessWidget {
  final String userId;
  final String name;
  final String handle;
  final String? avatarUrl;
  final int points;

  const _UserProfileSheet({
    required this.userId,
    required this.name,
    required this.handle,
    required this.avatarUrl,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFDDDDDD),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          // Avatar
          CircleAvatar(
            radius: 44,
            backgroundColor: const Color(0xFFEAEAEA),
            backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
                ? NetworkImage(avatarUrl!)
                : null,
            child: (avatarUrl == null || avatarUrl!.isEmpty)
                ? const Icon(Icons.person, size: 40, color: Colors.black45)
                : null,
          ),
          const SizedBox(height: 12),
          // Name
          Text(
            name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            handle,
            style: const TextStyle(fontSize: 13, color: Colors.black45),
          ),
          if (points > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Color(0xFF18B4B1), size: 18),
                const SizedBox(width: 4),
                Text(
                  '$points pts',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF18B4B1),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          // Follow button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                try {
                  final profileCtrl = Get.find<HomeProfileController>();
                  profileCtrl.addFollowing(SocialUser(
                    id: userId,
                    name: name,
                    handle: handle,
                    avatarUrl: avatarUrl,
                  ));
                  Get.snackbar(
                    'Following',
                    'You are now following $name',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.black87,
                    colorText: Colors.white,
                    duration: const Duration(seconds: 2),
                  );
                } catch (_) {}
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Follow',
                  style: TextStyle(color: Colors.white, fontSize: 15)),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
