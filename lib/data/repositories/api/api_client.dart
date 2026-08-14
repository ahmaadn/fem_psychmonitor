import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RemoteAuthSessionStore {
  static const _accessTokenKey = 'remote_access_token';
  static const _refreshTokenKey = 'remote_refresh_token';
  static const _syncCursorKey = 'remote_sync_cursor';

  String? accessToken;
  String? refreshToken;
  int syncCursor = 0;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString(_accessTokenKey);
    refreshToken = prefs.getString(_refreshTokenKey);
    syncCursor = prefs.getInt(_syncCursorKey) ?? 0;
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString(_accessTokenKey, accessToken),
      prefs.setString(_refreshTokenKey, refreshToken),
    ]);
  }

  Future<void> saveSyncCursor(int value) async {
    syncCursor = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_syncCursorKey, value);
  }

  Future<void> clearTokens() async {
    accessToken = null;
    refreshToken = null;
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_accessTokenKey),
      prefs.remove(_refreshTokenKey),
    ]);
  }

  Future<void> clearAll() async {
    syncCursor = 0;
    await clearTokens();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_syncCursorKey);
  }
}

class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.code,
    this.isTransportError = false,
  });

  final String message;
  final int? statusCode;
  final String? code;
  final bool isTransportError;

  @override
  String toString() => 'ApiException($statusCode, $code, $message)';
}

class ApiClient {
  ApiClient({
    required String baseUrl,
    required this.sessionStore,
    http.Client? client,
    this.timeout = const Duration(seconds: 8),
  }) : baseUrl = baseUrl.replaceFirst(RegExp(r'/$'), ''),
       _client = client ?? http.Client();

  final String baseUrl;
  final RemoteAuthSessionStore sessionStore;
  final Duration timeout;
  final http.Client _client;
  Future<bool>? _refreshing;

  bool get isEnabled => baseUrl.trim().isNotEmpty;
  bool get hasRemoteSession => sessionStore.accessToken != null;

  Future<Map<String, dynamic>> requestJson(
    String method,
    String path, {
    Object? body,
    bool authenticated = true,
  }) async {
    final response = await request(
      method,
      path,
      body: body,
      authenticated: authenticated,
    );
    if (response.body.isEmpty) return <String, dynamic>{};
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const ApiException(message: 'Invalid JSON response');
    }
    return decoded;
  }

  Future<http.Response> request(
    String method,
    String path, {
    Object? body,
    bool authenticated = true,
    bool retryAfterRefresh = true,
  }) async {
    if (!isEnabled) {
      throw const ApiException(
        message: 'Remote API is disabled',
        isTransportError: true,
      );
    }

    final headers = <String, String>{'accept': 'application/json'};
    if (body != null) headers['content-type'] = 'application/json';
    if (authenticated && sessionStore.accessToken != null) {
      headers['authorization'] = 'Bearer ${sessionStore.accessToken}';
    }

    try {
      final request = http.Request(method, Uri.parse('$baseUrl$path'));
      request.headers.addAll(headers);
      if (body != null) request.body = jsonEncode(body);
      final streamed = await _client.send(request).timeout(timeout);
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 401 &&
          authenticated &&
          retryAfterRefresh &&
          sessionStore.refreshToken != null &&
          await _refresh()) {
        return requestJsonResponse(method, path, body: body);
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw _exceptionFrom(response);
      }
      return response;
    } on ApiException {
      rethrow;
    } on TimeoutException catch (error) {
      throw ApiException(message: error.toString(), isTransportError: true);
    } on http.ClientException catch (error) {
      throw ApiException(message: error.message, isTransportError: true);
    }
  }

  Future<http.Response> requestJsonResponse(
    String method,
    String path, {
    Object? body,
  }) {
    return request(method, path, body: body, retryAfterRefresh: false);
  }

  Future<bool> _refresh() {
    return _refreshing ??= _performRefresh().whenComplete(
      () => _refreshing = null,
    );
  }

  Future<bool> _performRefresh() async {
    final refreshToken = sessionStore.refreshToken;
    if (refreshToken == null) return false;
    try {
      final response = await requestJson(
        'POST',
        '/auth/refresh',
        body: {'refreshToken': refreshToken},
        authenticated: false,
      );
      final access = response['accessToken'] as String?;
      final refresh = response['refreshToken'] as String?;
      if (access == null || refresh == null) return false;
      await sessionStore.saveTokens(accessToken: access, refreshToken: refresh);
      return true;
    } catch (error) {
      debugPrint('[remote] token refresh failed: $error');
      await sessionStore.clearTokens();
      return false;
    }
  }

  ApiException _exceptionFrom(http.Response response) {
    String message = 'Request failed';
    String? code;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final rawError = decoded['error'];
        if (rawError is Map<String, dynamic>) {
          message = rawError['message'] as String? ?? message;
          code = rawError['code'] as String?;
        }
      }
    } catch (_) {}
    return ApiException(
      message: message,
      statusCode: response.statusCode,
      code: code,
    );
  }

  void close() => _client.close();
}
