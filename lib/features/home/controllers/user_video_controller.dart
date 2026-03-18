import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:fitness_app/features/home/models/user_video_item.dart';
import 'package:fitness_app/features/home/services/app_api_service.dart';
import 'package:fitness_app/features/home/controllers/home_profile_controller.dart';

class UserVideoController extends GetxController {
  final _api = AppApiService();
  final RxList<UserVideoItem> videos = <UserVideoItem>[].obs;
  final RxBool isLoading = false.obs;
  int _counter = 0;

  @override
  void onInit() {
    super.onInit();
    loadShorts();
  }

  Future<void> loadShorts() async {
    isLoading.value = true;
    try {
      final result = await _api.getShorts();
      if (result['ok'] == true) {
        final data = result['data'];
        List<dynamic> list = [];
        if (data is Map) {
          list = data['data'] ?? data['shorts'] ?? data['reels'] ?? data['videos'] ?? [];
        } else if (data is List) {
          list = data;
        }
        if (list.isNotEmpty) {
          final fetched = list.whereType<Map<String, dynamic>>().map(_fromApi).toList();
          // Keep locally added videos (isMine), replace server ones
          videos.removeWhere((v) => !v.isMine);
          videos.addAll(fetched);
        }
      }
    } catch (_) {}
    isLoading.value = false;
  }

  UserVideoItem _fromApi(Map<String, dynamic> m) {
    _counter++;
    return UserVideoItem(
      id: (m['id'] ?? 'sv_$_counter').toString(),
      userId: (m['user_id'] ?? m['user']?['id'] ?? '').toString(),
      userName: (m['user']?['name'] ?? m['user_name'] ?? 'User').toString(),
      userHandle: (m['user']?['username'] ?? m['handle'] ?? '@user').toString(),
      profileImageUrl: (m['user']?['avatar_url'] ?? m['avatar_url'] ?? '').toString(),
      videoUrl: (m['video_url'] ?? m['url'] ?? '').toString(),
      caption: (m['caption'] ?? m['description'] ?? '').toString(),
      hashtags: [],
      timeAgo: (m['created_at'] ?? '').toString(),
      likeCount: _toInt(m['likes_count'] ?? m['likes'] ?? 0),
      isMine: false,
    );
  }

  static int _toInt(dynamic v) =>
      v == null ? 0 : (v is num ? v.toInt() : int.tryParse(v.toString()) ?? 0);

  void addVideo({
    required String userName,
    required String userHandle,
    Uint8List? profileImageBytes,
    String? profileImageUrl,
    String? videoPath,
    String? videoUrl,
    String caption = '',
    List<String> hashtags = const [],
    bool isMine = true,
  }) {
    _counter++;
    videos.insert(
      0,
      UserVideoItem(
        id: 'uv_$_counter',
        userId: 'me',
        userName: userName,
        userHandle: userHandle,
        profileImageBytes: profileImageBytes,
        profileImageUrl: profileImageUrl,
        videoPath: videoPath,
        videoUrl: videoUrl,
        caption: caption,
        hashtags: hashtags,
        timeAgo: 'Just now',
        isMine: isMine,
      ),
    );
  }

  void toggleLike(String id) {
    final i = _indexOf(id);
    if (i == -1) return;
    final v = videos[i];
    if (v.isLiked) {
      v.isLiked = false;
      v.likeCount = (v.likeCount - 1).clamp(0, 1 << 31);
    } else {
      v.isLiked = true;
      v.likeCount++;
      if (v.isDisliked) {
        v.isDisliked = false;
        v.dislikeCount = (v.dislikeCount - 1).clamp(0, 1 << 31);
      }
    }
    videos.refresh();
    // Sync liked video to profile
    final profileCtrl = Get.isRegistered<HomeProfileController>()
        ? Get.find<HomeProfileController>()
        : null;
    if (profileCtrl != null) {
      if (v.isLiked) {
        profileCtrl.addLikedVideo(v);
      } else {
        profileCtrl.removeLikedVideo(v.id);
      }
    }
    _api.toggleReelReaction(reelId: id, reactionType: 'like', isActive: v.isLiked).catchError((_) {});
  }

  void toggleDislike(String id) {
    final i = _indexOf(id);
    if (i == -1) return;
    final v = videos[i];
    if (v.isDisliked) {
      v.isDisliked = false;
      v.dislikeCount = (v.dislikeCount - 1).clamp(0, 1 << 31);
    } else {
      v.isDisliked = true;
      v.dislikeCount++;
      if (v.isLiked) {
        v.isLiked = false;
        v.likeCount = (v.likeCount - 1).clamp(0, 1 << 31);
      }
    }
    videos.refresh();
    _api.toggleReelReaction(reelId: id, reactionType: 'dislike', isActive: v.isDisliked).catchError((_) {});
  }

  void toggleFavorite(String id) {
    final i = _indexOf(id);
    if (i == -1) return;
    final v = videos[i];
    v.isFavorite = !v.isFavorite;
    v.favoriteCount += v.isFavorite ? 1 : -1;
    videos.refresh();
    _api.toggleReelReaction(reelId: id, reactionType: 'favorite', isActive: v.isFavorite).catchError((_) {});
  }

  void toggleFollow(String id) {
    final i = _indexOf(id);
    if (i == -1) return;
    final v = videos[i];
    v.isFollowing = !v.isFollowing;
    videos.refresh();
    // Update profile following list
    final profileCtrl = Get.isRegistered<HomeProfileController>()
        ? Get.find<HomeProfileController>()
        : null;
    if (profileCtrl != null) {
      if (v.isFollowing) {
        profileCtrl.addFollowing(SocialUser(
          id: v.userId,
          name: v.userName,
          handle: v.normalizedHandle,
          avatarUrl: v.profileImageUrl,
        ));
      } else {
        profileCtrl.removeFollowing(v.userId);
      }
    }
    _api.followUser(userId: v.userId, follow: v.isFollowing).catchError((_) {});
  }

  void addComment(String id, String text) {
    final i = _indexOf(id);
    if (i == -1) return;
    videos[i].comments.add(text.trim());
    videos[i].commentCount++;
    videos.refresh();
    // Send comment to backend (reels comment endpoint)
    _api.addComment(challengeId: id, description: text.trim()).catchError((_) {});
  }

  int _indexOf(String id) => videos.indexWhere((v) => v.id == id);

  String formatCount(int v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return '$v';
  }
}
