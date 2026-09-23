import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:it_helpdesk_client/shared/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiException implements Exception {
  final String code;
  final String message;
  final Map<String, dynamic> details;
  final int statusCode;

  ApiException({
    required this.code,
    required this.message,
    required this.details,
    required this.statusCode,
  });

  @override
  String toString() => 'ApiException [$code] ($statusCode): $message';
}

class ApiClient {
  String? _activeBaseUrl;

  ApiClient({String? baseUrl}) : _activeBaseUrl = baseUrl;

  String get baseUrl => _activeBaseUrl ?? AppConstants.defaultApiBaseUrl;

  Future<Map<String, String>> _getHeaders({bool isMultipart = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.keyAccessToken);

    final headers = <String, String>{
      if (!isMultipart) 'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  dynamic _handleResponse(http.Response response) {
    dynamic body;
    try {
      body = jsonDecode(utf8.decode(response.bodyBytes));
    } catch (_) {
      body = {'error': {'code': 'PARSE_ERROR', 'message': response.body, 'details': {}}};
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    if (body is Map<String, dynamic> && body.containsKey('error')) {
      final err = body['error'];
      throw ApiException(
        code: err['code'] ?? 'UNKNOWN_ERROR',
        message: err['message'] ?? 'An unexpected error occurred',
        details: err['details'] is Map<String, dynamic> ? err['details'] : {},
        statusCode: response.statusCode,
      );
    }

    throw ApiException(
      code: 'HTTP_${response.statusCode}',
      message: 'Server error: ${response.statusCode}',
      details: {},
      statusCode: response.statusCode,
    );
  }

  /// Executes request with automatic multi-host fallback across USB ADB reverse & Wi-Fi LAN
  Future<dynamic> _executeWithFallback(Future<http.Response> Function(String currentBaseUrl) requestBuilder) async {
    final candidates = [
      if (_activeBaseUrl != null) _activeBaseUrl!,
      ...AppConstants.candidateApiBaseUrls.where((u) => u != _activeBaseUrl),
    ];

    ApiException? lastException;

    for (final candidate in candidates) {
      try {
        final response = await requestBuilder(candidate).timeout(const Duration(seconds: 15));
        _activeBaseUrl = candidate;
        return _handleResponse(response);
      } on TimeoutException {
        debugPrint('[ApiClient] TimeoutException for $candidate');
        lastException = ApiException(
          code: 'TIMEOUT',
          message: 'The request timed out. Please check your connection and try again.',
          details: {'host': candidate},
          statusCode: 0,
        );
      } on http.ClientException catch (e) {
        debugPrint('[ApiClient] ClientException for $candidate: ${e.message}');
        lastException = ApiException(
          code: 'CONNECTION_ERROR',
          message: 'Connection failed. Please verify the server is reachable.',
          details: {'original': e.message, 'host': candidate},
          statusCode: 0,
        );
      } catch (e) {
        debugPrint('[ApiClient] Error for $candidate: $e');
        lastException = ApiException(
          code: 'CONNECTION_ERROR',
          message: 'Could not connect to backend server.',
          details: {'host': candidate, 'error': e.toString()},
          statusCode: 0,
        );
      }
    }

    throw lastException ??
        ApiException(
          code: 'CONNECTION_FAILED',
          message: 'Could not reach backend server on any configured address.',
          details: {},
          statusCode: 0,
        );
  }

  Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParams}) async {
    final headers = await _getHeaders();
    return _executeWithFallback((host) {
      final uri = Uri.parse('$host$endpoint').replace(queryParameters: queryParams?.map((k, v) => MapEntry(k, v.toString())));
      return http.get(uri, headers: headers);
    });
  }

  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    final headers = await _getHeaders();
    return _executeWithFallback((host) {
      final uri = Uri.parse('$host$endpoint');
      return http.post(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
    });
  }

  Future<dynamic> patch(String endpoint, {Map<String, dynamic>? body}) async {
    final headers = await _getHeaders();
    return _executeWithFallback((host) {
      final uri = Uri.parse('$host$endpoint');
      return http.patch(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
    });
  }

  Future<dynamic> delete(String endpoint) async {
    final headers = await _getHeaders();
    return _executeWithFallback((host) {
      final uri = Uri.parse('$host$endpoint');
      return http.delete(uri, headers: headers);
    });
  }
}

final apiClient = ApiClient();
