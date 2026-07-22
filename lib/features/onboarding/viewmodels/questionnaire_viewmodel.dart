import 'package:flutter/material.dart';
import 'package:fem_psychmonitor/app/utils/mental_health_score.dart';
import 'package:fem_psychmonitor/data/repositories/question_repository.dart';
import 'package:fem_psychmonitor/features/onboarding/models/ocean_model.dart';
import 'package:fem_psychmonitor/features/onboarding/models/psych_model.dart';

class QuestionnaireViewModel extends ChangeNotifier {
  final QuestionRepository? _questionRepo;

  QuestionnaireViewModel({QuestionRepository? questionRepo})
      : _questionRepo = questionRepo;

  List<OceanQuestion> _oceanQuestions = [];
  PsychData? _psychData;

  List<OceanQuestion> get oceanQuestions => _oceanQuestions;
  PsychData? get psychData => _psychData;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  OceanScores? _oceanScores;
  OceanScores? get oceanScores => _oceanScores;

  int? _psychScore;
  int? get psychScore => _psychScore;
  PsychClass? _psychClass;
  PsychClass? get psychClass => _psychClass;
  String? _psychClassKey;
  String? get psychClassKey => _psychClassKey;

  bool _hasUnsavedOnboardingResults = false;
  bool get hasUnsavedOnboardingResults => _hasUnsavedOnboardingResults;

  int _currentOceanIndex = 0;
  int get currentOceanIndex => _currentOceanIndex;
  final Map<int, int> _oceanAnswers = {}; // questionId -> 1..5

  final Map<int, PsychOption> _psychAnswers = {};

  Future<void> initData() async {
    _isLoading = true;
    notifyListeners();
    try {
      if (_questionRepo != null) {
        _oceanQuestions = await _questionRepo.getOceanQuestions();
        _psychData = await _questionRepo.getPsychData();
      }
    } catch (e) {
      debugPrint('Error loading questionnaire data: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  // ── OCEAN ────────────────────────────────────────────────────────────
  void answerOcean(int questionId, int value1to5) {
    _oceanAnswers[questionId] = value1to5.clamp(1, 5);
    notifyListeners();
  }

  int? getOceanAnswer(int questionId) => _oceanAnswers[questionId];

  bool get isOceanComplete =>
      _oceanQuestions.isNotEmpty &&
      _oceanQuestions.every((q) => _oceanAnswers.containsKey(q.id));

  void nextOceanQuestion() {
    if (_currentOceanIndex < _oceanQuestions.length - 1) {
      _currentOceanIndex++;
      notifyListeners();
    }
  }

  void previousOceanQuestion() {
    if (_currentOceanIndex > 0) {
      _currentOceanIndex--;
      notifyListeners();
    }
  }

  void goToOceanIndex(int index) {
    if (index >= 0 && index < _oceanQuestions.length) {
      _currentOceanIndex = index;
      notifyListeners();
    }
  }

  void calculateOceanResult() {
    if (!isOceanComplete) return;
    _oceanScores = computeOceanScores(_oceanQuestions, _oceanAnswers);
    _hasUnsavedOnboardingResults = true;
    notifyListeners();
  }

  // ── Psych ────────────────────────────────────────────────────────────
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

    final maxRawScore = _psychData!.assessment.scoringSystem.totalMaxScore;
    final displayMaxScore = _psychData!.assessment.scoringSystem.displayMaxScore;

    final calculatedRiskScore = maxRawScore == 0
        ? 0.0
        : (totalRawScore / maxRawScore) * displayMaxScore;
    _psychScore = (displayMaxScore - calculatedRiskScore).round().clamp(
          0,
          displayMaxScore,
        );

    for (var pClass in _psychData!.assessment.scoringSystem.classes) {
      final rangeParts = pClass.scoreRange.split('-');
      if (rangeParts.length == 2) {
        final minRange = int.tryParse(rangeParts[0].trim()) ?? 0;
        final maxRange = int.tryParse(rangeParts[1].trim()) ?? 100;
        if (totalRawScore >= minRange && totalRawScore <= maxRange) {
          _psychClass = pClass;
          break;
        }
      }
    }

    _psychClassKey = psychClassKeyForScore(_psychScore ?? 0);
    _hasUnsavedOnboardingResults = true;
    notifyListeners();
  }

  void markOnboardingResultsSaved() {
    if (!_hasUnsavedOnboardingResults) return;
    _hasUnsavedOnboardingResults = false;
    notifyListeners();
  }

  void resetAssessmentProgress() {
    _oceanAnswers.clear();
    _psychAnswers.clear();
    _currentOceanIndex = 0;
    _oceanScores = null;
    _psychScore = null;
    _psychClass = null;
    _psychClassKey = null;
    _hasUnsavedOnboardingResults = false;
    notifyListeners();
  }
}
