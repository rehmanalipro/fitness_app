import 'dart:convert';
import 'dart:io';

import 'package:fitness_app/core/network/api_config.dart';
import 'package:fitness_app/features/auth/services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AppApiService {
  final AuthService _authService = AuthService();

  // ── Home ─────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getHome() async {
    return _get(ApiConfig.homeUrl);
  }

  // ── Profile ──────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getProfile() async {
    final result = await _get(ApiConfig.getUserProfileUrl);
    if (result['ok'] == true) return result;
    return _get(ApiConfig.profileUrl); // fallback: GET /api/profile
  }

  Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> fields,
  ) async {
    return _postToFirstAvailable(
      endpoints: [
        ApiConfig.updateProfileUrl,   // POST /api/update_profile
        ApiConfig.profileUrl,         // POST /api/profile
      ],
      body: fields,
    );
  }

  Future<Map<String, dynamic>> uploadProfileImage(File imageFile) async {
    final token = await _authService.getToken();
    final endpoints = [
      ApiConfig.profileImageUrl,      // POST /api/update_profile_img
      ApiConfig.api('profile/image'), // fallback
    ];
    for (final url in endpoints) {
      final uri = Uri.parse(url);
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(_authHeaders(token));
      for (final field in ['image', 'media']) {
        try { request.files.add(await http.MultipartFile.fromPath(field, imageFile.path)); } catch (_) {}
      }
      try {
        final streamed = await request.send().timeout(_timeout);
        final response = await http.Response.fromStream(streamed);
        final result = _toResult(response);
        if (result['ok'] == true) return result;
      } catch (_) {}
    }
    return _timeoutResult();
  }

  // ── Media posts ──────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> uploadMediaPost({
    required File mediaFile,
    required bool isVideo,
    required String caption,
    required String visibility,
    String? soundPath,
    String? soundName,
    double speed = 1.0,
  }) async {
    final token = await _authService.getToken();
    final endpoints = <String>[
      ApiConfig.mediaPostsUrl,
      ApiConfig.profileMediaUrl,
      ApiConfig.api('posts/media'),
      ApiConfig.api('posts'),
      ApiConfig.root('media/posts'),
      ApiConfig.root('profile/media'),
      ApiConfig.root('posts/media'),
      ApiConfig.root('posts'),
    ];
    final tried = <Map<String, dynamic>>[];

    for (final url in endpoints) {
      final uri = Uri.parse(url);
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(_authHeaders(token));
      request.fields['caption'] = caption;
      request.fields['visibility'] = visibility.toLowerCase();
      request.fields['type'] = isVideo ? 'video' : 'image';
      request.fields['speed'] = speed.toStringAsFixed(2);
      if (soundName != null && soundName.trim().isNotEmpty) {
        request.fields['sound_name'] = soundName.trim();
      }
      if (soundPath != null && soundPath.trim().isNotEmpty) {
        try {
          request.files.add(
            await http.MultipartFile.fromPath('sound', soundPath),
          );
        } catch (_) {}
      }
      for (final field in <String>[
        isVideo ? 'video' : 'image',
        'media',
        'file',
        'upload',
      ]) {
        try {
          request.files.add(
            await http.MultipartFile.fromPath(field, mediaFile.path),
          );
        } catch (_) {}
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      final result = _toResult(response);
      if (result['ok'] == true) {
        result['endpoint'] = url;
        return result;
      }
      tried.add({
        'endpoint': url,
        'statusCode': result['statusCode'] as int? ?? 0,
      });
    }

    // Image-only fallback: profile image endpoint
    if (!isVideo) {
      final uri = Uri.parse(ApiConfig.profileImageUrl);
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(_authHeaders(token));
      request.fields['caption'] = caption;
      request.fields['visibility'] = visibility.toLowerCase();
      request.files.add(
        await http.MultipartFile.fromPath('image', mediaFile.path),
      );
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      final result = _toResult(response);
      if (result['ok'] == true) {
        result['endpoint'] = ApiConfig.profileImageUrl;
        return result;
      }
      tried.add({
        'endpoint': ApiConfig.profileImageUrl,
        'statusCode': result['statusCode'] as int? ?? 0,
      });
    }

    return <String, dynamic>{
      'ok': false,
      'statusCode': 404,
      'data': {
        'message': isVideo
            ? 'Video upload endpoint not found on backend'
            : 'Image upload endpoint not found on backend',
        'tried': tried,
      },
    };
  }

  Future<Map<String, dynamic>> getProfileMedia() async {
    final result = await _get(ApiConfig.profileMediaUrl);
    if (result['ok'] == true) return result;
    return _get(ApiConfig.mediaPostsUrl);
  }

  // ── Challenges ───────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getChallenges() async {
    // Try GET first, then POST fallbacks
    final getResult = await _postToFirstAvailable(
      endpoints: [
        ApiConfig.challengesUrl,       // GET /api/challenges
        ApiConfig.allChallengesUrl,    // GET /api/all_challenges
        ApiConfig.api('challenges/public'),
        ApiConfig.api('get_challenges'),
        ApiConfig.api('public_challenges'),
      ],
      body: {},
      useGet: true,
    );
    if (getResult['ok'] == true) return getResult;

    // Fallback: try POST
    return _postToFirstAvailable(
      endpoints: [
        ApiConfig.challengesUrl,
        ApiConfig.allChallengesUrl,
        ApiConfig.api('get_challenges'),
      ],
      body: {'type': 'public'},
    );
  }

  Future<Map<String, dynamic>> getChallengeCategories() async {
    return _get(ApiConfig.challengeCategoriesUrl);
  }

  Future<Map<String, dynamic>> createChallenge(
    Map<String, dynamic> fields,
  ) async {
    return _postToFirstAvailable(
      endpoints: [
        ApiConfig.challengesUrl,
        ApiConfig.createChallengeUrl,
        ApiConfig.api('challenges/store'),
      ],
      body: fields,
    );
  }

  Future<Map<String, dynamic>> uploadChallengeWithMedia({
    required String title,
    required String target,
    required String category,
    required String fitnessLevel,
    required String description,
    required File mediaFile,
    required bool isVideo,
  }) async {
    final token = await _authService.getToken();
    final endpoints = [
      ApiConfig.challengesUrl,
      ApiConfig.createChallengeUrl,
      ApiConfig.api('challenges/store'),
    ];
    final tried = <Map<String, dynamic>>[];

    for (final url in endpoints) {
      final uri = Uri.parse(url);
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(_authHeaders(token));
      request.fields['title'] = title;
      request.fields['target'] = target;
      request.fields['category'] = category;
      request.fields['fitness_level'] = fitnessLevel;
      request.fields['description'] = description;
      request.fields['type'] = isVideo ? 'video' : 'image';
      for (final field in [isVideo ? 'video' : 'image', 'media', 'file']) {
        try {
          request.files.add(await http.MultipartFile.fromPath(field, mediaFile.path));
        } catch (_) {}
      }
      try {
        final streamed = await request.send().timeout(_timeout);
        final response = await http.Response.fromStream(streamed);
        final result = _toResult(response);
        if (result['ok'] == true) { result['endpoint'] = url; return result; }
        tried.add({'endpoint': url, 'statusCode': result['statusCode']});
      } catch (_) {
        tried.add({'endpoint': url, 'statusCode': 0});
      }
    }
    return {'ok': false, 'statusCode': 0, 'data': {'message': 'Upload failed', 'tried': tried}};
  }

  Future<Map<String, dynamic>> acceptChallenge({required String challengeId}) async {
    // Strip local prefix — backend needs raw numeric/uuid id
    final rawId = challengeId.replaceFirst(RegExp(r'^(api_|my_|public_)'), '');
    if (rawId.isEmpty || rawId == challengeId && !challengeId.contains('_')) {
      // rawId is already clean
    }
    if (kDebugMode) debugPrint('acceptChallenge rawId: $rawId (from: $challengeId)');
    return _postToFirstAvailable(
      endpoints: [
        ApiConfig.acceptChallengeUrl,              // POST /api/accept_challenge
        ApiConfig.api('challenges/$rawId/accept'), // POST /api/challenges/{id}/accept
        ApiConfig.challengeRecordUrl(rawId),       // POST /api/challenges/{id}/record
        ApiConfig.api('accept_challenge'),         // alias
      ],
      body: {
        'challenge_id': rawId,
        'id': rawId,
        'status': 'accepted',
        'progress': 100,
      },
    );
  }

  Future<Map<String, dynamic>> likeChallenge({required String challengeId}) async {
    final rawId = challengeId.replaceFirst(RegExp(r'^(api_|my_|public_)'), '');
    return _postToFirstAvailable(
      endpoints: [
        ApiConfig.likeChallengeUrl,                // POST /api/like_challenge
        ApiConfig.api('challenges/$rawId/like'),   // fallback
        ApiConfig.api('challenges/$rawId/reactions'),
      ],
      body: {'challenge_id': rawId, 'id': rawId, 'reaction': 'like'},
    );
  }

  Future<Map<String, dynamic>> getCurrentChallenge() async {
    return _get(ApiConfig.currentChallengeUrl);
  }

  Future<Map<String, dynamic>> getCurrentChallengeById(String id) async {
    return _get(ApiConfig.currentChallengeByIdUrl(id));
  }

  Future<Map<String, dynamic>> startRandomChallenge({
    Map<String, dynamic>? fields,
  }) async {
    return _post(ApiConfig.startRandomChallengeUrl, body: fields ?? {});
  }

  Future<Map<String, dynamic>> updateChallengeProgress(
    String id,
    Map<String, dynamic> fields,
  ) async {
    return _post(ApiConfig.challengeRecordUrl(id), body: fields);
  }

  Future<Map<String, dynamic>> deleteChallenge(String id) async {
    final rawId = id.replaceFirst(RegExp(r'^(api_|my_|public_)'), '');
    return _delete(ApiConfig.currentChallengeByIdUrl(rawId));
  }

  Future<Map<String, dynamic>> getChallengeLimits() async {
    return _get(ApiConfig.challengeLimitsUrl);
  }

  Future<Map<String, dynamic>> extendChallengeLimits(
    Map<String, dynamic> fields,
  ) async {
    return _post(ApiConfig.challengeLimitsExtendUrl, body: fields);
  }

  Future<Map<String, dynamic>> getChallengeCards() async {
    return _get(ApiConfig.challengeCardsUrl);
  }

  // ── Guides ───────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getGuides({
    String tab = 'for_you',
    String? topic,
  }) async {
    return _getWithQuery(ApiConfig.guidesUrl, <String, String>{
      'tab': tab,
      if (topic != null && topic.trim().isNotEmpty) 'topic': topic.trim(),
    });
  }

  Future<Map<String, dynamic>> getGuidePosts({
    String? topic,
    String tab = 'public',
    int perPage = 10,
  }) async {
    return _getWithQuery(ApiConfig.guidesPostsUrl, <String, String>{
      if (topic != null && topic.trim().isNotEmpty) 'topic': topic.trim(),
      'tab': tab,
      'per_page': '$perPage',
    });
  }

  Future<Map<String, dynamic>> createGuidePost(
    Map<String, dynamic> fields,
  ) async {
    return _post(ApiConfig.guidesPostsUrl, body: fields);
  }

  Future<Map<String, dynamic>> likeGuidePost(String id) async {
    return _post(ApiConfig.guidePostLikeUrl(id), body: {});
  }

  Future<Map<String, dynamic>> replyGuidePost(
    String id,
    Map<String, dynamic> fields,
  ) async {
    return _post(ApiConfig.guidePostReplyUrl(id), body: fields);
  }

  // ── Chat ─────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getChatRooms() async {
    return _get(ApiConfig.chatRoomsUrl);
  }

  Future<Map<String, dynamic>> inviteToChatRoom(
    String roomId,
    Map<String, dynamic> fields,
  ) async {
    return _post(ApiConfig.chatRoomInviteUrl(roomId), body: fields);
  }

  Future<Map<String, dynamic>> getChatRoomMessages(String roomId) async {
    return _get(ApiConfig.chatRoomMessagesUrl(roomId));
  }

  Future<Map<String, dynamic>> createChatRoomMessage(
    String roomId,
    Map<String, dynamic> fields,
  ) async {
    return _post(ApiConfig.chatRoomMessagesUrl(roomId), body: fields);
  }

  // ── Friends ───────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> searchFriends(String query) async {
    return _getWithQuery(ApiConfig.friendsSearchUrl, <String, String>{
      'q': query,
    });
  }

  // ── Notifications ────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getNotifications() async {
    return _get(ApiConfig.notificationsUrl);
  }

  Future<Map<String, dynamic>> getUnreadNotificationsCount() async {
    final result = await _get(ApiConfig.notificationsUnreadCountUrl);
    if (result['ok'] == true) return result;
    return _getWithQuery(ApiConfig.notificationsUrl, <String, String>{
      'unread': '1',
    });
  }

  Future<Map<String, dynamic>> createNotification(
    Map<String, dynamic> fields,
  ) async {
    return _post(ApiConfig.notificationsUrl, body: fields);
  }

  Future<Map<String, dynamic>> markNotificationAsRead(String id) async {
    return _postToFirstAvailable(
      endpoints: [
        ApiConfig.notificationReadUrl(id),   // POST /api/notifications/{id}/read
        ApiConfig.notificationActionUrl(id), // fallback
      ],
      body: <String, dynamic>{'action': 'read'},
    );
  }

  Future<Map<String, dynamic>> markAllNotificationsAsRead() async {
    return _postToFirstAvailable(
      endpoints: [
        ApiConfig.notificationsMarkAllReadUrl,    // POST /api/notifications/read-all
        ApiConfig.notificationsMarkAllReadAltUrl, // fallback
      ],
      body: {},
    );
  }

  // ── Settings ─────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getSettings() async {
    return _get(ApiConfig.settingsUrl);
  }

  Future<Map<String, dynamic>> updateLanguageSettings(
    Map<String, dynamic> fields,
  ) async {
    return _put(ApiConfig.settingsLanguageUrl, body: fields);
  }

  Future<Map<String, dynamic>> updateThemeSettings(
    Map<String, dynamic> fields,
  ) async {
    return _put(ApiConfig.settingsThemeUrl, body: fields);
  }

  // ── Shorts / Reels fetch ─────────────────────────────────────────────────
  Future<Map<String, dynamic>> getShorts({Map<String, dynamic>? fields}) async {
    return _post(ApiConfig.api('get_shorts'), body: fields ?? {});
  }

  // ── Comments ─────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> addComment({
    required String challengeId,
    required String description,
  }) async {
    final rawId = challengeId.replaceFirst(RegExp(r'^(api_|my_|public_)'), '');
    return _post(ApiConfig.api('comment'), body: {
      'challenge_id': rawId,
      'description': description,
      'message': description,
    });
  }

  Future<Map<String, dynamic>> likeComment(String commentId) async {
    return _post(ApiConfig.api('like_comment'), body: {'comment_id': commentId});
  }

  // ── Report ───────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> report({
    required String targetId,
    required String targetType, // 'challenge' | 'reel' | 'user'
    String reason = '',
  }) async {
    return _post(ApiConfig.api('report'), body: {
      'id': targetId,
      'type': targetType,
      'reason': reason,
    });
  }

  // ── FCM Token ────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> updateFcmToken(String fcmToken) async {
    return _post(ApiConfig.api('update_fcm'), body: {
      'fcm_token': fcmToken,
      'fcm': fcmToken,
    });
  }

  // ── Social Detail (followers/following/likes counts) ─────────────────────
  Future<Map<String, dynamic>> getSocialDetail({String? userId}) async {
    return _post(ApiConfig.api('social_detail'), body: {
      if (userId != null) 'user_id': userId,
    });
  }

  // ── Recipes ──────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> addRecipe(Map<String, dynamic> fields) async {
    return _post(ApiConfig.api('add_recipe'), body: fields);
  }

  Future<Map<String, dynamic>> getRecipes() async {
    return _post(ApiConfig.api('get_recipes'), body: {});
  }

  // ── Food Logs ────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> createFoodLog(Map<String, dynamic> fields) async {
    return _post(ApiConfig.createFoodLogUrl, body: fields);
  }

  Future<Map<String, dynamic>> getMyFoodLogs() async {
    return _get(ApiConfig.myFoodLogsUrl);
  }

  Future<Map<String, dynamic>> deleteFoodLog(String foodLogId) async {
    return _post(ApiConfig.deleteFoodLogUrl, body: {'food_log_id': foodLogId});
  }

  Future<Map<String, dynamic>> likeFoodLog(String foodLogId) async {
    return _post(ApiConfig.likeFoodLogUrl, body: {'food_log_id': foodLogId});
  }

  // ── Leaderboard ──────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getLeaderboard() async {
    return _postToFirstAvailable(
      endpoints: [ApiConfig.leaderboardUrl],
      body: {},
      useGet: true,
    );
  }

  // ── Steps ────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getStepsSummary({String range = 'week'}) async {
    return _getWithQuery(ApiConfig.stepsSummaryUrl, <String, String>{
      'range': range,
    });
  }

  // ── Subscriptions ────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getSubscriptionPlans() async {
    return _get(ApiConfig.appSubscriptionPlansUrl);
  }

  Future<Map<String, dynamic>> checkoutSubscription(
    Map<String, dynamic> fields,
  ) async {
    return _post(ApiConfig.appSubscriptionCheckoutUrl, body: fields);
  }

  // ── Reels ────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> toggleReelReaction({
    required String reelId,
    required String reactionType,
    required bool isActive,
  }) async {
    final cleaned = reactionType.trim().toLowerCase();
    return _postToFirstAvailable(
      endpoints: <String>[
        ApiConfig.reelReactionByTypeUrl(reelId, cleaned),
        ApiConfig.reelReactionsUrl(reelId),
        ApiConfig.reelsReactionsUrl,
        ApiConfig.root('reels/$reelId/reactions'),
        ApiConfig.root('reels/reactions'),
      ],
      body: <String, dynamic>{
        'reel_id': reelId,
        'reaction': cleaned,
        'type': cleaned,
        'is_active': isActive,
        'active': isActive,
        'value': isActive ? 1 : 0,
      },
    );
  }

  // ── Users / Follow ────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> followUser({
    required String userId,
    required bool follow,
  }) async {
    return _postToFirstAvailable(
      endpoints: <String>[
        ApiConfig.followUserUrl(userId),
        ApiConfig.usersFollowUrl,
        ApiConfig.root('users/$userId/follow'),
        ApiConfig.root('users/follow'),
      ],
      body: <String, dynamic>{
        'user_id': userId,
        'follow': follow,
        'is_following': follow,
        'action': follow ? 'follow' : 'unfollow',
      },
    );
  }

  // ── Private HTTP helpers ──────────────────────────────────────────────────
  static const Duration _timeout = Duration(seconds: 20);

  Future<Map<String, dynamic>> _get(String url) async {
    try {
      final token = await _authService.getToken();
      final response = await http
          .get(Uri.parse(url), headers: _jsonHeaders(token))
          .timeout(_timeout);
      return _toResult(response);
    } catch (_) {
      return _timeoutResult();
    }
  }

  Future<Map<String, dynamic>> _post(
    String url, {
    required Map<String, dynamic> body,
  }) async {
    try {
      final token = await _authService.getToken();
      if (kDebugMode) {
        debugPrint('API POST → $url');
        debugPrint('API BODY → ${jsonEncode(body)}');
      }
      final response = await http
          .post(
            Uri.parse(url),
            headers: _jsonHeaders(token),
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      if (kDebugMode) {
        debugPrint('API STATUS → ${response.statusCode}');
        debugPrint('API RESPONSE → ${response.body}');
      }
      return _toResult(response);
    } catch (e) {
      if (kDebugMode) debugPrint('API POST ERROR → $e');
      return _timeoutResult();
    }
  }

  Future<Map<String, dynamic>> _put(
    String url, {
    required Map<String, dynamic> body,
  }) async {
    try {
      final token = await _authService.getToken();
      final response = await http
          .put(
            Uri.parse(url),
            headers: _jsonHeaders(token),
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      return _toResult(response);
    } catch (_) {
      return _timeoutResult();
    }
  }

  Future<Map<String, dynamic>> _delete(String url) async {
    try {
      final token = await _authService.getToken();
      final response = await http
          .delete(Uri.parse(url), headers: _jsonHeaders(token))
          .timeout(_timeout);
      return _toResult(response);
    } catch (_) {
      return _timeoutResult();
    }
  }

  Future<Map<String, dynamic>> _getWithQuery(
    String url,
    Map<String, String> query,
  ) async {
    try {
      final token = await _authService.getToken();
      final uri = Uri.parse(url).replace(queryParameters: query);
      final response = await http
          .get(uri, headers: _jsonHeaders(token))
          .timeout(_timeout);
      return _toResult(response);
    } catch (_) {
      return _timeoutResult();
    }
  }

  Map<String, dynamic> _timeoutResult() => <String, dynamic>{
    'ok': false,
    'statusCode': 0,
    'data': <String, dynamic>{'message': 'Unable to connect to server'},
  };

  Future<Map<String, dynamic>> _postToFirstAvailable({
    required List<String> endpoints,
    required Map<String, dynamic> body,
    bool useGet = false,
  }) async {
    final tried = <Map<String, dynamic>>[];

    for (final url in endpoints) {
      final result = useGet ? await _get(url) : await _post(url, body: body);
      if (result['ok'] == true) {
        result['endpoint'] = url;
        return result;
      }
      final statusCode = result['statusCode'] as int? ?? 0;
      tried.add({'endpoint': url, 'statusCode': statusCode});
      if (statusCode >= 500 || statusCode == 401 || statusCode == 403) {
        return <String, dynamic>{...result, 'tried': tried};
      }
    }

    return <String, dynamic>{
      'ok': false,
      'statusCode': tried.isNotEmpty ? tried.last['statusCode'] : 404,
      'data': <String, dynamic>{
        'message': 'No matching endpoint accepted the request',
        'tried': tried,
      },
    };
  }

  Map<String, String> _jsonHeaders(String? token) => <String, String>{
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    ..._authHeaders(token),
  };

  Map<String, String> _authHeaders(String? token) {
    if (token == null || token.trim().isEmpty) return {};
    return {'Authorization': 'Bearer $token'};
  }

  Map<String, dynamic> _toResult(http.Response response) {
    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      decoded = null;
    }
    final data = decoded is Map<String, dynamic>
        ? decoded
        : <String, dynamic>{'raw': response.body};
    return <String, dynamic>{
      'ok': response.statusCode >= 200 && response.statusCode < 300,
      'statusCode': response.statusCode,
      'data': data,
    };
  }
}
