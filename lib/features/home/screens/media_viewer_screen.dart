import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:fitness_app/features/home/controllers/home_profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class MediaViewerScreen extends StatefulWidget {
  final UserMediaItem media;

  const MediaViewerScreen({super.key, required this.media});

  @override
  State<MediaViewerScreen> createState() => _MediaViewerScreenState();
}

class _MediaViewerScreenState extends State<MediaViewerScreen> {
  VideoPlayerController? _videoController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _videoError;

  @override
  void initState() {
    super.initState();
    _initVideoIfNeeded();
    _playAttachedSoundIfAny();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _initVideoIfNeeded() async {
    if (!widget.media.isVideo) return;
    try {
      final path = widget.media.localPath;
      if (path != null && path.isNotEmpty && File(path).existsSync()) {
        final controller = VideoPlayerController.file(File(path));
        _videoController = controller;
        await controller.initialize();
        await controller.setLooping(true);
        await controller.setPlaybackSpeed(widget.media.speed);
        await controller.play();
        if (mounted) setState(() {});
        return;
      }

      final remote = widget.media.mediaUrl ?? widget.media.imageUrl;
      if (remote != null && remote.trim().isNotEmpty) {
        final controller = VideoPlayerController.networkUrl(Uri.parse(remote));
        _videoController = controller;
        await controller.initialize();
        await controller.setLooping(true);
        await controller.setPlaybackSpeed(widget.media.speed);
        await controller.play();
        if (mounted) setState(() {});
        return;
      }

      if (mounted) {
        setState(() => _videoError = 'Video source not found');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _videoError = 'Unable to play this video');
      }
    }
  }

  Future<void> _playAttachedSoundIfAny() async {
    final path = widget.media.soundPath;
    if (path == null || path.isEmpty) return;
    await _audioPlayer.stop();
    await _audioPlayer.play(DeviceFileSource(path));
  }

  @override
  Widget build(BuildContext context) {
    final media = widget.media;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: Center(child: _buildMedia(media))),
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0x80000000),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (media.caption.trim().isNotEmpty)
                      Text(
                        media.caption,
                        style: const TextStyle(color: Colors.white),
                      ),
                    if ((media.soundName ?? '').isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Sound: ${media.soundName}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      'Visibility: ${media.visibility}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedia(UserMediaItem media) {
    if (media.isVideo) {
      final controller = _videoController;
      if (_videoError != null) {
        return Text(
          _videoError!,
          style: const TextStyle(color: Colors.white70),
        );
      }
      if (controller == null || !controller.value.isInitialized) {
        return const CircularProgressIndicator(color: Colors.white);
      }
      return AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: VideoPlayer(controller),
      );
    }

    if (media.bytes != null) {
      return Image.memory(media.bytes!, fit: BoxFit.contain);
    }
    if ((media.localPath ?? '').isNotEmpty) {
      return Image.file(File(media.localPath!), fit: BoxFit.contain);
    }
    if ((media.imageUrl ?? '').isNotEmpty) {
      return Image.network(media.imageUrl!, fit: BoxFit.contain);
    }
    return const Icon(Icons.image_not_supported, color: Colors.white70);
  }
}
