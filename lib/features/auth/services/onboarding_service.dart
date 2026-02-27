import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:fitness_app/core/network/api_config.dart';
import 'package:fitness_app/features/auth/services/auth_service.dart';

class OnboardingResult {
  final bool success;
  final String message;

  const OnboardingResult({required this.success, required this.message});
}

class OnboardingService {
  final AuthService _authService = AuthService();

  Future<OnboardingResult> saveStep({
    required String step,
    required Map<String, dynamic> data,
  }) async {
    try {
      final token = await _authService.getToken();
      final email = await _authService.getEmail();
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final basePayload = <String, dynamic>{
        ..._withAliases(data),
        'step': step,
        'onboarding_step': step,
        if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
      };
      final urls = _candidateUrls(step);
      final payloads = _candidatePayloads(basePayload, step);
      http.Response? lastResponse;
      Map<String, dynamic> lastDecoded = <String, dynamic>{};

      for (final url in urls) {
        for (final payload in payloads) {
          final response = await http
              .post(Uri.parse(url), headers: headers, body: jsonEncode(payload))
              .timeout(const Duration(seconds: 20));
          lastResponse = response;

          dynamic decoded;
          try {
            decoded = jsonDecode(response.body);
          } catch (_) {
            decoded = null;
          }
          lastDecoded = decoded is Map<String, dynamic>
              ? decoded
              : <String, dynamic>{};

          if (kDebugMode) {
            debugPrint('ONBOARDING STEP -> $step');
            debugPrint('ONBOARDING URL -> $url');
            debugPrint('ONBOARDING PAYLOAD -> $payload');
            debugPrint('ONBOARDING STATUS -> ${response.statusCode}');
            debugPrint('ONBOARDING RESPONSE -> ${response.body}');
          }

          if (response.statusCode >= 200 && response.statusCode < 300) {
            return OnboardingResult(
              success: true,
              message: _extractMessage(lastDecoded) ?? 'Saved successfully',
            );
          }

          if (response.statusCode == 404) {
            break;
          }

          if (_isInvalidType(lastDecoded)) {
            continue;
          }

          return OnboardingResult(
            success: false,
            message:
                _extractMessage(lastDecoded) ??
                'Failed to save step ($step) (${response.statusCode})',
          );
        }
      }

      final code = lastResponse?.statusCode ?? 404;
      return OnboardingResult(
        success: false,
        message:
            _extractMessage(lastDecoded) ??
            'Failed to save step ($step) ($code): endpoint not found',
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ONBOARDING ERROR -> $e');
      }
      return const OnboardingResult(
        success: false,
        message: 'Unable to connect to server',
      );
    }
  }

  List<Map<String, dynamic>> _candidatePayloads(
    Map<String, dynamic> basePayload,
    String step,
  ) {
    return <Map<String, dynamic>>[
      {...basePayload, 'type': 'onboarding'},
      {...basePayload, 'type': step},
      {...basePayload, 'type': 'profile_update'},
      {...basePayload},
    ];
  }

  List<String> _candidateUrls(String step) {
    return <String>[
      ApiConfig.onboardingSaveUrl,
      ApiConfig.auth(''),
      ApiConfig.auth('onboarding'),
      ApiConfig.auth('onboarding/$step'),
      ApiConfig.onboarding(step),
      ApiConfig.onboarding(''),
    ];
  }

  Map<String, dynamic> _withAliases(Map<String, dynamic> data) {
    final map = <String, dynamic>{...data};

    final fitnessLevel = data['fitness_level'];
    if (fitnessLevel != null) map['fitnessLevel'] = fitnessLevel;

    final heightValue = data['height_value'];
    final heightUnit = data['height_unit'];
    if (heightValue != null) map['height'] = heightValue;
    if (heightUnit != null) map['heightUnit'] = heightUnit;

    final weightValue = data['weight_value'];
    final weightUnit = data['weight_unit'];
    if (weightValue != null) map['weight'] = weightValue;
    if (weightUnit != null) map['weightUnit'] = weightUnit;

    return map;
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

  bool _isInvalidType(Map<String, dynamic> data) {
    final message = _extractMessage(data);
    if (message == null) return false;
    final normalized = message.toLowerCase();
    return normalized.contains('invalid request type') ||
        normalized.contains('invalid type');
  }
}
