import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/mbti_model.dart';
import '../models/psych_model.dart';

class QuestionnaireViewModel extends ChangeNotifier {
  MbtiData? _mbtiData;
  PsychData? _psychData;

  MbtiData? get mbtiData => _mbtiData;
  PsychData? get psychData => _psychData;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _finalMbti;
  String? get finalMbti => _finalMbti;

  int? _psychScore;
  int? get psychScore => _psychScore;
  PsychClass? _psychClass;
  PsychClass? get psychClass => _psychClass;

  // MBTI Test State
  int _currentMbtiIndex = 0;
  int get currentMbtiIndex => _currentMbtiIndex;
  final Map<int, MbtiOption> _mbtiAnswers = {};

  // Psych Test State
  final Map<int, PsychOption> _psychAnswers = {};

  Future<void> initData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final mbtiJsonString =
          await rootBundle.loadString('assets/questions/mbti_localized.json');
      final psychJsonString =
          await rootBundle.loadString('assets/questions/psych_localized.json');

      _mbtiData = MbtiData.fromJson(jsonDecode(mbtiJsonString));
      _psychData = PsychData.fromJson(jsonDecode(psychJsonString));
    } catch (e) {
      debugPrint("Error loading questionnaire data: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  void setKnownMbti(String mbti) {
    _finalMbti = mbti;
    notifyListeners();
  }

  // --- MBTI Test ---
  void answerMbtiQuestion(int questionIndex, MbtiOption option) {
    _mbtiAnswers[questionIndex] = option;
    notifyListeners();
  }

  MbtiOption? getSelectedMbtiOption(int questionIndex) {
    return _mbtiAnswers[questionIndex];
  }

  void nextMbtiQuestion() {
    if (_mbtiData != null &&
        _currentMbtiIndex < _mbtiData!.questionnaire.length - 1) {
      _currentMbtiIndex++;
      notifyListeners();
    }
  }

  void previousMbtiQuestion() {
    if (_currentMbtiIndex > 0) {
      _currentMbtiIndex--;
      notifyListeners();
    }
  }

  void calculateMbtiResult() {
    if (_mbtiData == null) return;

    Map<String, int> counts = {
      'E': 0, 'I': 0,
      'S': 0, 'N': 0,
      'T': 0, 'F': 0,
      'J': 0, 'P': 0,
    };

    for (var option in _mbtiAnswers.values) {
      counts[option.type] = (counts[option.type] ?? 0) + 1;
    }

    String result = "";
    result += (counts['E']! >= counts['I']!) ? 'E' : 'I';
    result += (counts['S']! >= counts['N']!) ? 'S' : 'N';
    result += (counts['T']! >= counts['F']!) ? 'T' : 'F';
    result += (counts['J']! >= counts['P']!) ? 'J' : 'P';

    _finalMbti = result;
    notifyListeners();
  }

  // --- Psych Test ---
  void answerPsychQuestion(int questionIndex, PsychOption option) {
    _psychAnswers[questionIndex] = option;
    notifyListeners();
  }

  PsychOption? getSelectedPsychOption(int questionIndex) {
    return _psychAnswers[questionIndex];
  }

  bool isPsychTestComplete() {
    if (_psychData == null) return false;
    return _psychAnswers.length == _psychData!.assessment.questions.length;
  }

  void calculatePsychResult() {
    if (_psychData == null) return;

    int totalRawScore = 0;
    for (var option in _psychAnswers.values) {
      totalRawScore += option.score;
    }

    int maxRawScore = _psychData!.assessment.scoringSystem.totalMaxScore;
    int displayMaxScore = _psychData!.assessment.scoringSystem.displayMaxScore;

    double calculatedScore = (totalRawScore / maxRawScore) * displayMaxScore;
    _psychScore = calculatedScore.round();

    // Find class
    for (var pClass in _psychData!.assessment.scoringSystem.classes) {
      var rangeParts = pClass.scoreRange.split('-');
      if (rangeParts.length == 2) {
        int minRange = int.tryParse(rangeParts[0].trim()) ?? 0;
        int maxRange = int.tryParse(rangeParts[1].trim()) ?? 100;
        if (totalRawScore >= minRange && totalRawScore <= maxRange) {
          _psychClass = pClass;
          break;
        }
      }
    }

    notifyListeners();
  }
}
