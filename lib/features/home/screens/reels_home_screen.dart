import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:fitness_app/features/home/models/reel_item.dart';
import 'package:fitness_app/features/home/screens/reels_watch_screen.dart';
import 'package:fitness_app/features/home/screens/user_video_feed_screen.dart';
import 'package:fitness_app/features/home/controllers/user_video_controller.dart';
import 'package:fitness_app/features/home/widgets/user_profile_sheet.dart';
import 'package:fitness_app/layout/main_layout.dart';

class ReelsHomeScreen extends StatelessWidget {
  const ReelsHomeScreen({super.key});

  static final List<ReelItem> _items = <ReelItem>[
    ReelItem(
      id: 'r1',
      userId: 'u1',
      userName: 'Areeba Malik',
      userHandle: '@areeba.fit',
      profileImage:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
      previewImage:
          'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=600',
      ageText: '1 day ago',
      createdAt: DateTime(2026, 3, 5, 10, 20),
      description: 'The most satisfying exercise flow',
      hashtags: <String>['fyp', 'fitness', 'road'],
      likeCount: 328000,
      dislikeCount: 58,
      favoriteCount: 578,
    ),
    ReelItem(
      id: 'r2',
      userId: 'u2',
      userName: 'Hassan Ali',
      userHandle: '@hassan.lifts',
      profileImage:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
      previewImage:
          'https://images.unsplash.com/photo-1549060279-7e168fcee0c2?w=600',
      ageText: '2 days ago',
      createdAt: DateTime(2026, 3, 4, 14, 5),
      description: 'Chest + triceps burnout session',
      hashtags: <String>['gym', 'pushday'],
      likeCount: 24900,
      dislikeCount: 14,
      favoriteCount: 910,
    ),
    ReelItem(
      id: 'r3',
      userId: 'u3',
      userName: 'Sana Noor',
      userHandle: '@sana.moves',
      profileImage:
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200',
      previewImage:
          'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=600',
      ageText: '3 days ago',
      createdAt: DateTime(2026, 3, 3, 11, 40),
      description: 'Mobility drills for strong legs',
      hashtags: <String>['mobility', 'legday'],
      likeCount: 17200,
      dislikeCount: 11,
      favoriteCount: 430,
    ),
    ReelItem(
      id: 'r4',
      userId: 'u4',
      userName: 'Usman Khan',
      userHandle: '@usman.train',
      profileImage:
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200',
      previewImage:
          'https://images.unsplash.com/photo-1534258936925-c58bed479fcb?w=600',
      ageText: '5 days ago',
      createdAt: DateTime(2026, 3, 1, 9, 25),
      description: 'No excuses morning cardio',
      hashtags: <String>['discipline', 'cardio'],
      likeCount: 8300,
      dislikeCount: 6,
      favoriteCount: 213,
    ),
    ReelItem(
      id: 'r5',
      userId: 'u5',
      userName: 'Iqra Ahmed',
      userHandle: '@iqra.core',
      profileImage:
          'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=200',
      previewImage:
          'https://images.unsplash.com/photo-1574680178050-55c6a6a96e0a?w=600',
      ageText: '1 week ago',
      createdAt: DateTime(2026, 2, 27, 19, 10),
      description: 'Core stability workout for beginners',
      hashtags: <String>['core', 'beginner'],
      likeCount: 5600,
      dislikeCount: 5,
      favoriteCount: 198,
    ),
    ReelItem(
      id: 'r6',
      userId: 'u6',
      userName: 'Bilal Raza',
      userHandle: '@bilal.endure',
      profileImage:
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=200',
      previewImage:
          'https://images.unsplash.com/photo-1434682881908-b43d0467b798?w=600',
      ageText: '2 weeks ago',
      createdAt: DateTime(2026, 2, 22, 7, 45),
      description: '10KM prep run motivation',
      hashtags: <String>['running', 'endurance'],
      likeCount: 3100,
      dislikeCount: 4,
      favoriteCount: 160,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final items = List<ReelItem>.from(_items)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return MainLayout(
      title: 'Reels',
      currentIndex: -1,
      constrainBody: false,
      useScreenPadding: false,
      body: Container(
        color: Colors.white,
        child: SafeArea(
          top: true,
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final contentWidth = math.min(390.0, constraints.maxWidth);
              final searchWidth = math.min(335.0, contentWidth - 24);

              return Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: contentWidth,
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                        child: Container(
                          width: contentWidth,
                          height: 110,
                          color: Colors.black,
                          alignment: Alignment.center,
                          child: Container(
                            width: searchWidth,
                            height: 47,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const TextField(
                              textInputAction: TextInputAction.search,
                              decoration: InputDecoration(
                                hintText: 'Search by user, video, hashtag',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                suffixIcon: Icon(Icons.search, size: 20),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                          child: _StaggeredReels(items: items),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StaggeredReels extends StatelessWidget {
  final List<ReelItem> items;

  const _StaggeredReels({required this.items});

  @override
  Widget build(BuildContext context) {
    final left = <_IndexedReel>[];
    final right = <_IndexedReel>[];
    for (var i = 0; i < items.length; i++) {
      if (i.isEven) {
        left.add(_IndexedReel(index: i, item: items[i]));
      } else {
        right.add(_IndexedReel(index: i, item: items[i]));
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              for (final entry in left) ...[
                _ReelCard(
                  item: entry.item,
                  onTap: () => Get.to(
                    () => ReelsWatchScreen(
                      items: items,
                      initialIndex: entry.index,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 42),
            child: Column(
              children: [
                for (final entry in right) ...[
                  _ReelCard(
                    item: entry.item,
                    onTap: () => Get.to(
                      () => ReelsWatchScreen(
                        items: items,
                        initialIndex: entry.index,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ReelCard extends StatelessWidget {
  final ReelItem item;
  final VoidCallback onTap;

  const _ReelCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 165,
        height: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(
            image: NetworkImage(item.previewImage),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x12000000),
                Color(0x22000000),
                Color(0x88000000),
              ],
            ),
          ),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => showUserProfileSheet(
                    context,
                    userId: item.userId,
                    name: item.userName,
                    handle: item.userHandle,
                    avatarUrl: item.profileImage,
                  ),
                  child: CircleAvatar(
                    radius: 15,
                    backgroundImage: NetworkImage(item.profileImage),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => showUserProfileSheet(
                      context,
                      userId: item.userId,
                      name: item.userName,
                      handle: item.userHandle,
                      avatarUrl: item.profileImage,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.userName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.ageText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFFE0E0E0),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IndexedReel {
  final int index;
  final ReelItem item;

  const _IndexedReel({required this.index, required this.item});
}
