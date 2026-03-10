class ApiConfig {
  static const String _hostOverride = String.fromEnvironment('API_HOST');
  static const String _defaultLanHost = '192.168.2.107';
  static const String _port = '8000';

  static String get _host {
    if (_hostOverride.trim().isNotEmpty) return _hostOverride.trim();
    return _defaultLanHost;
  }

  static String get baseUrl => 'http://$_host:$_port';
  static String get authBaseUrl => 'http://$_host:$_port/api/auth';

  // ── Helpers ──────────────────────────────────────────────────────────────
  static String api(String path) => _join([baseUrl, 'api', path]);
  static String root(String path) => _join([baseUrl, path]);
  static String auth(String path) => _join([authBaseUrl, path]);

  // ── Auth ──────────────────────────────────────────────────────────────
  static String forgotPassword() => _join([authBaseUrl, 'forgot-password']);
  static String get authSignupUrl => auth('signup');
  static String get authSigninUrl => auth('signin');
  static String get authLoginUrl => auth('login');
  static String get authVerifySignupOtpUrl => auth('verify-signup-otp');
  static String get authForgotPasswordUrl => auth('forgot-password');
  static String get authVerifyForgotOtpUrl => auth('verify-forgot-otp');
  static String get authVerifyChangePasswordOtpUrl =>
      auth('verify-change-password-otp');
  static String get authResetPasswordUrl => auth('reset-password');
  static String get authSendChangePasswordOtpUrl =>
      auth('send-change-password-otp');
  static String get authChangePasswordUrl => auth('change-password');
  static String get authConfirmPasswordUrl => auth('confirm-password');

  // ── Onboarding ───────────────────────────────────────────────────────────
  static String onboarding(String path) =>
      _join([baseUrl, 'api', 'onboarding', path]);
  static String get onboardingSaveUrl => onboarding('save');
  static String get onboardingGetUrl => onboarding('get');

  // ── Home ─────────────────────────────────────────────────────────────────
  static String get homeUrl => api('home');

  // ── Profile ──────────────────────────────────────────────────────────────
  static String get profileUrl => api('profile');
  static String get profileImageUrl => api('profile/image');
  static String get profileMediaUrl => api('profile/media'); // IGNORE --

  // ── Challenges ───────────────────────────────────────────────────────────
  static String get challengesUrl => api('challenges');
  static String get challengeCategoriesUrl => api('challenges/categories');
  static String get currentChallengeUrl => api('challenges/current');
  static String get startRandomChallengeUrl => api('challenges/start-random');
  static String get challengeLimitsUrl => api('challenges/limits');
  static String get challengeLimitsExtendUrl => api('challenges/limits/extend');
  static String get challengeCardsUrl => api('challenges/cards');
  static String currentChallengeByIdUrl(String id) => api('challenges/$id');
  static String challengeByIdUrl(String id) => api('challenges/$id');
  static String challengeProgressUrl(String id) =>
      api('challenges/$id/progress');
  static String challengeRecordUrl(String id) => api('challenges/$id/record');

  // ── Media / Posts ────────────────────────────────────────────────────────
  static String get mediaPostsUrl => api('posts/media');

  // ── Reels ────────────────────────────────────────────────────────────────
  static String get reelsReactionsUrl => api('reels/reactions');
  static String reelReactionsUrl(String reelId) =>
      api('reels/$reelId/reactions');
  static String reelReactionByTypeUrl(String reelId, String type) =>
      api('reels/$reelId/reactions/$type');

  // ── Guides ───────────────────────────────────────────────────────────────
  static String get guidesUrl => api('guides');
  static String get guidesPostsUrl => api('guides/posts');
  static String guidePostLikeUrl(String id) => api('guides/posts/$id/like');
  static String guidePostReplyUrl(String id) => api('guides/posts/$id/reply');

  // ── Chat ─────────────────────────────────────────────────────────────────
  static String get chatRoomsUrl => api('chat/rooms');
  static String chatRoomInviteUrl(String roomId) =>
      api('chat/rooms/$roomId/invite');
  static String chatRoomMessagesUrl(String roomId) =>
      api('chat/rooms/$roomId/messages');

  // ── Friends ───────────────────────────────────────────────────────────────
  static String get friendsSearchUrl => api('friends/search');

  // ── Users / Follow ────────────────────────────────────────────────────────
  static String get usersFollowUrl => api('users/follow');
  static String followUserUrl(String userId) => api('users/$userId/follow');

  // ── Notifications ────────────────────────────────────────────────────────
  static String get notificationsUrl => api('notifications');
  static String get notificationsUnreadCountUrl =>
      api('notifications/unread-count');
  static String notificationReadUrl(String id) => api('notifications/$id/read');
  static String notificationActionUrl(String id) =>
      api('notifications/$id/action');
  static String get notificationsReadAllUrl => api('notifications/read-all');
  static String get notificationsMarkAllReadUrl =>
      api('notifications/mark-all-read');

  // ── Settings ─────────────────────────────────────────────────────────────
  static String get settingsUrl => api('settings');
  static String get settingsLanguageUrl => api('settings/language');
  static String get settingsThemeUrl => api('settings/theme');

  // ── Steps ────────────────────────────────────────────────────────────────
  static String get stepsSummaryUrl => api('steps/summary');

  // ── Subscriptions ────────────────────────────────────────────────────────
  static String get subscriptionSelectUrl => api('subscription/select');
  static String get subscriptionsSelectUrl => api('subscriptions/select');
  static String get subscriptionUrl => api('subscription');
  static String get subscriptionsUrl => api('subscriptions');
  static String get subscriptionPlanUrl => api('subscription/plan');
  static String get subscriptionsPlanUrl => api('subscriptions/plan');
  static String get appSubscriptionPlansUrl => api('subscriptions/plans');
  static String get appSubscriptionCheckoutUrl => api('subscriptions/checkout');

  // ── Private helper ───────────────────────────────────────────────────────
  static String _join(List<String> parts) {
    final cleaned = parts
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .map((p) => p.replaceAll(RegExp(r'^/+|/+$'), ''))
        .toList();

    return cleaned.isEmpty
        ? ''
        : cleaned.first +
              (cleaned.length > 1 ? '/${cleaned.skip(1).join('/')}' : '');
  }
}
