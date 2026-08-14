import 'dart:convert';

import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/data/models/detection_result_model.dart';
import 'package:fem_psychmonitor/data/models/detection_session_model.dart';
import 'package:fem_psychmonitor/data/repositories/api/api_auth_repository.dart';
import 'package:fem_psychmonitor/data/repositories/api/api_client.dart';
import 'package:fem_psychmonitor/data/repositories/api/api_daily_mood_repository.dart';
import 'package:fem_psychmonitor/data/repositories/api/api_detection_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('login stores remote tokens and maps epoch user timestamps', () async {
    final store = RemoteAuthSessionStore();
    final client = MockClient((request) async {
      expect(request.url.path, '/api/v1/auth/login');
      expect(jsonDecode(request.body), {
        'email': 'user@example.com',
        'password': 'password-1',
      });
      return http.Response(
        jsonEncode({
          'user': _serverUser(),
          'accessToken': 'access-token',
          'refreshToken': 'refresh-token',
        }),
        200,
      );
    });
    final api = ApiClient(
      baseUrl: 'https://example.com/api/v1',
      sessionStore: store,
      client: client,
    );
    final repository = ApiAuthRepository(apiClient: api);

    final state = await repository.login('user@example.com', 'password-1');

    expect(state.isAuthenticated, isTrue);
    expect(state.user?.createdAt.millisecondsSinceEpoch, 1700000000000);
    expect(store.accessToken, 'access-token');
    expect(store.refreshToken, 'refresh-token');
  });

  test(
    'session API sends epoch timestamps and omits local audio path',
    () async {
      final store = RemoteAuthSessionStore()..accessToken = 'access-token';
      final startedAt = DateTime.fromMillisecondsSinceEpoch(1700000000000);
      final stoppedAt = DateTime.fromMillisecondsSinceEpoch(1700000003000);
      final session = DetectionSessionModel(
        id: 'sess_1',
        userId: 'usr_1',
        startedAt: startedAt,
        stoppedAt: stoppedAt,
        sourceType: DetectionSourceType.live,
        audioFilePath: '/private/device/audio.wav',
        dominantEmotion: EmotionLabelType.happy,
        dominantConfidence: 0.9,
        results: const [
          DetectionResultModel(
            id: 'result_1',
            sessionId: 'sess_1',
            startSec: 0,
            endSec: 3,
            label: EmotionLabelType.happy,
            confidence: 0.9,
            allProbs: [0.9, 0.02, 0.02, 0.02, 0.02, 0.02],
          ),
        ],
      );
      final client = MockClient((request) async {
        expect(request.headers['authorization'], 'Bearer access-token');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['startedAt'], 1700000000000);
        expect(body['stoppedAt'], 1700000003000);
        expect(body['audioFilePath'], isNull);
        return http.Response(jsonEncode({'session': body}), 200);
      });
      final api = ApiClient(
        baseUrl: 'https://example.com/api/v1',
        sessionStore: store,
        client: client,
      );
      final repository = ApiDetectionRepository(apiClient: api);

      final saved = await repository.saveSession(session);

      expect(saved.startedAt, startedAt);
      expect(saved.stoppedAt, stoppedAt);
      expect(saved.audioFilePath, isNull);
      expect(saved.results.single.allProbs, hasLength(6));
    },
  );

  test('daily mood API uses local date key and emotion contract', () async {
    final store = RemoteAuthSessionStore()..accessToken = 'access-token';
    final client = MockClient((request) async {
      expect(request.url.path, '/api/v1/daily-moods/2026-08-14');
      expect(jsonDecode(request.body), {'emotion': 'sad'});
      return http.Response(
        jsonEncode({
          'mood': {
            'userId': 'usr_1',
            'date': '2026-08-14',
            'emotion': 'sad',
            'createdAt': 1700000000000,
            'updatedAt': 1700000001000,
          },
        }),
        200,
      );
    });
    final api = ApiClient(
      baseUrl: 'https://example.com/api/v1',
      sessionStore: store,
      client: client,
    );
    final repository = ApiDailyMoodRepository(apiClient: api);

    final mood = await repository.upsert(
      date: '2026-08-14',
      emotion: EmotionLabelType.sad,
    );

    expect(mood.date, '2026-08-14');
    expect(mood.emotion, EmotionLabelType.sad);
  });

  test('API errors preserve server status and code for sync logging', () async {
    final store = RemoteAuthSessionStore()..accessToken = 'access-token';
    final client = MockClient((request) async {
      return http.Response(
        jsonEncode({
          'error': {'code': 'VALIDATION_ERROR', 'message': 'Invalid session'},
        }),
        400,
      );
    });
    final api = ApiClient(
      baseUrl: 'https://example.com/api/v1',
      sessionStore: store,
      client: client,
    );

    expect(
      () => api.request('GET', '/sessions'),
      throwsA(
        isA<ApiException>()
            .having((error) => error.statusCode, 'statusCode', 400)
            .having((error) => error.code, 'code', 'VALIDATION_ERROR'),
      ),
    );
  });
}

Map<String, dynamic> _serverUser() {
  return {
    'id': 'usr_1',
    'fullName': 'User',
    'email': 'user@example.com',
    'phone': null,
    'dateOfBirth': null,
    'avatarUrl': null,
    'createdAt': 1700000000000,
    'isGuest': false,
    'oceanScores': null,
    'oceanCompletedAt': null,
    'psychScore': null,
    'psychClass': null,
  };
}
