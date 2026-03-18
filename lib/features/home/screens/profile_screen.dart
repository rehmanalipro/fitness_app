import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import 'package:fitness_app/features/home/controllers/challenges_feed_controller.dart';
import 'package:fitness_app/features/home/controllers/home_profile_controller.dart';
import 'package:fitness_app/features/home/controllers/user_video_controller.dart';
import 'package:fitness_app/features/home/models/user_video_item.dart';
import 'package:fitness_app/features/home/screens/challenge_video_screen.dart';
import 'package:fitness_app/features/home/screens/media_viewer_screen.dart';
import 'package:fitness_app/features/home/screens/user_video_feed_screen.dart';
import 'package:fitness_app/layout/main_layout.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final HomeProfileController _profileController;
  late final ChallengesFeedController _challengesController;
  int _tabIndex = 0; // 0 = Public, 1 = Likes, 2 = Challenges

  @override
  void initState() {
    super.initState();
    _profileController = Get.isRegistered<HomeProfileController>()
        ? Get.find<HomeProfileController>()
        : Get.put(HomeProfileController(), permanent: true);
    _challengesController = Get.isRegistered<ChallengesFeedController>()
        ? Get.find<ChallengesFeedController>()
        : Get.put(ChallengesFeedController(), permanent: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _profileController.loadProfileFromApi();
    });
  }

  void _showUserList({
    required String title,
    required RxList<SocialUser> users,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFDDDDDD),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Text(title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const Divider(),
            Expanded(
              child: Obx(() {
                if (users.isEmpty) {
                  return Center(
                    child: Text('No $title yet',
                        style: const TextStyle(color: Colors.black45)),
                  );
                }
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (_, i) {
                    final u = users[i];
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundImage: u.avatarUrl != null && u.avatarUrl!.isNotEmpty
                            ? NetworkImage(u.avatarUrl!) as ImageProvider
                            : null,
                        backgroundColor: const Color(0xFFEAEAEA),
                        child: u.avatarUrl == null || u.avatarUrl!.isEmpty
                            ? const Icon(Icons.person, size: 20, color: Colors.black54)
                            : null,
                      ),
                      title: Text(u.name,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: Text(u.handle,
                          style: const TextStyle(fontSize: 12, color: Colors.black45)),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openEditProfileSheet() async {
    if (!mounted) return;

    final nameCtrl = TextEditingController(
      text: _profileController.displayName.value,
    );
    final userCtrl = TextEditingController(
      text: _profileController.userName.value,
    );
    final bioCtrl = TextEditingController(text: _profileController.bio.value);
    Uint8List? selectedAvatar;
    String? selectedAvatarPath;

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
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
                          setSheetState(() {
                            selectedAvatar = bytes;
                            selectedAvatarPath = picked.path;
                          });
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
                          if (Navigator.of(sheetContext).canPop()) {
                            Navigator.of(sheetContext).pop({
                              'name': nameCtrl.text,
                              'username': userCtrl.text,
                              'bio': bioCtrl.text,
                              'avatar': selectedAvatar,
                              'avatarPath': selectedAvatarPath,
                            });
                          }
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

    if (!mounted) return;
    if (result != null) {
      final name = (result['name'] ?? '').toString();
      final username = (result['username'] ?? '').toString();
      final userBio = (result['bio'] ?? '').toString();
      final avatarPath = (result['avatarPath'] ?? '').toString();

      if (avatarPath.isNotEmpty) {
        await _profileController.uploadAvatarToApi(avatarPath);
        await _profileController.loadProfileFromApi(force: true);
      }

      final saved = await _profileController.saveProfileToApi(
        name: name,
        username: username,
        userBio: userBio,
      );
      if (!saved && mounted) {
        Get.snackbar(
          'Profile',
          _profileController.syncError.value ?? 'Profile save failed',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }

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
                : _tabIndex == 1
                    ? _profileController.likedMediaItems
                    : <UserMediaItem>[];
            final challenges = _tabIndex == 2
                ? _challengesController.myPosts
                : <ChallengePost>[];
            final likedVideos = _profileController.likedVideoItems;

            return RefreshIndicator(
              onRefresh: () async {
                await Future.wait([
                  _profileController.loadProfileFromApi(force: true),
                  _challengesController.loadPublicChallenges(),
                ]);
              },
              child: Column(
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
                    Obx(() => GestureDetector(
                      onTap: () => _showUserList(
                        title: 'Following',
                        users: _profileController.followingUsers,
                      ),
                      child: _StatItem(
                        label: 'Following',
                        value: _profileController.followingCount.value,
                      ),
                    )),
                    const SizedBox(width: 26),
                    Obx(() => GestureDetector(
                      onTap: () => _showUserList(
                        title: 'Followers',
                        users: _profileController.followerUsers,
                      ),
                      child: _StatItem(
                        label: 'Followers',
                        value: _profileController.followerCount.value,
                      ),
                    )),
                    const SizedBox(width: 26),
                    Obx(() => _StatItem(
                      label: 'Likes',
                      value: _profileController.totalLikesCount.value,
                    )),
                    const SizedBox(width: 26),
                    Obx(() => _StatItem(
                      label: 'Points',
                      value: _profileController.points.value,
                    )),
                  ],
                ),
                const SizedBox(height: 12),
                // Edit profile + Follow buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 150,
                      height: 36,
                      child: OutlinedButton(
                        onPressed: _openEditProfileSheet,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.black26),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Edit profile',
                            style: TextStyle(fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 100,
                      height: 36,
                      child: ElevatedButton(
                        onPressed: () {
                          // Simulate someone following you
                          final newFollower = SocialUser(
                            id: 'follower_${DateTime.now().millisecondsSinceEpoch}',
                            name: 'New Follower',
                            handle: '@user_${_profileController.followerCount.value + 1}',
                            avatarUrl: 'https://i.pravatar.cc/100?img=${(_profileController.followerCount.value % 70) + 1}',
                          );
                          _profileController.addFollower(newFollower);
                          Get.snackbar(
                            'New Follower',
                            '${newFollower.name} followed you!',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.black87,
                            colorText: Colors.white,
                            duration: const Duration(seconds: 2),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Follow',
                            style: TextStyle(color: Colors.white, fontSize: 13)),
                      ),
                    ),
                  ],
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
                  child: _tabIndex == 2
                      ? _ChallengesGrid(challenges: challenges)
                      : _tabIndex == 1
                          ? _LikesGrid(
                              mediaItems: _profileController.likedMediaItems,
                              videoItems: likedVideos,
                              profileController: _profileController,
                            )
                          : GridView.builder(
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
                        onTap: () =>
                            Get.to(() => MediaViewerScreen(media: media)),
                        onDoubleTap: () =>
                            _profileController.toggleLike(media.id),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (media.bytes != null)
                              Image.memory(media.bytes!, fit: BoxFit.cover)
                            else if (media.isVideo)
                              Container(
                                color: Colors.black87,
                                child: const Center(
                                  child: Icon(
                                    Icons.play_circle_fill,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                              )
                            else if ((media.localPath ?? '').isNotEmpty)
                              Image.file(
                                File(media.localPath!),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      color: const Color(0xFFE8E8E8),
                                      child: const Icon(
                                        Icons.image_not_supported,
                                      ),
                                    ),
                              )
                            else
                              Image.network(
                                media.imageUrl ?? media.mediaUrl ?? '',
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
                            if (media.caption.trim().isNotEmpty)
                              Positioned(
                                left: 6,
                                right: 6,
                                bottom: 6,
                                child: Text(
                                  media.caption,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black87,
                                        blurRadius: 3,
                                      ),
                                    ],
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
            ),
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

  String _format(int v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return '$v';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(_format(value),
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.black54)),
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
      width: 300,
      height: 34,
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFEF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _TabButton(label: 'Public', selected: selectedIndex == 0, onTap: () => onTap(0)),
          _TabButton(label: 'Likes', selected: selectedIndex == 1, onTap: () => onTap(1)),
          _TabButton(label: 'Challenges', selected: selectedIndex == 2, onTap: () => onTap(2)),
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

class _ChallengesGrid extends StatelessWidget {
  final List<ChallengePost> challenges;
  const _ChallengesGrid({required this.challenges});

  @override
  Widget build(BuildContext context) {
    if (challenges.isEmpty) {
      return const Center(
        child: Text('No challenges posted yet.',
            style: TextStyle(fontSize: 13, color: Colors.black45)),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      itemCount: challenges.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        final post = challenges[index];
        return _ChallengeGridItem(post: post);
      },
    );
  }
}

class _ChallengeGridItem extends StatefulWidget {
  final ChallengePost post;
  const _ChallengeGridItem({required this.post});

  @override
  State<_ChallengeGridItem> createState() => _ChallengeGridItemState();
}

class _ChallengeGridItemState extends State<_ChallengeGridItem> {
  VideoPlayerController? _vpc;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.post.hasVideo) _initVideo();
  }

  Future<void> _initVideo() async {
    final path = widget.post.videoPath;
    final url = widget.post.videoUrl;
    VideoPlayerController vpc;
    if (path != null && path.isNotEmpty) {
      vpc = VideoPlayerController.file(File(path));
    } else if (url != null && url.isNotEmpty) {
      vpc = VideoPlayerController.networkUrl(Uri.parse(url));
    } else return;
    await vpc.initialize();
    vpc.setLooping(true);
    vpc.play();
    if (mounted) setState(() { _vpc = vpc; _initialized = true; });
  }

  @override
  void dispose() {
    _vpc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => ChallengeVideoScreen(post: widget.post)),
      child: Container(
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Media
          if (widget.post.hasVideo && _initialized)
            FittedBox(fit: BoxFit.cover, child: SizedBox(
              width: _vpc!.value.size.width,
              height: _vpc!.value.size.height,
              child: VideoPlayer(_vpc!),
            ))
          else if (widget.post.hasVideo)
            const Center(child: Icon(Icons.play_circle_fill, color: Colors.white54, size: 40))
          else if (widget.post.imageBytes != null)
            Image.memory(widget.post.imageBytes!, fit: BoxFit.cover)
          else
            const Center(child: Icon(Icons.fitness_center, color: Colors.white54, size: 36)),

          // Overlay
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.post.title,
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(widget.post.category,
                          style: const TextStyle(color: Colors.white70, fontSize: 10)),
                      const SizedBox(width: 6),
                      const Icon(Icons.thumb_up_alt_outlined, size: 10, color: Colors.white70),
                      const SizedBox(width: 2),
                      Text('${widget.post.likes}',
                          style: const TextStyle(color: Colors.white70, fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          if (widget.post.hasVideo)
            const Positioned(
              top: 6, right: 6,
              child: Icon(Icons.videocam, color: Colors.white70, size: 16),
            ),
        ],
      ),
    ),
    );
  }
}

// ── Likes Grid — shows liked media posts + liked reel videos ──────────────
class _LikesGrid extends StatelessWidget {
  final List<UserMediaItem> mediaItems;
  final RxList<UserVideoItem> videoItems;
  final HomeProfileController profileController;

  const _LikesGrid({
    required this.mediaItems,
    required this.videoItems,
    required this.profileController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final allVideos = videoItems.toList();
      final total = mediaItems.length + allVideos.length;

      if (total == 0) {
        return const Center(
          child: Text('No liked posts yet.\nLike videos or posts to see them here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.black45)),
        );
      }

      return GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        itemCount: total,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          // First show liked media posts
          if (index < mediaItems.length) {
            final media = mediaItems[index];
            return GestureDetector(
              onTap: () => Get.to(() => MediaViewerScreen(media: media)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (media.bytes != null)
                    Image.memory(media.bytes!, fit: BoxFit.cover)
                  else if (media.isVideo)
                    Container(
                      color: Colors.black87,
                      child: const Center(
                        child: Icon(Icons.play_circle_fill, color: Colors.white, size: 36),
                      ),
                    )
                  else if ((media.localPath ?? '').isNotEmpty)
                    Image.file(File(media.localPath!), fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: const Color(0xFFE8E8E8)))
                  else
                    Image.network(media.imageUrl ?? media.mediaUrl ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: const Color(0xFFE8E8E8))),
                  const Positioned(
                    right: 6, top: 6,
                    child: Icon(Icons.favorite, color: Colors.red, size: 16),
                  ),
                ],
              ),
            );
          }

          // Then show liked reel videos
          final video = allVideos[index - mediaItems.length];
          return GestureDetector(
            onTap: () {
              final videoCtrl = Get.isRegistered<UserVideoController>()
                  ? Get.find<UserVideoController>()
                  : null;
              if (videoCtrl == null) return;
              final idx = videoCtrl.videos.indexWhere((v) => v.id == video.id);
              Get.to(() => UserVideoFeedScreen(initialIndex: idx >= 0 ? idx : 0));
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Thumbnail or black bg
                if (video.profileImageUrl != null && video.profileImageUrl!.isNotEmpty)
                  Image.network(video.profileImageUrl!, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: Colors.black87))
                else
                  Container(
                    color: Colors.black87,
                    child: const Center(
                      child: Icon(Icons.play_circle_fill, color: Colors.white54, size: 36),
                    ),
                  ),
                // Video icon
                const Positioned(
                  top: 6, right: 6,
                  child: Icon(Icons.videocam, color: Colors.white70, size: 14),
                ),
                // Like icon
                const Positioned(
                  bottom: 6, right: 6,
                  child: Icon(Icons.favorite, color: Colors.red, size: 14),
                ),
                // Caption
                if (video.caption.isNotEmpty)
                  Positioned(
                    left: 4, right: 4, bottom: 4,
                    child: Text(video.caption,
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white, fontSize: 9,
                          shadows: [Shadow(color: Colors.black87, blurRadius: 3)],
                        )),
                  ),
              ],
            ),
          );
        },
      );
    });
  }
}
