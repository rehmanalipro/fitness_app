import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import 'package:fitness_app/features/home/controllers/user_video_controller.dart';
import 'package:fitness_app/features/home/controllers/home_profile_controller.dart';
import 'package:fitness_app/features/home/models/user_video_item.dart';
import 'package:fitness_app/features/home/services/app_api_service.dart';

class UserVideoFeedScreen extends StatefulWidget {
  final int initialIndex;

  const UserVideoFeedScreen({super.key, this.initialIndex = 0});

  @override
  State<UserVideoFeedScreen> createState() => _UserVideoFeedScreenState();
}

class _UserVideoFeedScreenState extends State<UserVideoFeedScreen> {
  late final PageController _pageCtrl;
  late final UserVideoController _ctrl;
  late final HomeProfileController _profileCtrl;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _currentIndex = widget.initialIndex;
    _pageCtrl = PageController(initialPage: _currentIndex);
    _ctrl = Get.isRegistered<UserVideoController>()
        ? Get.find<UserVideoController>()
        : Get.put(UserVideoController(), permanent: true);
    _profileCtrl = Get.isRegistered<HomeProfileController>()
        ? Get.find<HomeProfileController>()
        : Get.put(HomeProfileController(), permanent: true);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        final videos = _ctrl.videos;
        if (videos.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => _ctrl.loadShorts(),
            child: ListView(
              children: const [
                SizedBox(height: 200),
                Center(
                  child: Text('No videos yet.\nPost a video using the + button.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white54, fontSize: 14)),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () => _ctrl.loadShorts(),
          child: PageView.builder(
          controller: _pageCtrl,
          scrollDirection: Axis.vertical,
          itemCount: videos.length,
          onPageChanged: (i) => setState(() => _currentIndex = i),
          itemBuilder: (context, index) {
            final video = videos[index];
            return _VideoSlide(
              video: video,
              isActive: index == _currentIndex,
              profileCtrl: _profileCtrl,
              onLike: () => _ctrl.toggleLike(video.id),
              onDislike: () => _ctrl.toggleDislike(video.id),
              onFavorite: () => _ctrl.toggleFavorite(video.id),
              onFollow: () => _ctrl.toggleFollow(video.id),
              onComment: () => _openComments(video),
              onShare: () => _share(video),
              onReport: () => _report(video),
            );
          },
        ),
        );
      }),
    );
  }

  void _openComments(UserVideoItem video) {
    final inputCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: SizedBox(
              height: 460,
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Container(width: 36, height: 4,
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 12),
                  Obx(() {
                    final v = _ctrl.videos.firstWhereOrNull((e) => e.id == video.id);
                    return Text('${v?.comments.length ?? 0} Comments',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15));
                  }),
                  const Divider(color: Colors.white12),
                  Expanded(
                    child: Obx(() {
                      final v = _ctrl.videos.firstWhereOrNull((e) => e.id == video.id);
                      final comments = v?.comments ?? [];
                      if (comments.isEmpty) {
                        return const Center(child: Text('No comments yet',
                            style: TextStyle(color: Colors.white54)));
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: comments.length,
                        itemBuilder: (_, i) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const CircleAvatar(radius: 14, backgroundColor: Color(0xFF333333),
                                  child: Icon(Icons.person, size: 14, color: Colors.white54)),
                              const SizedBox(width: 10),
                              Expanded(child: Text(comments[i],
                                  style: const TextStyle(color: Colors.white, fontSize: 13))),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: inputCtrl,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Add a comment...',
                              hintStyle: const TextStyle(color: Colors.white38),
                              filled: true,
                              fillColor: const Color(0xFF2A2A2A),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            final text = inputCtrl.text.trim();
                            if (text.isEmpty) return;
                            _ctrl.addComment(video.id, text);
                            inputCtrl.clear();
                            setSheet(() {});
                          },
                          child: Container(
                            width: 40, height: 40,
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: const Icon(Icons.send, size: 18, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _share(UserVideoItem video) {
    Get.snackbar('Share', 'Share feature coming soon',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87, colorText: Colors.white);
  }

  void _report(UserVideoItem video) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(width: 36, height: 4,
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 12),
            const Text('Report', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            _ReportTile('Inappropriate content', Icons.warning_amber_outlined, videoId: video.id, reason: 'inappropriate_content'),
            _ReportTile('Spam', Icons.block_outlined, videoId: video.id, reason: 'spam'),
            _ReportTile('Misleading information', Icons.info_outline, videoId: video.id, reason: 'misleading'),
            _ReportTile('Other', Icons.more_horiz, videoId: video.id, reason: 'other'),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── Single Video Slide ────────────────────────────────────────────────────
class _VideoSlide extends StatefulWidget {
  final UserVideoItem video;
  final bool isActive;
  final HomeProfileController profileCtrl;
  final VoidCallback onLike;
  final VoidCallback onDislike;
  final VoidCallback onFavorite;
  final VoidCallback onFollow;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onReport;

  const _VideoSlide({
    required this.video,
    required this.isActive,
    required this.profileCtrl,
    required this.onLike,
    required this.onDislike,
    required this.onFavorite,
    required this.onFollow,
    required this.onComment,
    required this.onShare,
    required this.onReport,
  });

  @override
  State<_VideoSlide> createState() => _VideoSlideState();
}

class _VideoSlideState extends State<_VideoSlide> {
  VideoPlayerController? _vpc;
  bool _initialized = false;
  bool _showPauseIcon = false;

  @override
  void initState() {
    super.initState();
    if (widget.isActive) _initVideo();
  }

  @override
  void didUpdateWidget(_VideoSlide old) {
    super.didUpdateWidget(old);
    if (widget.isActive && !old.isActive) {
      _initVideo();
    } else if (!widget.isActive && old.isActive) {
      _vpc?.pause();
    }
  }

  Future<void> _initVideo() async {
    if (_vpc != null) { _vpc!.play(); return; }
    final path = widget.video.videoPath;
    final url = widget.video.videoUrl;
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

  void _togglePlay() {
    if (_vpc == null) return;
    if (_vpc!.value.isPlaying) {
      _vpc!.pause();
      setState(() => _showPauseIcon = true);
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) setState(() => _showPauseIcon = false);
      });
    } else {
      _vpc!.play();
      setState(() => _showPauseIcon = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final video = widget.video;
    final ctrl = Get.find<UserVideoController>();

    return GestureDetector(
      onTap: _togglePlay,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Video ────────────────────────────────────────────────────
          _initialized && _vpc != null
              ? Center(
                  child: AspectRatio(
                    aspectRatio: _vpc!.value.aspectRatio,
                    child: VideoPlayer(_vpc!),
                  ),
                )
              : const Center(child: CircularProgressIndicator(color: Colors.white)),

          // ── Gradient ─────────────────────────────────────────────────
          const Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x55000000), Colors.transparent, Color(0xCC000000)],
                    stops: [0.0, 0.35, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // ── Pause icon flash ─────────────────────────────────────────
          if (_showPauseIcon)
            const Center(
              child: Icon(Icons.pause_circle_filled, color: Colors.white54, size: 80),
            ),

          // ── Back button ───────────────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            ),
          ),

          // ── Bottom left: user info + description ──────────────────────
          Positioned(
            left: 14, right: 70, bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // User row
                    Row(
                      children: [
                        _Avatar(video: video, profileCtrl: widget.profileCtrl),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(video.userName,
                                  style: const TextStyle(color: Colors.white,
                                      fontWeight: FontWeight.w700, fontSize: 15)),
                              Text(video.normalizedHandle,
                                  style: const TextStyle(color: Colors.white60, fontSize: 12)),
                            ],
                          ),
                        ),
                        // Follow button
                        if (!video.isMine)
                          Obx(() {
                            final v = ctrl.videos.firstWhereOrNull((e) => e.id == video.id);
                            final following = v?.isFollowing ?? false;
                            return GestureDetector(
                              onTap: widget.onFollow,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  border: Border.all(color: following ? Colors.white54 : Colors.white),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(following ? 'Following' : 'Follow',
                                    style: const TextStyle(color: Colors.white,
                                        fontSize: 12, fontWeight: FontWeight.w700)),
                              ),
                            );
                          }),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Caption + hashtags
                    if (video.descriptionWithTags.isNotEmpty)
                      Text(video.descriptionWithTags,
                          maxLines: 3, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.3)),
                    const SizedBox(height: 4),
                    Text(video.timeAgo,
                        style: const TextStyle(color: Colors.white54, fontSize: 11)),
                  ],
                ),
              ),
            ),
          ),

          // ── Right side action buttons ─────────────────────────────────
          Positioned(
            right: 10,
            bottom: MediaQuery.of(context).padding.bottom + 80,
            child: Obx(() {
              final v = ctrl.videos.firstWhereOrNull((e) => e.id == video.id);
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Like
                  _ActionBtn(
                    icon: (v?.isLiked ?? false) ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
                    label: ctrl.formatCount(v?.likeCount ?? 0),
                    active: v?.isLiked ?? false,
                    onTap: widget.onLike,
                  ),
                  const SizedBox(height: 22),
                  // Dislike
                  _ActionBtn(
                    icon: (v?.isDisliked ?? false) ? Icons.thumb_down_alt : Icons.thumb_down_alt_outlined,
                    label: ctrl.formatCount(v?.dislikeCount ?? 0),
                    active: v?.isDisliked ?? false,
                    onTap: widget.onDislike,
                  ),
                  const SizedBox(height: 22),
                  // Comment
                  _ActionBtn(
                    icon: Icons.comment_outlined,
                    label: ctrl.formatCount(v?.commentCount ?? 0),
                    onTap: widget.onComment,
                  ),
                  const SizedBox(height: 22),
                  // Favourite / Save
                  _ActionBtn(
                    icon: (v?.isFavorite ?? false) ? Icons.bookmark : Icons.bookmark_border,
                    label: ctrl.formatCount(v?.favoriteCount ?? 0),
                    active: v?.isFavorite ?? false,
                    onTap: widget.onFavorite,
                  ),
                  const SizedBox(height: 22),
                  // Share
                  _ActionBtn(
                    icon: Icons.share_outlined,
                    label: 'Share',
                    onTap: widget.onShare,
                  ),
                  const SizedBox(height: 22),
                  // Report
                  _ActionBtn(
                    icon: Icons.flag_outlined,
                    label: 'Report',
                    onTap: widget.onReport,
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Avatar ────────────────────────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  final UserVideoItem video;
  final HomeProfileController profileCtrl;
  const _Avatar({required this.video, required this.profileCtrl});

  @override
  Widget build(BuildContext context) {
    if (video.isMine) {
      return Obx(() => CircleAvatar(
        radius: 18,
        backgroundImage: profileCtrl.avatarProvider,
        backgroundColor: const Color(0xFF333333),
      ));
    }
    if (video.profileImageUrl != null && video.profileImageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 18,
        backgroundImage: NetworkImage(video.profileImageUrl!),
        backgroundColor: const Color(0xFF333333),
      );
    }
    if (video.profileImageBytes != null) {
      return CircleAvatar(
        radius: 18,
        backgroundImage: MemoryImage(video.profileImageBytes!),
        backgroundColor: const Color(0xFF333333),
      );
    }
    return const CircleAvatar(
      radius: 18, backgroundColor: Color(0xFF333333),
      child: Icon(Icons.person, size: 18, color: Colors.white54),
    );
  }
}

// ── Action Button ─────────────────────────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;
  const _ActionBtn({required this.icon, required this.label, this.active = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 30, color: active ? const Color(0xFFFF4D6D) : Colors.white),
          const SizedBox(height: 3),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ── Report Tile ───────────────────────────────────────────────────────────
class _ReportTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final String videoId;
  final String reason;
  const _ReportTile(this.label, this.icon, {required this.videoId, required this.reason});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Get.back();
        AppApiService().report(targetId: videoId, targetType: 'reel', reason: reason).catchError((_) {});
        Get.snackbar('Reported', 'Thank you for your report',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.black87, colorText: Colors.white);
      },
    );
  }
}
