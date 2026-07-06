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

  /// US-07: per-trait answer counts for the four MBTI dimensions. Populated
  /// by [calculateMbtiResult] and exposed so the result page can render
  /// dimension-strength bars (E/I, S/N, T/F, J/P).
  final Map<String, int> _mbtiDimensionCounts = {
    'E': 0,
    'I': 0,
    'S': 0,
    'N': 0,
    'T': 0,
    'F': 0,
    'J': 0,
    'P': 0,
  };
  Map<String, int> get mbtiDimensionCounts =>
      Map.unmodifiable(_mbtiDimensionCounts);

  /// US-07: true when the dimension counts were populated from a real test
  /// (not the known-MBTI shortcut, which has no per-trait breakdown).
  bool get hasDimensionCounts =>
      _mbtiDimensionCounts.values.fold<int>(0, (a, b) => a + b) > 0;

  /// Returns the four MBTI dimension pairs with their percentage split, where
  /// each pair maps to `(leftTrait, leftPercent, rightTrait, rightPercent)`.
  /// Percentages are rounded and sum to 100 (ties favour the left trait at 50).
  List<({String left, int leftPct, String right, int rightPct})>
  get mbtiDimensionPercentages {
    int pct(int a, int b) {
      final total = a + b;
      if (total == 0) return 50;
      return ((a / total) * 100).round();
    }

    final pairs = [('E', 'I'), ('S', 'N'), ('T', 'F'), ('J', 'P')];
    return pairs.map((p) {
      final left = _mbtiDimensionCounts[p.$1] ?? 0;
      final right = _mbtiDimensionCounts[p.$2] ?? 0;
      final lp = pct(left, right);
      return (left: p.$1, leftPct: lp, right: p.$2, rightPct: 100 - lp);
    }).toList();
  }

  int? _psychScore;
  int? get psychScore => _psychScore;
  PsychClass? _psychClass;
  PsychClass? get psychClass => _psychClass;
  bool _hasUnsavedOnboardingResults = false;
  bool get hasUnsavedOnboardingResults => _hasUnsavedOnboardingResults;

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
    _hasUnsavedOnboardingResults = true;
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
      'E': 0,
      'I': 0,
      'S': 0,
      'N': 0,
      'T': 0,
      'F': 0,
      'J': 0,
      'P': 0,
    };

    for (var option in _mbtiAnswers.values) {
      counts[option.type] = (counts[option.type] ?? 0) + 1;
    }

    // US-07: persist the per-trait counts for the dimension bars.
    _mbtiDimensionCounts
      ..clear()
      ..addAll(counts);

    String result = "";
    result += (counts['E']! >= counts['I']!) ? 'E' : 'I';
    result += (counts['S']! >= counts['N']!) ? 'S' : 'N';
    result += (counts['T']! >= counts['F']!) ? 'T' : 'F';
    result += (counts['J']! >= counts['P']!) ? 'J' : 'P';

    _finalMbti = result;
    _hasUnsavedOnboardingResults = true;
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

    double calculatedRiskScore = maxRawScore == 0
        ? 0
        : (totalRawScore / maxRawScore) * displayMaxScore;
    _psychScore = (displayMaxScore - calculatedRiskScore).round().clamp(
      0,
      displayMaxScore,
    );

    // Class ranges in the JSON use raw distress score; display score is the
    // inverse wellness scale shown to users.
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

    _hasUnsavedOnboardingResults = true;
    notifyListeners();
  }

  void markOnboardingResultsSaved() {
    if (!_hasUnsavedOnboardingResults) return;
    _hasUnsavedOnboardingResults = false;
    notifyListeners();
  }
}
