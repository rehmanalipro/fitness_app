import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitness_app/core/network/api_config.dart';

class AuthResult {
  final bool success;
  final String message;
  final String? token;
  final String? otp;

  const AuthResult({
    required this.success,
    required this.message,
    this.token,
    this.otp,
  });
}

class AuthService {
  static const _tokenKey = 'auth_token';
  static const _emailKey = 'auth_email';

  // REGISTER
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final body = {
      'type': 'signup',
      'name': name.trim(),
      'email': email.trim(),
      'password': password,
      if (phone != null && phone.trim().isNotEmpty) 'number': phone.trim(),
    };

    return _authenticate(url: ApiConfig.auth(''), body: body);
  }

  // LOGIN
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final body = {'type': 'login', 'email': email.trim(), 'password': password};

    return _authenticate(url: ApiConfig.auth(''), body: body);
  }

  // FORGOT PASSWORD (SEND OTP)
  Future<AuthResult> forgotPassword({required String email}) async {
    final normalizedEmail = email.trim();

    return _authenticate(
      url: ApiConfig.auth(''),
      body: {'type': 'forgot_password', 'email': normalizedEmail},
    );
  }

  // CORE AUTH METHOD
  Future<AuthResult> _authenticate({
    required String url,
    required Map<String, dynamic> body,
  }) async {
    try {
      if (kDebugMode) {
        final safeBody = Map<String, dynamic>.from(body);
        if (safeBody.containsKey('password')) safeBody['password'] = '***';
        debugPrint('AUTH REQUEST -> $url');
        debugPrint('AUTH BODY -> $safeBody');
      }

      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 20));

      dynamic decoded;
      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        decoded = null;
      }
      final Map<String, dynamic> data = decoded is Map<String, dynamic>
          ? decoded
          : <String, dynamic>{};

      if (kDebugMode) {
        debugPrint('AUTH STATUS -> ${response.statusCode}');
        debugPrint('AUTH RESPONSE -> ${response.body}');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final token = _extractToken(data);
        final email = _extractEmail(data, body);
        final otp = _extractOtp(data);
        if (email != null && email.isNotEmpty) {
          await saveEmail(email);
        }
        if (token != null && token.isNotEmpty) {
          await saveToken(token);
          return AuthResult(
            success: true,
            message: _extractMessage(data) ?? 'Authentication successful',
            token: token,
            otp: otp,
          );
        }
        return AuthResult(
          success: true,
          message: _extractMessage(data) ?? 'Authentication successful',
          otp: otp,
        );
      }

      return AuthResult(
        success: false,
        message:
            _extractMessage(data) ??
            'Authentication failed (${response.statusCode})',
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AUTH ERROR -> $e');
      }
      return const AuthResult(
        success: false,
        message: 'Unable to connect to server',
      );
    }
  }

  String? _extractToken(Map<String, dynamic> data) {
    final direct = data['token'] ?? data['access_token'];
    if (direct is String) return direct;

    final payload = data['data'];
    if (payload is Map<String, dynamic>) {
      final nested = payload['token'] ?? payload['access_token'];
      if (nested is String) return nested;
    }

    return null;
  }

  String? _extractMessage(Map<String, dynamic> data) {
    final message = data['message'];
    if (message is String && message.trim().isNotEmpty) return message;

    final errors = data['errors'];
    if (errors is Map<String, dynamic> && errors.isNotEmpty) {
      final firstError = errors.values.first;
      if (firstError is List && firstError.isNotEmpty) {
        final value = firstError.first;
        if (value is String) return value;
      }
    }

    return null;
  }

  String? _extractEmail(
    Map<String, dynamic> data,
    Map<String, dynamic> requestBody,
  ) {
    final requestEmail = requestBody['email'];
    if (requestEmail is String && requestEmail.trim().isNotEmpty) {
      return requestEmail.trim();
    }

    final direct = data['email'];
    if (direct is String && direct.trim().isNotEmpty) return direct.trim();

    final payload = data['data'];
    if (payload is Map<String, dynamic>) {
      final nested = payload['email'];
      if (nested is String && nested.trim().isNotEmpty) return nested.trim();
    }

    return null;
  }

  String? _extractOtp(Map<String, dynamic> data) {
    final direct = data['otp'];
    if (direct != null) return direct.toString();

    final payload = data['data'];
    if (payload is Map<String, dynamic> && payload['otp'] != null) {
      return payload['otp'].toString();
    }

    return null;
  }

  // SAVE TOKEN
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, email.trim());
  }

  // GET TOKEN
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  // CHECK LOGIN
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // LOGOUT
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_emailKey);
  }
}
