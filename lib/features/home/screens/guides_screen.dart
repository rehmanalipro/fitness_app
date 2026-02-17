import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:fitness_app/core/widgets/fallback_network_image.dart';
import 'package:fitness_app/features/home/controllers/home_profile_controller.dart';
import 'package:fitness_app/layout/main_layout.dart';
import 'package:fitness_app/routes/app_routes.dart';

class GuidesScreen extends StatefulWidget {
  const GuidesScreen({super.key});

  @override
  State<GuidesScreen> createState() => _GuidesScreenState();
}

class _GuidesScreenState extends State<GuidesScreen> {
  int _topTabIndex = 2;
  int _chatFilterIndex = 0;

  final List<_ChatPost> _foodPosts = [
    _ChatPost(
      message:
          "Hey! My body weight is increasing. I'm gaining weight and want some suggestions.",
      timeAgo: '14 min',
      likes: 2,
      replies: ['Start with a light calorie deficit and track protein daily.'],
    ),
    _ChatPost(
      message:
          'I completed 8k steps and full-body workout today. Any post-workout meal ideas?',
      timeAgo: '9 min',
      likes: 4,
      replies: ['Great work. Try eggs + toast + fruit for recovery.'],
    ),
    _ChatPost(
      message:
          'New update: I reduced sugar drinks this week and feel better already.',
      timeAgo: '3 min',
      likes: 1,
      replies: [
        'Nice progress. Keep hydration 2.5L+ and maintain consistency.',
      ],
    ),
  ];

  late final HomeProfileController _profileController;

  @override
  void initState() {
    super.initState();
    _profileController = Get.isRegistered<HomeProfileController>()
        ? Get.find<HomeProfileController>()
        : Get.put(HomeProfileController(), permanent: true);
  }

  Future<void> _openReplyDialog(int index) async {
    final inputController = TextEditingController();
    final reply = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reply'),
          content: TextField(
            controller: inputController,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(hintText: 'Write your reply'),
            onSubmitted: (_) => Navigator.of(context).pop(inputController.text),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(inputController.text),
              child: const Text('Post'),
            ),
          ],
        );
      },
    );

    final trimmed = reply?.trim();
    if (trimmed == null || trimmed.isEmpty) return;

    setState(() {
      _foodPosts[index].replies.add(trimmed);
    });
  }

  void _increaseLikes(int index) {
    setState(() {
      _foodPosts[index].likes += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Guides',
      showAppBar: true,
      showBackButton: true,
      currentIndex: 4,
      constrainBody: false,
      body: Container(
        color: const Color(0xFFF5F5F5),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final contentMaxWidth = width >= 1024 ? 760.0 : 520.0;
            final sidePadding = width >= 768 ? 24.0 : 18.0;
            final tabWidth = math.min(
              345.0,
              contentMaxWidth - (sidePadding * 2),
            );

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentMaxWidth),
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: 24 + MediaQuery.of(context).padding.bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: sidePadding),
                        child: SizedBox(
                          width: tabWidth,
                          height: 40,
                          child: _GuideTabs(
                            tabs: const ['For You', 'Explore', 'Chat'],
                            selectedIndex: _topTabIndex,
                            onTap: (index) {
                              setState(() {
                                _topTabIndex = index;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_topTabIndex == 0)
                        _ForYouSection(sidePadding: sidePadding)
                      else if (_topTabIndex == 2)
                        _ChatSection(
                          sidePadding: sidePadding,
                          tabWidth: tabWidth,
                          chatFilterIndex: _chatFilterIndex,
                          onFoodTap: () {
                            setState(() {
                              _chatFilterIndex = 0;
                            });
                          },
                          onChallengeTap: () {
                            setState(() {
                              _chatFilterIndex = 1;
                            });
                            Get.toNamed(AppRoutes.challenges);
                          },
                          profileController: _profileController,
                          posts: _foodPosts,
                          onLikeTap: _increaseLikes,
                          onReplyTap: _openReplyDialog,
                        )
                      else
                        _GuidePlaceholder(
                          title: 'Explore Feed',
                          message:
                              'Switch to For You for media content and Chat for community posts.',
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ChatSection extends StatelessWidget {
  final double sidePadding;
  final double tabWidth;
  final int chatFilterIndex;
  final VoidCallback onFoodTap;
  final VoidCallback onChallengeTap;
  final HomeProfileController profileController;
  final List<_ChatPost> posts;
  final ValueChanged<int> onLikeTap;
  final ValueChanged<int> onReplyTap;

  const _ChatSection({
    required this.sidePadding,
    required this.tabWidth,
    required this.chatFilterIndex,
    required this.onFoodTap,
    required this.onChallengeTap,
    required this.profileController,
    required this.posts,
    required this.onLikeTap,
    required this.onReplyTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sidePadding),
      child: Column(
        children: [
          SizedBox(
            width: tabWidth,
            height: 40,
            child: _GuideTabs(
              tabs: const ['Food', 'Challenges'],
              selectedIndex: chatFilterIndex,
              onTap: (index) {
                if (index == 0) {
                  onFoodTap();
                  return;
                }
                onChallengeTap();
              },
            ),
          ),
          const SizedBox(height: 24),
          if (chatFilterIndex == 0)
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 354.21),
                child: Column(
                  children: List.generate(posts.length, (index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == posts.length - 1 ? 0 : 30,
                      ),
                      child: _FoodPostCard(
                        index: index,
                        post: posts[index],
                        profileController: profileController,
                        onLikeTap: () => onLikeTap(index),
                        onReplyTap: () => onReplyTap(index),
                      ),
                    );
                  }),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FoodPostCard extends StatelessWidget {
  final int index;
  final _ChatPost post;
  final HomeProfileController profileController;
  final VoidCallback onLikeTap;
  final VoidCallback onReplyTap;

  const _FoodPostCard({
    required this.index,
    required this.post,
    required this.profileController,
    required this.onLikeTap,
    required this.onReplyTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Obx(
                () => CircleAvatar(
                  radius: 12,
                  backgroundImage: profileController.avatarProvider,
                  backgroundColor: const Color(0xFFEAEAEA),
                  child: profileController.avatarProvider == null
                      ? const Icon(
                          Icons.person,
                          size: 14,
                          color: Colors.black54,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    Obx(
                      () => Text(
                        profileController.displayName.value,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      post.timeAgo,
                      style: const TextStyle(
                        color: Color(0xFF9A9A9A),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            post.message,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 15,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                '${post.likes} Likes',
                style: const TextStyle(color: Color(0xFF6F6F6F), fontSize: 12),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: onReplyTap,
                child: const Text(
                  'Reply',
                  style: TextStyle(
                    color: Color(0xFF1F1F1F),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: onLikeTap,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.thumb_up_alt_outlined, size: 18),
                ),
              ),
            ],
          ),
          if (post.replies.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            ...post.replies.map(
              (reply) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '- $reply',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF555555),
                    height: 1.25,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ForYouSection extends StatelessWidget {
  final double sidePadding;

  const _ForYouSection({required this.sidePadding});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sidePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _SectionHeader(title: 'Recommended Meal', onViewAllTap: () {}),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: const [
                FallbackNetworkImage(
                  imageUrl:
                      'https://images.pexels.com/photos/376464/pexels-photo-376464.jpeg',
                  width: double.infinity,
                  height: 170,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: _MealOverlay(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _SectionHeader(title: 'Workout Videos', onViewAllTap: () {}),
          const SizedBox(height: 10),
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _videoItems.length,
              separatorBuilder: (_, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final item = _videoItems[index];
                return SizedBox(width: 220, child: _VideoCard(item: item));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onViewAllTap;

  const _SectionHeader({required this.title, required this.onViewAllTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF343434),
          ),
        ),
        GestureDetector(
          onTap: onViewAllTap,
          child: const Text(
            'View all',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF9A9A9A),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _MealOverlay extends StatelessWidget {
  const _MealOverlay();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Nut Butter Toast With Boiled Eggs',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 4),
        Text('164 kcal', style: TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}

class _VideoCard extends StatelessWidget {
  final _GuideVideoItem item;

  const _VideoCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEAEAEA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: Stack(
              alignment: Alignment.center,
              children: [
                FallbackNetworkImage(
                  imageUrl: item.thumbnailUrl,
                  width: double.infinity,
                  height: 120,
                  fit: BoxFit.cover,
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow, color: Colors.white),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
            child: Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              item.duration,
              style: const TextStyle(fontSize: 11, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}

const List<_GuideVideoItem> _videoItems = [
  _GuideVideoItem(
    title: 'Beginner Home Workout',
    duration: '12 min',
    thumbnailUrl:
        'https://images.pexels.com/photos/414029/pexels-photo-414029.jpeg',
  ),
  _GuideVideoItem(
    title: 'Fat Burn Cardio',
    duration: '18 min',
    thumbnailUrl:
        'https://images.pexels.com/photos/3764011/pexels-photo-3764011.jpeg',
  ),
  _GuideVideoItem(
    title: 'Core Strength Routine',
    duration: '15 min',
    thumbnailUrl:
        'https://images.pexels.com/photos/3076509/pexels-photo-3076509.jpeg',
  ),
];

class _GuideVideoItem {
  final String title;
  final String duration;
  final String thumbnailUrl;

  const _GuideVideoItem({
    required this.title,
    required this.duration,
    required this.thumbnailUrl,
  });
}

class _GuidePlaceholder extends StatelessWidget {
  final String title;
  final String message;

  const _GuidePlaceholder({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE9E9E9)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideTabs extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _GuideTabs({
    required this.tabs,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = index == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _ChatPost {
  final String message;
  final String timeAgo;
  int likes;
  final List<String> replies;

  _ChatPost({
    required this.message,
    required this.timeAgo,
    required this.likes,
    required this.replies,
  });
}
