import 'package:fem_psychmonitor/app/config/app_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android emulator defaults to host loopback alias', () {
    expect(
      AppConfig.resolveApiBaseUrl(
        configuredUrl: '',
        isWeb: false,
        targetPlatform: TargetPlatform.android,
      ),
      'http://10.0.2.2:3000/api/v1',
    );
  });

  test('desktop and web default to localhost', () {
    for (final platform in [TargetPlatform.windows, TargetPlatform.linux]) {
      expect(
        AppConfig.resolveApiBaseUrl(
          configuredUrl: '',
          isWeb: false,
          targetPlatform: platform,
        ),
        'http://localhost:3000/api/v1',
      );
    }
    expect(
      AppConfig.resolveApiBaseUrl(
        configuredUrl: '',
        isWeb: true,
        targetPlatform: TargetPlatform.android,
      ),
      'http://localhost:3000/api/v1',
    );
  });

  test('hosted URL is normalized with one API prefix', () {
    for (final configured in [
      'https://api.example.com',
      'https://api.example.com/',
      'https://api.example.com/api/v1',
      ' https://api.example.com/api/v1/ ',
    ]) {
      expect(
        AppConfig.resolveApiBaseUrl(
          configuredUrl: configured,
          isWeb: false,
          targetPlatform: TargetPlatform.android,
        ),
        'https://api.example.com/api/v1',
      );
    }
  });
}
