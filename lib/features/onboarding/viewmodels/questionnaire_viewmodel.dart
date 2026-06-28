import 'package:flutter/material.dart';
import 'package:fem_psychmonitor/data/repositories/question_repository.dart';
import 'package:fem_psychmonitor/features/onboarding/models/mbti_model.dart';
import 'package:fem_psychmonitor/features/onboarding/models/psych_model.dart';

/// ViewModel driving the MBTI & Psych onboarding questionnaires.
///
/// Loads master data through [QuestionRepository] (asset-seeded SQLite) instead
/// of reading `rootBundle` directly, so the same data source backs the seeder
/// and the UI.
class QuestionnaireViewModel extends ChangeNotifier {
  final QuestionRepository? _questionRepo;

  QuestionnaireViewModel({QuestionRepository? questionRepo})
      : _questionRepo = questionRepo;

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

  /// Load questionnaire master data. Prefers the [QuestionRepository] when one
  /// was injected; otherwise falls back to asset loading (kept for legacy
  /// test paths that construct the VM without a repo).
  Future<void> initData() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_questionRepo != null) {
        _mbtiData = await _questionRepo.getMbtiData();
        _psychData = await _questionRepo.getPsychData();
      }
    } catch (e) {
      debugPrint("Error loading questionnaire data via repo: $e");
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

    double calculatedScore = maxRawScore == 0
        ? 0
        : (totalRawScore / maxRawScore) * displayMaxScore;
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
