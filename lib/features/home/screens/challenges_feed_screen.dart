import 'dart:io';
import 'dart:math' as math;

import 'package:fitness_app/features/home/controllers/challenges_feed_controller.dart';
import 'package:fitness_app/features/home/controllers/home_profile_controller.dart';
import 'package:fitness_app/features/home/screens/challenge_video_screen.dart';
import 'package:fitness_app/layout/main_layout.dart';
import 'package:fitness_app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class ChallengesFeedScreen extends StatefulWidget {
  const ChallengesFeedScreen({super.key});

  @override
  State<ChallengesFeedScreen> createState() => _ChallengesFeedScreenState();
}

class _ChallengesFeedScreenState extends State<ChallengesFeedScreen> {
  int _tabIndex = 0;
  late final ChallengesFeedController _controller;
  late final HomeProfileController _profileController;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<ChallengesFeedController>()
        ? Get.find<ChallengesFeedController>()
        : Get.put(ChallengesFeedController(), permanent: true);
    _profileController = Get.isRegistered<HomeProfileController>()
        ? Get.find<HomeProfileController>()
        : Get.put(HomeProfileController(), permanent: true);
  }

  void _onAccept(ChallengesFeedController controller, String postId) {
    final post = controller.findById(postId);
    if (post == null) return;
    if (post.accepted) {
      Get.snackbar('Already Accepted', 'You already accepted this challenge',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black54,
          colorText: Colors.white,
          duration: const Duration(seconds: 2));
      return;
    }
    controller.acceptPost(postId);
    Get.snackbar('Challenge Accepted! 🎯', '+10 points earned',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
        duration: const Duration(seconds: 2));
  }

  Future<void> _openReplyDialog(String postId) async {
    final inputController = TextEditingController();
    final reply = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Comment'),
        content: TextField(
          controller: inputController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Write your comment...'),
          onSubmitted: (_) => Navigator.of(ctx).pop(inputController.text),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(inputController.text),
            child: const Text('Post'),
          ),
        ],
      ),
    );
    final text = reply?.trim();
    if (text == null || text.isEmpty) return;
    _controller.addReply(postId, text);
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Challenges',
      showAppBar: true,
      showBackButton: true,
      currentIndex: 2,
      constrainBody: false,
      body: Container(
        color: const Color(0xFFF5F5F5),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final sidePadding = width >= 768 ? 24.0 : 18.0;
            final contentMaxWidth = width >= 1024 ? 760.0 : 520.0;
            final tabWidth = math.min(345.0, contentMaxWidth - sidePadding * 2);

            return GetBuilder<ChallengesFeedController>(
              builder: (controller) {
                final posts = _tabIndex == 0 ? controller.publicPosts : controller.myPosts;

                return Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: contentMaxWidth),
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            const SizedBox(height: 12),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: sidePadding),
                              child: SizedBox(
                                width: tabWidth,
                                height: 40,
                                child: _ChallengeTabs(
                                  selectedIndex: _tabIndex,
                                  onTap: (i) => setState(() => _tabIndex = i),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: controller.isLoadingPublic && _tabIndex == 0
                                  ? const Center(child: CircularProgressIndicator())
                                  : posts.isEmpty
                                  ? _EmptyState(showHint: _tabIndex == 1)
                                  : RefreshIndicator(
                                      onRefresh: () => controller.loadPublicChallenges(),
                                      child: ListView.separated(
                                      padding: EdgeInsets.only(
                                        left: sidePadding,
                                        right: sidePadding,
                                        bottom: 100 + MediaQuery.of(context).padding.bottom,
                                      ),
                                      itemCount: posts.length,
                                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                                      itemBuilder: (context, index) {
                                        final post = posts[index];
                                        if (post.hasVideo) {
                                          return _VideoCard(
                                            post: post,
                                            profileController: _profileController,
                                            onLike: () => controller.likePost(post.id),
                                            onDislike: () => controller.dislikePost(post.id),
                                            onComment: () => _openReplyDialog(post.id),
                                            onAccept: () => _onAccept(controller, post.id),
                                            onTap: () => Get.to(() => ChallengeVideoScreen(post: post)),
                                          );
                                        }
                                        return _ChallengeCard(
                                          post: post,
                                          profileController: _profileController,
                                          onOpenDetail: () => Get.toNamed(
                                            AppRoutes.challengePostDetail,
                                            arguments: post.id,
                                          ),
                                          onLike: () => controller.likePost(post.id),
                                          onDislike: () => controller.dislikePost(post.id),
                                          onComment: () => _openReplyDialog(post.id),
                                          onAccept: () => _onAccept(controller, post.id),
                                        );
                                      },
                                    ),
                                  ),
                            ),
                          ],
                        ),
                        if (_tabIndex == 1)
                          Positioned(
                            right: sidePadding,
                            bottom: 18 + MediaQuery.of(context).padding.bottom,
                            child: InkWell(
                              onTap: () async {
                                final result = await Get.toNamed(AppRoutes.addChallengePost);
                                if (result == true) setState(() {});
                              },
                              borderRadius: BorderRadius.circular(19),
                              child: Container(
                                width: 38, height: 38,
                                decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                                child: const Icon(Icons.add, color: Colors.white, size: 20),
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
        ),
      ),
    );
  }
}

// ── TikTok-style Video Card ───────────────────────────────────────────────
class _VideoCard extends StatefulWidget {
  final ChallengePost post;
  final HomeProfileController profileController;
  final VoidCallback onLike;
  final VoidCallback onDislike;
  final VoidCallback onComment;
  final VoidCallback onAccept;
  final VoidCallback? onTap;

  const _VideoCard({
    required this.post,
    required this.profileController,
    required this.onLike,
    required this.onDislike,
    required this.onComment,
    required this.onAccept,
    this.onTap,
  });

  @override
  State<_VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<_VideoCard> {
  VideoPlayerController? _vpc;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    final path = widget.post.videoPath;
    final url = widget.post.videoUrl;
    VideoPlayerController vpc;
    if (path != null && path.isNotEmpty) {
      vpc = VideoPlayerController.file(File(path));
    } else if (url != null && url.isNotEmpty) {
      vpc = VideoPlayerController.networkUrl(Uri.parse(url));
    } else {
      return;
    }
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

  void _togglePlay() {
    if (_vpc == null) return;
    setState(() {
      _vpc!.value.isPlaying ? _vpc!.pause() : _vpc!.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Video player
          AspectRatio(
            aspectRatio: _initialized ? _vpc!.value.aspectRatio : 9 / 16,
            child: _initialized
                ? GestureDetector(
                    onTap: _togglePlay,
                    onDoubleTap: widget.onTap,
                    child: VideoPlayer(_vpc!))
                : const Center(child: CircularProgressIndicator(color: Colors.white)),
          ),

          // Tap to open fullscreen overlay
          if (_initialized)
            Positioned.fill(
              child: GestureDetector(
                onDoubleTap: widget.onTap,
                behavior: HitTestBehavior.translucent,
                child: const SizedBox.expand(),
              ),
            ),

          // Top-right expand button
          Positioned(
            top: 8, right: 8,
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.fullscreen, color: Colors.white, size: 20),
              ),
            ),
          ),

          // Play/pause overlay
          if (_initialized && !_vpc!.value.isPlaying)
            Positioned.fill(
              child: GestureDetector(
                onTap: _togglePlay,
                child: const Center(
                  child: Icon(Icons.play_circle_fill, color: Colors.white70, size: 64),
                ),
              ),
            ),

          // Bottom info overlay
          Positioned(
            left: 0, right: 60, bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(12),
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
                  Row(
                    children: [
                      _PostAvatar(post: widget.post, profileController: widget.profileController),
                      const SizedBox(width: 8),
                      Text(widget.post.author,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(width: 6),
                      Text(widget.post.timeAgo,
                          style: const TextStyle(color: Colors.white60, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(widget.post.title,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      _Badge(widget.post.category),
                      const SizedBox(width: 6),
                      _Badge(widget.post.fitnessLevel),
                    ],
                  ),
                  if (widget.post.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(widget.post.description,
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ],
              ),
            ),
          ),

          // Right side action buttons
          Positioned(
            right: 8, bottom: 12,
            child: Column(
              children: [
                _ActionBtn(
                  icon: widget.post.isLiked ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
                  label: '${widget.post.likes}',
                  color: widget.post.isLiked ? Colors.white : Colors.white70,
                  onTap: widget.onLike,
                ),
                const SizedBox(height: 16),
                _ActionBtn(
                  icon: Icons.comment_outlined,
                  label: '${widget.post.replies.length}',
                  color: Colors.white70,
                  onTap: widget.onComment,
                ),
                const SizedBox(height: 16),
                _ActionBtn(
                  icon: widget.post.accepted ? Icons.check_circle : Icons.check_circle_outline,
                  label: widget.post.accepted ? 'Done' : 'Accept',
                  color: widget.post.accepted ? Colors.greenAccent : Colors.white70,
                  onTap: widget.onAccept,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: color, fontSize: 11)),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  const _Badge(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 10)),
    );
  }
}

// ── Regular Challenge Card ────────────────────────────────────────────────
class _ChallengeCard extends StatelessWidget {
  final ChallengePost post;
  final HomeProfileController profileController;
  final VoidCallback onOpenDetail;
  final VoidCallback onLike;
  final VoidCallback onDislike;
  final VoidCallback onComment;
  final VoidCallback onAccept;

  const _ChallengeCard({
    required this.post,
    required this.profileController,
    required this.onOpenDetail,
    required this.onLike,
    required this.onDislike,
    required this.onComment,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onOpenDetail,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFEAEAEA)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _PostAvatar(post: post, profileController: profileController),
                  const SizedBox(width: 8),
                  Text(post.author,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  Text(post.timeAgo,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF9A9A9A))),
                ],
              ),
              const SizedBox(height: 8),
              if (post.imageBytes != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(post.imageBytes!,
                      height: 160, width: double.infinity, fit: BoxFit.cover),
                ),
                const SizedBox(height: 8),
              ],
              Text(post.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Wrap(spacing: 8, children: [
                _SmallBadge(post.category, const Color(0xFF81C784)),
                _SmallBadge(post.fitnessLevel, const Color(0xFF81C784)),
              ]),
              const SizedBox(height: 6),
              Text(post.target,
                  style: const TextStyle(fontSize: 14, color: Colors.black87)),
              if (post.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(post.description,
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF666666))),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('${post.likes} Likes',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF8F99AA))),
                  const SizedBox(width: 12),
                  _TextBtn(icon: Icons.comment_outlined, label: 'Comment', onTap: onComment),
                  const SizedBox(width: 12),
                  _TextBtn(
                    icon: post.accepted ? Icons.check_circle : Icons.check_circle_outline,
                    label: post.accepted ? 'Accepted' : 'Accept',
                    onTap: onAccept,
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: onLike,
                    child: Icon(
                      post.isLiked ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
                      size: 18,
                      color: post.isLiked ? Colors.black : const Color(0xFF8F99AA),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onDislike,
                    child: Icon(
                      post.isDisliked ? Icons.thumb_down_alt : Icons.thumb_down_alt_outlined,
                      size: 18,
                      color: post.isDisliked ? Colors.black : const Color(0xFF8F99AA),
                    ),
                  ),
                ],
              ),
              if (post.replies.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 8),
                ...post.replies.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('- $r',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF555555))),
                )),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallBadge extends StatelessWidget {
  final String text;
  final Color color;
  const _SmallBadge(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(fontSize: 10, color: color));
  }
}

class _TextBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _TextBtn({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 13, color: const Color(0xFF8F99AA)),
          const SizedBox(width: 3),
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF8F99AA))),
        ],
      ),
    );
  }
}

// ── Shared Avatar ─────────────────────────────────────────────────────────
class _PostAvatar extends StatelessWidget {
  final ChallengePost post;
  final HomeProfileController profileController;
  const _PostAvatar({required this.post, required this.profileController});

  @override
  Widget build(BuildContext context) {
    if (post.isMine) {
      return Obx(() => CircleAvatar(
        radius: 14,
        backgroundImage: profileController.avatarProvider,
        backgroundColor: const Color(0xFFEAEAEA),
      ));
    }
    if (post.avatarUrl != null && post.avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 14,
        backgroundImage: NetworkImage(post.avatarUrl!),
        backgroundColor: const Color(0xFFEAEAEA),
      );
    }
    return const CircleAvatar(
      radius: 14,
      backgroundColor: Color(0xFFEAEAEA),
      child: Icon(Icons.person, size: 14, color: Colors.black54),
    );
  }
}

// ── Tabs ──────────────────────────────────────────────────────────────────
class _ChallengeTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  const _ChallengeTabs({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD9D9D9)),
      ),
      child: Row(
        children: List.generate(2, (i) {
          final selected = selectedIndex == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? Colors.black : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  i == 0 ? 'Public' : 'My Post',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : Colors.black87,
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

class _EmptyState extends StatelessWidget {
  final bool showHint;
  const _EmptyState({required this.showHint});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        showHint
            ? 'No challenge posted yet.\nTap + to add your first challenge.'
            : 'No public challenges yet.',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 13, color: Colors.black45),
      ),
    );
  }
}
