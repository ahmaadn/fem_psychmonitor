import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrivacyProvider extends ChangeNotifier {
  static const _kTempAudio = 'privacy_store_temp_audio';
  static const _kAnalytics = 'privacy_analytics';

  bool _storeTempAudio = false;
  bool _analytics = false;

  bool get storeTempAudio => _storeTempAudio;
  bool get analytics => _analytics;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _storeTempAudio = prefs.getBool(_kTempAudio) ?? false;
    _analytics = prefs.getBool(_kAnalytics) ?? false;
    notifyListeners();
  }

  Future<void> setStoreTempAudio(bool v) async {
    _storeTempAudio = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kTempAudio, v);
  }

  Future<void> setAnalytics(bool v) async {
    _analytics = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAnalytics, v);
  }
}
