class ApiConfig {
  static const String _hostOverride = String.fromEnvironment('API_HOST');
  static const String _defaultLanHost = '192.168.2.113';
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

  static String onboarding(String path) =>
      _join([baseUrl, 'api', 'onboarding', path]);

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
