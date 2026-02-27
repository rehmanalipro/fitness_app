import 'dart:convert';
import 'dart:io';

import 'package:fitness_app/core/network/api_config.dart';
import 'package:fitness_app/features/auth/services/auth_service.dart';
import 'package:http/http.dart' as http;

class AppApiService {
  final AuthService _authService = AuthService();

  Future<Map<String, dynamic>> getHome() async {
    return _get(ApiConfig.homeUrl);
  }

  Future<Map<String, dynamic>> getProfile() async {
    return _get(ApiConfig.profileUrl);
  }

  Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> fields,
  ) async {
    return _post(ApiConfig.profileUrl, body: fields);
  }

  Future<Map<String, dynamic>> uploadProfileImage(File imageFile) async {
    final token = await _authService.getToken();
    final uri = Uri.parse(ApiConfig.profileImageUrl);
    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll(_authHeaders(token));
    request.files.add(
      await http.MultipartFile.fromPath('image', imageFile.path),
    );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    return _toResult(response);
  }

  Future<Map<String, dynamic>> getChallengeCategories() async {
    return _get(ApiConfig.challengeCategoriesUrl);
  }

  Future<Map<String, dynamic>> getCurrentChallenge() async {
    return _get(ApiConfig.currentChallengeUrl);
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
    return _post(ApiConfig.challengeProgressUrl(id), body: fields);
  }

  Future<Map<String, dynamic>> deleteChallenge(String id) async {
    return _delete(ApiConfig.challengeByIdUrl(id));
  }

  Future<Map<String, dynamic>> getNotifications() async {
    return _get(ApiConfig.notificationsUrl);
  }

  Future<Map<String, dynamic>> getUnreadNotificationsCount() async {
    return _get(ApiConfig.notificationsUnreadCountUrl);
  }

  Future<Map<String, dynamic>> createNotification(
    Map<String, dynamic> fields,
  ) async {
    return _post(ApiConfig.notificationsUrl, body: fields);
  }

  Future<Map<String, dynamic>> markNotificationAsRead(String id) async {
    return _post(ApiConfig.notificationReadUrl(id), body: {});
  }

  Future<Map<String, dynamic>> markAllNotificationsAsRead() async {
    return _post(ApiConfig.notificationsReadAllUrl, body: {});
  }

  Future<Map<String, dynamic>> _get(String url) async {
    final token = await _authService.getToken();
    final response = await http.get(
      Uri.parse(url),
      headers: _jsonHeaders(token),
    );
    return _toResult(response);
  }

  Future<Map<String, dynamic>> _post(
    String url, {
    required Map<String, dynamic> body,
  }) async {
    final token = await _authService.getToken();
    final response = await http.post(
      Uri.parse(url),
      headers: _jsonHeaders(token),
      body: jsonEncode(body),
    );
    return _toResult(response);
  }

  Future<Map<String, dynamic>> _delete(String url) async {
    final token = await _authService.getToken();
    final response = await http.delete(
      Uri.parse(url),
      headers: _jsonHeaders(token),
    );
    return _toResult(response);
  }

  Map<String, String> _jsonHeaders(String? token) {
    return <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ..._authHeaders(token),
    };
  }

  Map<String, String> _authHeaders(String? token) {
    if (token == null || token.trim().isEmpty) return <String, String>{};
    return <String, String>{'Authorization': 'Bearer $token'};
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
