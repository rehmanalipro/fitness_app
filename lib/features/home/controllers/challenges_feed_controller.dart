import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:fitness_app/features/home/services/app_api_service.dart';
import 'package:fitness_app/features/home/controllers/home_profile_controller.dart';

class ChallengePost {
  String id;
  final String author;
  final String timeAgo;
  final String title;
  final String target;
  final String category;
  final String fitnessLevel;
  final String description;
  final bool isMine;
  final String? avatarUrl;
  final Uint8List? imageBytes;
  final String? videoPath;
  final String? videoUrl;
  final String? imageUrl;
  int likes;
  bool isLiked;
  bool isDisliked;
  bool accepted;
  double progress; // 0.0 – 1.0
  final List<String> replies;

  ChallengePost({
    required this.id,
    required this.author,
    required this.timeAgo,
    required this.title,
    required this.target,
    required this.category,
    required this.fitnessLevel,
    required this.description,
    required this.isMine,
    this.avatarUrl,
    this.imageBytes,
    this.videoPath,
    this.videoUrl,
    this.imageUrl,
    required this.likes,
    this.isLiked = false,
    this.isDisliked = false,
    required this.accepted,
    this.progress = 0.0,
    required this.replies,
  });

  bool get hasVideo =>
      (videoPath != null && videoPath!.isNotEmpty) ||
      (videoUrl != null && videoUrl!.isNotEmpty);
}

class ChallengesFeedController extends GetxController {
  final _api = AppApiService();
  int _counter = 3;
  bool isLoadingPublic = false;

  final List<ChallengePost> _publicPosts = [
    ChallengePost(
      id: 'public_1',
      author: 'Maude Hall',
      timeAgo: '14 min',
      title: 'Push-Up Challenge',
      target: 'Do 100 push-ups in 1 minute',
      category: 'Strength',
      fitnessLevel: 'Beginner',
      description: 'Do 100 push-ups with proper form in under one minute.',
      isMine: false,
      avatarUrl: 'https://i.pravatar.cc/120?img=24',
      likes: 2,
      accepted: false,
      replies: [],
    ),
    ChallengePost(
      id: 'public_2',
      author: 'Chris Fox',
      timeAgo: '8 min',
      title: 'Plank Hold Challenge',
      target: 'Hold plank for 3 minutes',
      category: 'Core',
      fitnessLevel: 'Intermediate',
      description: 'Maintain a straight body line and hold for three minutes.',
      isMine: false,
      avatarUrl: 'https://i.pravatar.cc/120?img=12',
      likes: 4,
      accepted: false,
      replies: [],
    ),
  ];

  final List<ChallengePost> _myPosts = [];

  List<ChallengePost> get publicPosts => List.unmodifiable(_publicPosts);
  List<ChallengePost> get myPosts => List.unmodifiable(_myPosts);

  @override
  void onInit() {
    super.onInit();
    loadPublicChallenges();
  }

  /// Load public challenges from backend and merge with local defaults.
  Future<void> loadPublicChallenges() async {
    isLoadingPublic = true;
    update();
    try {
      final result = await _api.getChallenges();
      if (kDebugMode) debugPrint('loadPublicChallenges: $result');
      if (result['ok'] == true) {
        final data = result['data'];
        List<dynamic>? list;
        // Try multiple response shapes
        if (data is Map) {
          list = (data['data'] as List?)
              ?? (data['challenges'] as List?)
              ?? (data['items'] as List?)
              ?? (data['posts'] as List?);
          // Sometimes data itself is the list wrapper
          if (list == null && data['id'] != null) {
            // single object — wrap it
            list = [data];
          }
        } else if (data is List) {
          list = data;
        }
        if (list != null && list.isNotEmpty) {
          final fetched = list
              .whereType<Map<String, dynamic>>()
              .map(_fromApi)
              .where((p) => p.title.isNotEmpty)
              .toList();
          if (fetched.isNotEmpty) {
            // Replace old server-fetched posts, keep local demo ones
            _publicPosts.removeWhere((p) => p.id.startsWith('api_'));
            _publicPosts.insertAll(0, fetched);
          }
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('loadPublicChallenges error: $e');
    }
    isLoadingPublic = false;
    update();
  }

  ChallengePost _fromApi(Map<String, dynamic> m) {
    final id = (m['id'] ?? m['_id'] ?? '').toString();
    return ChallengePost(
      id: 'api_$id',
      author: (m['user']?['name'] ?? m['author'] ?? 'Unknown').toString(),
      timeAgo: (m['created_at'] ?? '').toString(),
      title: (m['title'] ?? m['name'] ?? '').toString(),
      target: (m['target'] ?? m['goal'] ?? '').toString(),
      category: (m['category'] ?? '').toString(),
      fitnessLevel: (m['fitness_level'] ?? m['level'] ?? '').toString(),
      description: (m['description'] ?? '').toString(),
      isMine: false,
      avatarUrl: (m['user']?['avatar_url'] ?? m['avatar_url'] ?? '').toString(),
      videoUrl: (m['video_url'] ?? '').toString(),
      imageUrl: (m['image_url'] ?? '').toString(),
      likes: (m['likes_count'] ?? m['likes'] ?? 0) as int,
      accepted: (m['status'] ?? '') == 'accepted',
      progress: (m['progress'] is num) ? (m['progress'] as num).toDouble() / 100 : 0.0,
      replies: [],
    );
  }

  /// Post a new challenge — saves locally immediately, then syncs to backend.
  Future<void> addMyPost({
    required String title,
    required String target,
    required String category,
    required String fitnessLevel,
    required String description,
    Uint8List? imageBytes,
    String? videoPath,
    String? imageUrl,
  }) async {
    _counter += 1;
    final tempId = 'my_$_counter';

    // Get real username from profile controller if available
    String authorName = 'You';
    try {
      final profileCtrl = Get.find<HomeProfileController>();
      final name = profileCtrl.displayName.value.trim();
      if (name.isNotEmpty) authorName = name;
    } catch (_) {}

    final post = ChallengePost(
      id: tempId,
      author: authorName,
      timeAgo: 'Just now',
      title: title,
      target: target,
      category: category,
      fitnessLevel: fitnessLevel,
      description: description,
      isMine: true,
      imageBytes: imageBytes,
      videoPath: videoPath,
      imageUrl: imageUrl,
      likes: 0,
      accepted: false,
      replies: [],
    );
    _myPosts.insert(0, post);
    _publicPosts.insert(0, post);
    update();

    // Upload to backend
    try {
      if (videoPath != null && videoPath.isNotEmpty) {
        // Multipart upload for video
        final result = await _api.uploadChallengeWithMedia(
          title: title,
          target: target,
          category: category,
          fitnessLevel: fitnessLevel,
          description: description,
          mediaFile: File(videoPath),
          isVideo: true,
        );
        _updatePostId(tempId, result);
      } else if (imageBytes != null) {
        // Multipart upload for image
        final tmpFile = await _bytesToTempFile(imageBytes, 'jpg');
        if (tmpFile != null) {
          final result = await _api.uploadChallengeWithMedia(
            title: title,
            target: target,
            category: category,
            fitnessLevel: fitnessLevel,
            description: description,
            mediaFile: tmpFile,
            isVideo: false,
          );
          _updatePostId(tempId, result);
          await tmpFile.delete().catchError((_) {});
        }
      } else {
        // JSON-only
        final result = await _api.createChallenge({
          'title': title,
          'target': target,
          'category': category,
          'fitness_level': fitnessLevel,
          'description': description,
        });
        _updatePostId(tempId, result);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('addMyPost API error: $e');
    }
  }

  void _updatePostId(String tempId, Map<String, dynamic> result) {
    if (result['ok'] != true) return;
    final data = result['data'];
    if (data is! Map) return;
    final inner = data['data'] ?? data;
    if (inner is! Map) return;
    final serverId = inner['id']?.toString();
    if (serverId == null || serverId.isEmpty) return;

    for (final list in [_myPosts, _publicPosts]) {
      final idx = list.indexWhere((p) => p.id == tempId);
      if (idx != -1) list[idx].id = 'api_$serverId';
    }
    update();
  }

  Future<File?> _bytesToTempFile(Uint8List bytes, String ext) async {
    try {
      final dir = Directory.systemTemp;
      final file = File('${dir.path}/challenge_img_${DateTime.now().millisecondsSinceEpoch}.$ext');
      await file.writeAsBytes(bytes);
      return file;
    } catch (_) {
      return null;
    }
  }

  ChallengePost? findById(String id) {
    for (final post in [..._myPosts, ..._publicPosts]) {
      if (post.id == id) return post;
    }
    return null;
  }

  void likePost(String id) {
    final post = findById(id);
    if (post == null) return;
    if (post.isLiked) {
      post.isLiked = false;
      if (post.likes > 0) post.likes -= 1;
    } else {
      post.isLiked = true;
      post.likes += 1;
      post.isDisliked = false;
    }
    update();
    // Fire-and-forget API call   
    _api.likeChallenge(challengeId: id).catchError((_) {});
  }

  void dislikePost(String id) {
    final post = findById(id);
    if (post == null) return;
    if (post.isDisliked) {
      post.isDisliked = false;
    } else {
      post.isDisliked = true;
      if (post.isLiked) {
        post.isLiked = false;
        if (post.likes > 0) post.likes -= 1;
      }
    }
    update();
  }

  void acceptPost(String id) {
    final post = findById(id);
    if (post == null) return;
    if (post.accepted) return;
    post.accepted = true;
    post.progress = 1.0;
    update();
    try { Get.find<HomeProfileController>().addPoints(10); } catch (_) {}

    // Only call backend for real server posts (api_ prefix = real backend ID)
    // Local demo posts (public_1, public_2) don't exist on server
    if (id.startsWith('api_')) {
      _api.acceptChallenge(challengeId: id).then((result) {
        if (kDebugMode) debugPrint('acceptChallenge [$id] → ${result['ok']} (${result['statusCode']})');
      }).catchError((_) {});
    }
    // For my_ posts that got updated to api_ after upload, also call backend
    // (handled above since _updatePostId changes id to api_xxx)
  }

  void addReply(String id, String reply) {
    final trimmed = reply.trim();
    if (trimmed.isEmpty) return;
    final post = findById(id);
    if (post == null) return;
    post.replies.add(trimmed);
    update();
    // Send comment to backend
    _api.addComment(challengeId: id, description: trimmed).catchError((_) {});
  }
}
