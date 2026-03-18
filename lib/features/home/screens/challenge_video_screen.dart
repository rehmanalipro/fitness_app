import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import 'package:fitness_app/features/home/controllers/challenges_feed_controller.dart';
import 'package:fitness_app/features/home/controllers/home_profile_controller.dart';

class ChallengeVideoScreen extends StatefulWidget {
  final ChallengePost post;

  const ChallengeVideoScreen({super.key, required this.post});

  @override
  State<ChallengeVideoScreen> createState() => _ChallengeVideoScreenState();
}

class _ChallengeVideoScreenState extends State<ChallengeVideoScreen> {
  VideoPlayerController? _vpc;
  bool _initialized = false;
  bool _showControls = true;
  bool _isFavorite = false;
  bool _isSharing = false;

  late ChallengesFeedController _feedController;
  late HomeProfileController _profileController;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _feedController = Get.isRegistered<ChallengesFeedController>()
        ? Get.find<ChallengesFeedController>()
        : Get.put(ChallengesFeedController(), permanent: true);
    _profileController = Get.isRegistered<HomeProfileController>()
        ? Get.find<HomeProfileController>()
        : Get.put(HomeProfileController(), permanent: true);
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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _vpc?.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (_vpc == null) return;
    setState(() {
      _vpc!.value.isPlaying ? _vpc!.pause() : _vpc!.play();
    });
  }

  void _toggleControls() => setState(() => _showControls = !_showControls);

  void _like() {
    _feedController.likePost(widget.post.id);
    setState(() {});
  }

  void _dislike() {
    _feedController.dislikePost(widget.post.id);
    setState(() {});
  }

  void _toggleFavorite() => setState(() => _isFavorite = !_isFavorite);

  void _share() {
    Get.snackbar('Share', 'Share feature coming soon',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white);
  }

  void _report() {
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
            const SizedBox(height: 16),
            const Text('Report', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            _ReportTile('Inappropriate content', Icons.warning_amber_outlined),
            _ReportTile('Spam', Icons.block_outlined),
            _ReportTile('Misleading information', Icons.info_outline),
            _ReportTile('Other', Icons.more_horiz),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _openComments() {
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
          final post = _feedController.findById(widget.post.id) ?? widget.post;
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: SizedBox(
              height: 420,
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Container(width: 36, height: 4,
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 12),
                  Text('${post.replies.length} Comments',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                  const Divider(color: Colors.white12),
                  Expanded(
                    child: post.replies.isEmpty
                        ? const Center(child: Text('No comments yet', style: TextStyle(color: Colors.white54)))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: post.replies.length,
                            itemBuilder: (_, i) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const CircleAvatar(radius: 14, backgroundColor: Color(0xFF333333),
                                      child: Icon(Icons.person, size: 14, color: Colors.white54)),
                                  const SizedBox(width: 10),
                                  Expanded(child: Text(post.replies[i],
                                      style: const TextStyle(color: Colors.white, fontSize: 13))),
                                ],
                              ),
                            ),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
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
                            _feedController.addReply(widget.post.id, text);
                            inputCtrl.clear();
                            setSheet(() {});
                            setState(() {});
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

  @override
  Widget build(BuildContext context) {
    final post = _feedController.findById(widget.post.id) ?? widget.post;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Video ──────────────────────────────────────────────────
            if (_initialized && _vpc != null)
              Center(
                child: AspectRatio(
                  aspectRatio: _vpc!.value.aspectRatio,
                  child: VideoPlayer(_vpc!),
                ),
              )
            else
              const Center(child: CircularProgressIndicator(color: Colors.white)),

            // ── Gradient overlays ──────────────────────────────────────
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x66000000), Colors.transparent, Color(0xAA000000)],
                      stops: [0.0, 0.4, 1.0],
                    ),
                  ),
                ),
              ),
            ),

            // ── Back button ────────────────────────────────────────────
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 12,
                child: SafeArea(
                  child: IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ),

            // ── Play/Pause center ──────────────────────────────────────
            if (_initialized && !_vpc!.value.isPlaying)
              Center(
                child: GestureDetector(
                  onTap: _togglePlay,
                  child: const Icon(Icons.play_circle_fill, color: Colors.white70, size: 72),
                ),
              ),

            // ── Bottom info ────────────────────────────────────────────
            Positioned(
              left: 0, right: 60, bottom: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          post.isMine
                              ? Obx(() => CircleAvatar(
                                    radius: 16,
                                    backgroundImage: _profileController.avatarProvider,
                                    backgroundColor: const Color(0xFF333333),
                                  ))
                              : CircleAvatar(
                                  radius: 16,
                                  backgroundImage: post.avatarUrl != null
                                      ? NetworkImage(post.avatarUrl!) as ImageProvider
                                      : null,
                                  backgroundColor: const Color(0xFF333333),
                                  child: post.avatarUrl == null
                                      ? const Icon(Icons.person, size: 16, color: Colors.white54)
                                      : null,
                                ),
                          const SizedBox(width: 8),
                          Text(post.author,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                          const SizedBox(width: 6),
                          Text(post.timeAgo,
                              style: const TextStyle(color: Colors.white60, fontSize: 11)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(post.title,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
                      const SizedBox(height: 4),
                      Row(children: [
                        _Chip(post.category),
                        const SizedBox(width: 6),
                        _Chip(post.fitnessLevel),
                      ]),
                      if (post.description.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(post.description,
                            maxLines: 2, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.3)),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // ── Right side action icons (reels style) ──────────────────
            Positioned(
              right: 10,
              bottom: MediaQuery.of(context).padding.bottom + 80,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Like
                  _ActionIcon(
                    icon: post.isLiked ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
                    label: '${post.likes}',
                    active: post.isLiked,
                    onTap: _like,
                  ),
                  const SizedBox(height: 20),
                  // Dislike
                  _ActionIcon(
                    icon: post.isDisliked ? Icons.thumb_down_alt : Icons.thumb_down_alt_outlined,
                    label: 'Dislike',
                    active: post.isDisliked,
                    onTap: _dislike,
                  ),
                  const SizedBox(height: 20),
                  // Comment
                  _ActionIcon(
                    icon: Icons.comment_outlined,
                    label: '${post.replies.length}',
                    onTap: _openComments,
                  ),
                  const SizedBox(height: 20),
                  // Favourite
                  _ActionIcon(
                    icon: _isFavorite ? Icons.bookmark : Icons.bookmark_border,
                    label: 'Save',
                    active: _isFavorite,
                    onTap: _toggleFavorite,
                  ),
                  const SizedBox(height: 20),
                  // Share
                  _ActionIcon(
                    icon: Icons.share_outlined,
                    label: 'Share',
                    onTap: _share,
                  ),
                  const SizedBox(height: 20),
                  // Report
                  _ActionIcon(
                    icon: Icons.flag_outlined,
                    label: 'Report',
                    onTap: _report,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helper Widgets ────────────────────────────────────────────────────────

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const _ActionIcon({
    required this.icon,
    required this.label,
    this.active = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 28,
              color: active ? const Color(0xFFFF4D6D) : Colors.white),
          const SizedBox(height: 3),
          Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  const _Chip(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 11)),
    );
  }
}

class _ReportTile extends StatelessWidget {
  final String label;
  final IconData icon;
  const _ReportTile(this.label, this.icon);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Get.back();
        Get.snackbar('Reported', 'Thank you for your report',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.black87,
            colorText: Colors.white);
      },
    );
  }
}
