/// ModivFit API configuration.
/// Base: http://<host>:8000/api
/// Auth: Bearer token (Laravel Sanctum)
/// Response shape: { "success": bool, "message": String, "token"?: String, "data"?: Map }
class ApiConfig {
  ApiConfig._();

  static const String _hostOverride = String.fromEnvironment('API_HOST');
  static const String _defaultHost = '192.168.2.101';
  static const String _port = '8000';

  static String get _host =>
      _hostOverride.trim().isNotEmpty ? _hostOverride.trim() : _defaultHost;

  // ── Base URLs ─────────────────────────────────────────────────────────────
  static String get baseUrl => 'http://$_host:$_port';

  // ── URL builders ──────────────────────────────────────────────────────────
  static String api(String path) => _join([baseUrl, 'api', path]);
  static String root(String path) => _join([baseUrl, path]);
  static String auth(String path) => _join([baseUrl, 'api', 'auth', path]);
  static String onboarding(String path) =>
      _join([baseUrl, 'api', 'onboarding', path]);

  // ── Auth ──────────────────────────────────────────────────────────────────
  static String get authSignupUrl => auth('signup');
  static String get authLoginUrl => auth('login');
  static String get authSigninUrl => auth('signin');
  static String get authForgotPasswordUrl => auth('forgot-password');
  static String get authVerifySignupOtpUrl => auth('verify-signup-otp');
  static String get authVerifyForgotOtpUrl => auth('verify-forgot-otp');
  static String get authVerifyChangePasswordOtpUrl =>
      auth('verify-change-password-otp');
  static String get authResetPasswordUrl => auth('reset-password');
  static String get authSendChangePasswordOtpUrl =>
      auth('send-change-password-otp');
  static String get authChangePasswordUrl => auth('change-password');
  static String get authConfirmPasswordUrl => auth('confirm-password');

  // ── Onboarding ────────────────────────────────────────────────────────────
  static String get onboardingSaveUrl => onboarding('save');

  // ── Home ──────────────────────────────────────────────────────────────────
  static String get homeUrl => api('home');

  // ── User / Profile ────────────────────────────────────────────────────────
  // GET  /api/user_profile  — get profile
  // POST /api/update_profile — update profile
  // POST /api/update_profile_img — upload image
  static String get getUserProfileUrl => api('user_profile');
  static String get updateProfileUrl => api('update_profile');
  static String get profileImageUrl => api('update_profile_img');
  static String get profileMediaUrl => api('profile/media');
  // Aliases kept for fallback in service
  static String get profileUrl => api('profile');

  // ── Feed / Media Posts ────────────────────────────────────────────────────
  static String get mediaPostsUrl => api('posts/media');

  // ── Challenges ────────────────────────────────────────────────────────────
  static String get challengesUrl => api('challenges');
  static String get allChallengesUrl => api('all_challenges');
  static String get createChallengeUrl => api('create_challenge');
  static String get acceptChallengeUrl => api('accept_challenge');
  static String get likeChallengeUrl => api('like_challenge');
  static String get challengeCategoriesUrl => api('challenges/categories');
  static String get currentChallengeUrl => api('challenges/current');
  static String get startRandomChallengeUrl => api('challenges/start-random');
  static String get challengeLimitsUrl => api('challenges/limits');
  static String get challengeLimitsExtendUrl => api('challenges/limits/extend');
  static String get challengeCardsUrl => api('challenges/cards');
  static String challengeByIdUrl(String id) => api('challenges/$id');
  static String challengeRecordUrl(String id) => api('challenges/$id/record');

  // Keep alias used by service (currentChallengeByIdUrl → challengeByIdUrl)
  static String currentChallengeByIdUrl(String id) => challengeByIdUrl(id);

  // ── Reels ─────────────────────────────────────────────────────────────────
  static String get reelsReactionsUrl => api('reels/reactions');
  static String reelReactionsUrl(String reelId) =>
      api('reels/$reelId/reactions');
  static String reelReactionByTypeUrl(String reelId, String type) =>
      api('reels/$reelId/reactions/$type');

  // ── Social / Follow ───────────────────────────────────────────────────────
  static String get usersFollowUrl => api('users/follow');
  static String followUserUrl(String userId) => api('users/$userId/follow');
  static String get friendsSearchUrl => api('friends/search');

  // ── Guides ────────────────────────────────────────────────────────────────
  static String get guidesUrl => api('guides');
  static String get guidesPostsUrl => api('guides/posts');
  static String guidePostLikeUrl(String id) => api('guides/posts/$id/like');
  static String guidePostReplyUrl(String id) => api('guides/posts/$id/reply');

  // ── Chat ──────────────────────────────────────────────────────────────────
  static String get chatRoomsUrl => api('chat/rooms');
  static String chatRoomInviteUrl(String roomId) =>
      api('chat/rooms/$roomId/invite');
  static String chatRoomMessagesUrl(String roomId) =>
      api('chat/rooms/$roomId/messages');

  // ── Food Logs ─────────────────────────────────────────────────────────────
  static String get createFoodLogUrl => api('create_food_log');
  static String get myFoodLogsUrl => api('my_food_logs');
  static String get allFoodLogsUrl => api('all_food_logs');
  static String get deleteFoodLogUrl => api('delete_food_log');
  static String get likeFoodLogUrl => api('like_food_log');

  // ── Leaderboard ───────────────────────────────────────────────────────────
  static String get leaderboardUrl => api('leaderboard');

  // ── Notifications ─────────────────────────────────────────────────────────
  static String get notificationsUrl => api('notifications');
  static String get notificationsUnreadCountUrl =>
      api('notifications/unread-count');
  // Backend: POST /api/notifications/{id}/read
  static String notificationReadUrl(String id) => api('notifications/$id/read');
  static String notificationActionUrl(String id) =>
      api('notifications/$id/action'); // fallback alias
  static String get notificationsMarkAllReadUrl => api('notifications/read-all');
  static String get notificationsMarkAllReadAltUrl =>
      api('notifications/mark-all-read'); // fallback

  // ── Settings ──────────────────────────────────────────────────────────────
  static String get settingsUrl => api('settings');
  static String get settingsLanguageUrl => api('settings/language');
  static String get settingsThemeUrl => api('settings/theme');

  // ── Steps ─────────────────────────────────────────────────────────────────
  static String get stepsSummaryUrl => api('steps/summary');

  // ── Subscriptions ─────────────────────────────────────────────────────────
  static String get subscriptionUrl => api('subscription');
  static String get subscriptionsUrl => api('subscriptions');
  static String get subscriptionSelectUrl => api('subscription/select');
  static String get subscriptionsSelectUrl => api('subscriptions/select');
  static String get subscriptionPlanUrl => api('subscription/plan');
  static String get subscriptionsPlanUrl => api('subscriptions/plan');
  static String get appSubscriptionPlansUrl => api('subscriptions/plans');
  static String get appSubscriptionCheckoutUrl => api('subscriptions/checkout');

  // ── Private helper ────────────────────────────────────────────────────────
  static String _join(List<String> parts) {
    final cleaned = parts
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .map((p) => p.replaceAll(RegExp(r'^/+|/+$'), ''))
        .toList();
    if (cleaned.isEmpty) return '';
    return cleaned.first +
        (cleaned.length > 1 ? '/${cleaned.skip(1).join('/')}' : '');
  }
}
