class ApiConfig {
  static const String _hostOverride = String.fromEnvironment('API_HOST');
  static const String _defaultLanHost = '192.168.2.104';
  static const String _port = '8000';

  static String get _host {
    if (_hostOverride.trim().isNotEmpty) return _hostOverride.trim();
    return _defaultLanHost;
  }

  static String get baseUrl => 'http://$_host:$_port';
  static String get authBaseUrl => 'http://$_host:$_port/api/auth';

  static String api(String path) => _join([baseUrl, 'api', path]);
  static String auth(String path) => _join([authBaseUrl, path]);
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

  static String onboarding(String path) =>
      _join([baseUrl, 'api', 'onboarding', path]);

  static String get homeUrl => api('home');

  static String get profileUrl => api('profile');
  static String get profileImageUrl => api('profile/image');

  static String get challengeCategoriesUrl => api('challenges/categories');
  static String get currentChallengeUrl => api('challenges/current');
  static String get startRandomChallengeUrl => api('challenges/start-random');
  static String challengeProgressUrl(String id) =>
      api('challenges/$id/progress');
  static String challengeByIdUrl(String id) => api('challenges/$id');

  static String get notificationsUrl => api('notifications');
  static String get notificationsUnreadCountUrl =>
      api('notifications/unread-count');
  static String notificationReadUrl(String id) => api('notifications/$id/read');
  static String get notificationsReadAllUrl => api('notifications/read-all');

  static String get onboardingSaveUrl => onboarding('save');
  static String get onboardingGetUrl => onboarding('get');

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
