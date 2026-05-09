import 'package:fem_psychmonitor/features/onboarding/models/localized_string_model.dart';

class PsychOption {
  final String code;
  final LocalizedString answer;
  final int score;

  PsychOption({
    required this.code,
    required this.answer,
    required this.score,
  });

  factory PsychOption.fromJson(Map<String, dynamic> json) {
    return PsychOption(
      code: json['code'] as String? ?? '',
      answer: LocalizedString.fromJson(json['answer'] as Map<String, dynamic>),
      score: json['score'] as int,
    );
  }
}

class PsychQuestion {
  final int id;
  final String code;
  final LocalizedString category;
  final LocalizedString question;
  final List<PsychOption> options;

  PsychQuestion({
    required this.id,
    required this.code,
    required this.category,
    required this.question,
    required this.options,
  });

  factory PsychQuestion.fromJson(Map<String, dynamic> json) {
    var optionsList = json['options'] as List;
    List<PsychOption> options =
        optionsList.map((i) => PsychOption.fromJson(i)).toList();
    return PsychQuestion(
      id: json['id'] as int,
      code: json['code'] as String? ?? '',
      category: LocalizedString.fromJson(json['category'] as Map<String, dynamic>),
      question: LocalizedString.fromJson(json['question'] as Map<String, dynamic>),
      options: options,
    );
  }
}

class PsychClass {
  final int classLevel;
  final LocalizedString className;
  final String displayRange;
  final String scoreRange;
  final LocalizedString description;
  final LocalizedString recommendation;

  PsychClass({
    required this.classLevel,
    required this.className,
    required this.displayRange,
    required this.scoreRange,
    required this.description,
    required this.recommendation,
  });

  factory PsychClass.fromJson(Map<String, dynamic> json) {
    return PsychClass(
      classLevel: json['class_level'] as int,
      className: LocalizedString.fromJson(json['class_name'] as Map<String, dynamic>),
      displayRange: json['display_range'] as String,
      scoreRange: json['score_range'] as String,
      description: LocalizedString.fromJson(json['description'] as Map<String, dynamic>),
      recommendation: LocalizedString.fromJson(json['recommendation'] as Map<String, dynamic>),
    );
  }
}

class PsychScoringSystem {
  final int totalMaxScore;
  final int displayMaxScore;
  final String calculation;
  final List<PsychClass> classes;

  PsychScoringSystem({
    required this.totalMaxScore,
    required this.displayMaxScore,
    required this.calculation,
    required this.classes,
  });

  factory PsychScoringSystem.fromJson(Map<String, dynamic> json) {
    var classesList = json['classes'] as List;
    List<PsychClass> classes =
        classesList.map((i) => PsychClass.fromJson(i)).toList();
    return PsychScoringSystem(
      totalMaxScore: json['total_max_score'] as int,
      displayMaxScore: json['display_max_score'] as int,
      calculation: json['calculation'] as String,
      classes: classes,
    );
  }
}

class PsychAssessment {
  final LocalizedString title;
  final LocalizedString description;
  final List<PsychQuestion> questions;
  final PsychScoringSystem scoringSystem;

  PsychAssessment({
    required this.title,
    required this.description,
    required this.questions,
    required this.scoringSystem,
  });

  factory PsychAssessment.fromJson(Map<String, dynamic> json) {
    var qList = json['questions'] as List;
    List<PsychQuestion> questions =
        qList.map((i) => PsychQuestion.fromJson(i)).toList();
    return PsychAssessment(
      title: LocalizedString.fromJson(json['title'] as Map<String, dynamic>),
      description: LocalizedString.fromJson(json['description'] as Map<String, dynamic>),
      questions: questions,
      scoringSystem: PsychScoringSystem.fromJson(json['scoring_system']),
    );
  }
}

class PsychData {
  final PsychAssessment assessment;

  PsychData({required this.assessment});

  factory PsychData.fromJson(Map<String, dynamic> json) {
    return PsychData(
      assessment: PsychAssessment.fromJson(
        json['womens_mental_health_assessment'],
      ),
    );
  }
}
