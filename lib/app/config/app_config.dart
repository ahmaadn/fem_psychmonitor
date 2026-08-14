import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig._();

  static const String _configuredApiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
  );
  static const int apiTimeoutSeconds = int.fromEnvironment(
    'API_TIMEOUT_SECONDS',
    defaultValue: 8,
  );

  static String get apiBaseUrl => resolveApiBaseUrl(
    configuredUrl: _configuredApiBaseUrl,
    isWeb: kIsWeb,
    targetPlatform: defaultTargetPlatform,
  );

  @visibleForTesting
  static String resolveApiBaseUrl({
    required String configuredUrl,
    required bool isWeb,
    required TargetPlatform targetPlatform,
  }) {
    final configured = configuredUrl.trim();
    final raw = configured.isNotEmpty
        ? configured
        : isWeb || targetPlatform != TargetPlatform.android
        ? 'http://localhost:3000'
        : 'http://10.0.2.2:3000';
    final withoutTrailingSlash = raw.replaceFirst(RegExp(r'/+$'), '');
    return withoutTrailingSlash.endsWith('/api/v1')
        ? withoutTrailingSlash
        : '$withoutTrailingSlash/api/v1';
  }
}
