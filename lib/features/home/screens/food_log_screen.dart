import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:fitness_app/features/home/controllers/home_profile_controller.dart';
import 'package:fitness_app/features/home/widgets/food_log/food_log_composer.dart';
import 'package:fitness_app/features/home/widgets/food_log/food_log_post_card.dart';
import 'package:fitness_app/features/home/widgets/food_log/food_log_tab_switcher.dart';
import 'package:fitness_app/layout/main_layout.dart';

class FoodLogScreen extends StatefulWidget {
  const FoodLogScreen({super.key});

  @override
  State<FoodLogScreen> createState() => _FoodLogScreenState();
}

class _FoodLogScreenState extends State<FoodLogScreen> {
  bool isPublicSelected = true;
  final TextEditingController _composerController = TextEditingController();
  late final HomeProfileController _profileController;

  final List<_FoodLogPost> _publicPosts = [
    const _FoodLogPost(
      name: 'Maude Hall',
      timeAgo: '14 min',
      avatarUrl: 'https://i.pravatar.cc/100?img=5',
      text:
          'Hey! My body weight is increasing. I\'m gaining weight and want some suggestions.',
      likes: 2,
    ),
    const _FoodLogPost(
      name: 'Maude Hall',
      timeAgo: '14 min',
      avatarUrl: 'https://i.pravatar.cc/100?img=5',
      text:
          'Sure! First, can you tell me about your daily routine and eating habits?',
      likes: 1,
    ),
  ];

  final List<_FoodLogPost> _myPosts = [
    const _FoodLogPost(
      name: 'My Post',
      timeAgo: '4 min',
      avatarUrl: 'https://i.pravatar.cc/100?img=47',
      text:
          'Hey! My body weight is increasing. I\'m gaining weight and want some suggestions.',
      likes: 2,
    ),
    const _FoodLogPost(
      name: 'My Post',
      timeAgo: '4 min',
      avatarUrl: 'https://i.pravatar.cc/100?img=47',
      text:
          'I am trying to improve diet and training consistency. Any tips for balance?',
      likes: 2,
    ),
    const _FoodLogPost(
      name: 'My Post',
      timeAgo: '4 min',
      avatarUrl: 'https://i.pravatar.cc/100?img=47',
      text: 'Thank you everyone for suggestions, I will apply them from today.',
      likes: 2,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _profileController = Get.isRegistered<HomeProfileController>()
        ? Get.find<HomeProfileController>()
        : Get.put(HomeProfileController(), permanent: true);
  }

  @override
  void dispose() {
    _composerController.dispose();
    super.dispose();
  }

  void _handlePost() {
    final text = _composerController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _myPosts.insert(
        0,
        _FoodLogPost(
          name: _profileController.displayName.value,
          timeAgo: 'Now',
          avatarUrl: 'https://i.pravatar.cc/100?img=47',
          text: text,
          likes: 0,
        ),
      );
      isPublicSelected = false;
      _composerController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final posts = isPublicSelected ? _publicPosts : _myPosts;

    return MainLayout(
      title: 'FoodLog',
      showAppBar: true,
      showBackButton: true,
      currentIndex: 1,
      body: Center(
        child: SizedBox(
          width: 388,
          height: 717,
          child: Padding(
            padding: const EdgeInsets.only(left: 23, right: 19, top: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FoodLogTabSwitcher(
                  isPublicSelected: isPublicSelected,
                  onPublicTap: () => setState(() => isPublicSelected = true),
                  onMyPostTap: () => setState(() => isPublicSelected = false),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: ListView.separated(
                    itemCount: posts.length,
                    separatorBuilder: (_, separatorIndex) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return FoodLogPostCard(
                        avatarUrl: post.avatarUrl,
                        name: post.name,
                        timeAgo: post.timeAgo,
                        message: post.text,
                        likes: post.likes,
                        onLikeTap: () {},
                        onReplyTap: () {},
                        onDislikeTap: () {},
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                FoodLogComposer(
                  controller: _composerController,
                  onPost: _handlePost,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FoodLogPost {
  final String name;
  final String timeAgo;
  final String avatarUrl;
  final String text;
  final int likes;

  const _FoodLogPost({
    required this.name,
    required this.timeAgo,
    required this.avatarUrl,
    required this.text,
    required this.likes,
  });
}
