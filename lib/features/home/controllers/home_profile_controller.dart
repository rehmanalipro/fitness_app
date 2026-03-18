import 'dart:typed_data';
import 'dart:math';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fitness_app/core/network/api_config.dart';
import 'package:fitness_app/features/auth/services/auth_service.dart';
import 'package:fitness_app/features/home/models/user_video_item.dart';
import 'package:fitness_app/features/home/services/app_api_service.dart';
import 'package:fitness_app/features/home/controllers/leaderboard_controller.dart';

class UserMediaItem {
  final String id;
  final Uint8List? bytes;
  final String? localPath;
  final bool isVideo;
  final String? imageUrl;
  final String? mediaUrl;
  final String caption;
  final String visibility;
  final String? soundName;
  final String? soundPath;
  final double speed;
  bool isLiked;

  UserMediaItem({
    required this.id,
    this.bytes,
    this.localPath,
    this.isVideo = false,
    this.imageUrl,
    this.mediaUrl,
    this.caption = '',
    this.visibility = 'Public',
    this.soundName,
    this.soundPath,
    this.speed = 1.0,
    this.isLiked = false,
  });
}

// ── Follow/Follower User Model ────────────────────────────────────────────
class SocialUser {
  final String id;
  final String name;
  final String handle;
  final String? avatarUrl;

  SocialUser({
    required this.id,
    required this.name,
    required this.handle,
    this.avatarUrl,
  });
}

class HomeProfileController extends GetxController {
  final AppApiService _apiService = AppApiService();

  final RxString displayName = ''.obs;
  final RxString userName = ''.obs;
  final RxString bio = ''.obs;
  final Rxn<Uint8List> avatarBytes = Rxn<Uint8List>();
  final RxnString avatarUrl = RxnString();
  final RxInt followingCount = 0.obs;
  final RxInt followerCount = 0.obs;
  final RxInt totalLikesCount = 0.obs;
  final RxInt points = 0.obs;
  final RxBool isSyncing = false.obs;
  final RxnString syncError = RxnString();
  bool _profileLoadedOnce = false;

  // TikTok-style social lists
  final RxList<SocialUser> followingUsers = <SocialUser>[].obs;
  final RxList<SocialUser> followerUsers = <SocialUser>[].obs;

  // Liked videos from reel feed
  final RxList<UserVideoItem> likedVideoItems = <UserVideoItem>[].obs;

  final RxList<UserMediaItem> mediaItems = <UserMediaItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadProfileFromApi();
  }

  void setDisplayName(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    displayName.value = trimmed;
  }

  void setAvatarBytes(Uint8List bytes) {
    avatarBytes.value = bytes;
  }

  void setAvatarUrl(String? value) {
    final url = value?.trim() ?? '';
    avatarUrl.value = url.isEmpty ? null : _resolveImageUrl(url);
  }

  void setProfile({
    required String name,
    required String username,
    required String userBio,
    Uint8List? avatar,
  }) {
    final trimmedName = name.trim();
    final trimmedUsername = username.trim();
    final trimmedBio = userBio.trim();

    if (trimmedName.isNotEmpty) displayName.value = trimmedName;
    if (trimmedUsername.isNotEmpty) {
      userName.value = trimmedUsername.startsWith('@')
          ? trimmedUsername
          : '@$trimmedUsername';
    }
    bio.value = trimmedBio.isEmpty
        ? 'Tap edit profile to add your bio'
        : trimmedBio;
    if (avatar != null) avatarBytes.value = avatar;
  }

  void addMedia(
    Uint8List bytes, {
    String caption = '',
    String visibility = 'Public',
    String? soundName,
    String? soundPath,
  }) {
    final id =
        'local_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999)}';
    mediaItems.insert(
      0,
      UserMediaItem(
        id: id,
        bytes: bytes,
        localPath: null,
        caption: caption,
        visibility: visibility,
        soundName: soundName,
        soundPath: soundPath,
      ),
    );
  }

  void addVideoMedia(
    String filePath, {
    String caption = '',
    String visibility = 'Public',
    String? soundName,
    String? soundPath,
    double speed = 1.0,
  }) {
    final id =
        'local_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999)}';
    mediaItems.insert(
      0,
      UserMediaItem(
        id: id,
        localPath: filePath,
        isVideo: true,
        mediaUrl: null,
        caption: caption,
        visibility: visibility,
        soundName: soundName,
        soundPath: soundPath,
        speed: speed,
      ),
    );
  }

  void toggleLike(String id) {
    final index = mediaItems.indexWhere((item) => item.id == id);
    if (index == -1) return;
    final wasLiked = mediaItems[index].isLiked;
    mediaItems[index].isLiked = !wasLiked;
    totalLikesCount.value = likedVideoItems.length +
        mediaItems.where((m) => m.isLiked).length;
    mediaItems.refresh();
  } //

  List<UserMediaItem> get likedMediaItems =>
      mediaItems.where((item) => item.isLiked).toList(growable: false);

  int get likesCount => totalLikesCount.value;

  /// Call on logout — clears all user data so next login starts fresh
  void resetForLogout() {
    displayName.value = '';
    userName.value = '';
    bio.value = '';
    avatarBytes.value = null;
    avatarUrl.value = null;
    followingCount.value = 0;
    followerCount.value = 0;
    totalLikesCount.value = 0;
    points.value = 0;
    followingUsers.clear();
    followerUsers.clear();
    likedVideoItems.clear();
    mediaItems.clear();
    syncError.value = null;
    _profileLoadedOnce = false;
  }

  void addPoints(int amount) {
    points.value += amount;
    try {
      Get.find<LeaderboardController>().syncCurrentUserPoints(points: points.value);
    } catch (_) {}
  }

  void incrementFollower() => followerCount.value++;
  void decrementFollower() {
    if (followerCount.value > 0) followerCount.value--;
  }

  // Called when user follows someone from reel feed
  void addFollowing(SocialUser user) {
    if (followingUsers.any((u) => u.id == user.id)) return;
    followingUsers.add(user);
    followingCount.value = followingUsers.length;
  }

  void removeFollowing(String userId) {
    followingUsers.removeWhere((u) => u.id == userId);
    followingCount.value = followingUsers.length;
  }

  // Called when someone follows you (simulated via Follow button on profile)
  void addFollower(SocialUser user) {
    if (followerUsers.any((u) => u.id == user.id)) return;
    followerUsers.add(user);
    followerCount.value = followerUsers.length;
  }

  // Called when user likes a video in reel feed
  void addLikedVideo(UserVideoItem video) {
    if (likedVideoItems.any((v) => v.id == video.id)) return;
    likedVideoItems.insert(0, video);
    totalLikesCount.value = likedVideoItems.length +
        mediaItems.where((m) => m.isLiked).length;
  }

  void removeLikedVideo(String videoId) {
    likedVideoItems.removeWhere((v) => v.id == videoId);
    totalLikesCount.value = likedVideoItems.length +
        mediaItems.where((m) => m.isLiked).length;
  }

  ImageProvider? get avatarProvider {
    final remoteAvatar = avatarUrl.value;
    if (remoteAvatar != null && remoteAvatar.trim().isNotEmpty) {
      return NetworkImage(remoteAvatar);
    }
    final bytes = avatarBytes.value;
    if (bytes != null) return MemoryImage(bytes);
    return null; // null = show person icon placeholder
  }

  Future<void> loadProfileFromApi({bool force = false}) async {
    if (_profileLoadedOnce && !force) return;
    isSyncing.value = true;
    syncError.value = null;
    try {
      final result = await _apiService.getProfile();
      final ok = result['ok'] == true;
      if (!ok) {
        syncError.value = 'Unable to load profile (${result['statusCode']})';
        // Fallback: load name from local signup data
        await _loadLocalFallback();
        return;
      }
      final payload = _extractPayload(result['data']);
      final remoteName = _pickString(payload, ['name', 'full_name']);
      final remoteUsername = _pickString(payload, ['username', 'user_name', 'handle']);
      final remoteBio = _pickString(payload, ['bio', 'about']);
      final remoteAvatar = _pickString(payload, [
        'avatar_url', 'profile_image_url', 'image_url', 'avatar', 'image', 'photo_url',
      ]);

      if (remoteName != null && remoteName.trim().isNotEmpty) {
        displayName.value = remoteName.trim();
      }
      if (remoteUsername != null && remoteUsername.trim().isNotEmpty) {
        final trimmed = remoteUsername.trim();
        userName.value = trimmed.startsWith('@') ? trimmed : '@$trimmed';
      }
      if (remoteBio != null) {
        bio.value = remoteBio.trim();
      }
      if (remoteAvatar != null && remoteAvatar.trim().isNotEmpty) {
        setAvatarUrl(remoteAvatar);
        avatarBytes.value = null;
      }

      _hydrateMediaFromPayload(payload);
      final mediaResult = await _apiService.getProfileMedia();
      if (mediaResult['ok'] == true) {
        _hydrateMediaFromPayload(_extractPayload(mediaResult['data']));
      }

      // Load social counts
      final socialResult = await _apiService.getSocialDetail();
      if (socialResult['ok'] == true) {
        final sp = _extractPayload(socialResult['data']);
        final fc = sp['followers_count'] ?? sp['followers'] ?? sp['follower_count'];
        final fwc = sp['following_count'] ?? sp['following'];
        final lc = sp['likes_count'] ?? sp['total_likes'] ?? sp['likes'];
        if (fc is num) followerCount.value = fc.toInt();
        if (fwc is num) followingCount.value = fwc.toInt();
        if (lc is num) totalLikesCount.value = lc.toInt();
      }

      _profileLoadedOnce = true;
    } catch (_) {
      syncError.value = 'Unable to connect to server';
      await _loadLocalFallback();
    } finally {
      isSyncing.value = false;
    }
  }

  /// Load name/email from local SharedPreferences as fallback when backend unreachable
  Future<void> _loadLocalFallback() async {
    try {
      final AuthService authService = AuthService();
      final email = await authService.getEmail();
      // If name is still empty, derive from email
      if (displayName.value.isEmpty && email != null && email.isNotEmpty) {
        final namePart = email.split('@').first;
        displayName.value = namePart;
        if (userName.value.isEmpty) {
          userName.value = '@$namePart';
        }
      }
    } catch (_) {}
  }

  Future<bool> saveProfileToApi({
    required String name,
    required String username,
    required String userBio,
  }) async {
    isSyncing.value = true;
    syncError.value = null;
    try {
      final trimmedName = name.trim();
      final trimmedUsername = username.trim();
      final cleanUsername = trimmedUsername.startsWith('@')
          ? trimmedUsername.substring(1)
          : trimmedUsername;
      final trimmedBio = userBio.trim();

      final result = await _apiService.updateProfile({
        'name': trimmedName,
        'username': cleanUsername,
        'user_name': cleanUsername,
        'bio': trimmedBio,
      });

      final ok = result['ok'] == true;
      if (!ok) {
        syncError.value = 'Unable to save profile (${result['statusCode']})';
        return false;
      }

      setProfile(
        name: trimmedName,
        username: cleanUsername,
        userBio: trimmedBio,
      );
      return true;
    } catch (_) {
      syncError.value = 'Unable to connect to server';
      return false;
    } finally {
      isSyncing.value = false;
    }
  }

  Future<bool> uploadAvatarToApi(String imagePath) async {
    isSyncing.value = true;
    syncError.value = null;
    try {
      final result = await _apiService.uploadProfileImage(File(imagePath));
      final ok = result['ok'] == true;
      if (!ok) {
        syncError.value =
            'Unable to upload profile image (${result['statusCode']})';
      } else {
        final payload = _extractPayload(result['data']);
        final remoteAvatar = _pickString(payload, [
          'avatar_url',
          'profile_image_url',
          'image_url',
          'avatar',
          'image',
          'photo_url',
        ]);
        if (remoteAvatar != null && remoteAvatar.trim().isNotEmpty) {
          setAvatarUrl(remoteAvatar);
          avatarBytes.value = null;
        } else {
          await loadProfileFromApi(force: true);
        }
      }
      return ok;
    } catch (_) {
      syncError.value = 'Unable to connect to server';
      return false;
    } finally {
      isSyncing.value = false;
    }
  }

  Map<String, dynamic> _extractPayload(dynamic raw) {
    if (raw is! Map<String, dynamic>) return <String, dynamic>{};
    final nested = raw['data'];
    if (nested is Map<String, dynamic>) return nested;
    return raw;
  }

  String? _pickString(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value is String) return value;
    }
    return null;
  }

  String _resolveImageUrl(String raw) {
    final value = raw.trim();
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    if (value.startsWith('/')) {
      return '${ApiConfig.baseUrl}$value';
    }
    return '${ApiConfig.baseUrl}/$value';
  }

  Future<bool> createMediaPost({
    required bool isVideo,
    String? mediaPath,
    Uint8List? imageBytes,
    String caption = '',
    String visibility = 'Public',
    String? soundName,
    String? soundPath,
    double speed = 1.0,
  }) async {
    final trimmedCaption = caption.trim();
    final trimmedVisibility = visibility.trim().isEmpty ? 'Public' : visibility;

    final localFilePath = mediaPath?.trim() ?? '';
    if (localFilePath.isEmpty && imageBytes == null) {
      syncError.value = 'No media selected';
      return false;
    }

    if (localFilePath.isNotEmpty) {
      final file = File(localFilePath);
      if (!file.existsSync()) {
        syncError.value = 'Selected file does not exist';
        return false;
      }
    }

    final fallbackLocalId =
        'local_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999)}';

    isSyncing.value = true;
    syncError.value = null;
    try {
      if (localFilePath.isNotEmpty) {
        final result = await _apiService.uploadMediaPost(
          mediaFile: File(localFilePath),
          isVideo: isVideo,
          caption: trimmedCaption,
          visibility: trimmedVisibility,
          soundName: soundName,
          soundPath: soundPath,
          speed: speed,
        );

        if (result['ok'] == true) {
          final payload = _extractPayload(result['data']);
          final remoteId = _pickString(payload, ['id', 'post_id', '_id']);
          final remoteCaption = _pickString(payload, [
            'caption',
            'description',
            'text',
          ]);
          final remoteVisibility = _pickString(payload, [
            'visibility',
            'scope',
          ]);
          final remoteSoundName = _pickString(payload, [
            'sound_name',
            'sound',
            'music_name',
          ]);
          final remoteMediaUrl = _pickString(payload, [
            'media_url',
            'video_url',
            'image_url',
            'file_url',
            'url',
          ]);
          final remoteThumbUrl = _pickString(payload, [
            'thumbnail_url',
            'thumb_url',
            'preview_url',
            'image_url',
          ]);
          final remoteType = _pickString(payload, [
            'type',
            'media_type',
            'kind',
          ]);
          final remoteIsVideo =
              (remoteType ?? '').toLowerCase() == 'video' ||
              (remoteMediaUrl ?? '').toLowerCase().contains('.mp4');

          mediaItems.insert(
            0,
            UserMediaItem(
              id: remoteId ?? fallbackLocalId,
              isVideo: isVideo || remoteIsVideo,
              localPath: localFilePath,
              mediaUrl: remoteMediaUrl == null
                  ? null
                  : _resolveImageUrl(remoteMediaUrl),
              imageUrl: remoteThumbUrl == null
                  ? null
                  : _resolveImageUrl(remoteThumbUrl),
              caption: (remoteCaption ?? trimmedCaption).trim(),
              visibility: (remoteVisibility ?? trimmedVisibility).trim(),
              soundName: (remoteSoundName ?? soundName)?.trim(),
              soundPath: soundPath,
              speed: speed,
            ),
          );
          return true;
        }

        final data = result['data'];
        final message = data is Map<String, dynamic>
            ? (data['message']?.toString() ?? '')
            : '';
        final tried = data is Map<String, dynamic> ? data['tried'] : null;
        final triedText = tried is List && tried.isNotEmpty
            ? ' Tried: ${tried.map((e) => (e as Map)['endpoint']).join(', ')}'
            : '';
        syncError.value =
            'Upload failed (${result['statusCode']}) ${message.trim()}$triedText';
        return false;
      }

      if (imageBytes != null) {
        addMedia(
          imageBytes,
          caption: trimmedCaption,
          visibility: trimmedVisibility,
          soundName: soundName,
          soundPath: soundPath,
        );
        return true;
      }

      syncError.value = 'No media selected';
      return false;
    } catch (_) {
      syncError.value = 'Unable to connect to server';
      return false;
    } finally {
      isSyncing.value = false;
    }
  }

  void _hydrateMediaFromPayload(Map<String, dynamic> payload) {
    final list = _pickMediaList(payload);
    if (list == null || list.isEmpty) return;

    final hydrated = <UserMediaItem>[];
    for (final raw in list) {
      if (raw is! Map<String, dynamic>) continue;
      final id =
          _pickString(raw, ['id', 'post_id', '_id']) ??
          'remote_${hydrated.length}_${DateTime.now().millisecondsSinceEpoch}';
      final caption =
          _pickString(raw, ['caption', 'description', 'text']) ?? '';
      final visibility = _pickString(raw, ['visibility', 'scope']) ?? 'Public';
      final soundName = _pickString(raw, ['sound_name', 'sound', 'music_name']);
      final mediaUrl = _pickString(raw, [
        'media_url',
        'video_url',
        'image_url',
        'file_url',
        'url',
      ]);
      final thumbUrl = _pickString(raw, [
        'thumbnail_url',
        'thumb_url',
        'preview_url',
        'image_url',
      ]);
      final mediaType = _pickString(raw, ['type', 'media_type', 'kind']) ?? '';
      final isVideo =
          mediaType.toLowerCase() == 'video' ||
          (mediaUrl ?? '').toLowerCase().contains('.mp4');

      hydrated.add(
        UserMediaItem(
          id: id,
          isVideo: isVideo,
          mediaUrl: mediaUrl == null ? null : _resolveImageUrl(mediaUrl),
          imageUrl: thumbUrl == null ? null : _resolveImageUrl(thumbUrl),
          caption: caption,
          visibility: visibility,
          soundName: soundName,
        ),
      );
    }

    if (hydrated.isNotEmpty) {
      mediaItems.assignAll(hydrated);
    }
  }

  List<dynamic>? _pickMediaList(Map<String, dynamic> map) {
    const keys = <String>[
      'media',
      'posts',
      'items',
      'media_items',
      'profile_media',
      'data',
    ];
    for (final key in keys) {
      final value = map[key];
      if (value is List) return value;
      if (value is Map<String, dynamic>) {
        for (final nestedKey in keys) {
          final nested = value[nestedKey];
          if (nested is List) return nested;
        }
      }
    }
    return null;
  }
}
