import 'package:fem_psychmonitor/features/onboarding/models/localized_string_model.dart';

class MbtiOption {
  final String code;
  final LocalizedString answer;
  final String type;

  MbtiOption({
    required this.code,
    required this.answer,
    required this.type,
  });

  factory MbtiOption.fromJson(Map<String, dynamic> json) {
    return MbtiOption(
      code: json['code'] as String? ?? '',
      answer: LocalizedString.fromJson(json['answer'] as Map<String, dynamic>),
      type: json['type'] as String,
    );
  }
}

class MbtiQuestion {
  final int id;
  final String code;
  final String dimension;
  final LocalizedString question;
  final List<MbtiOption> options;

  MbtiQuestion({
    required this.id,
    required this.code,
    required this.dimension,
    required this.question,
    required this.options,
  });

  factory MbtiQuestion.fromJson(Map<String, dynamic> json) {
    var optionsList = json['options'] as List;
    List<MbtiOption> options =
        optionsList.map((i) => MbtiOption.fromJson(i)).toList();
    return MbtiQuestion(
      id: json['id'] as int,
      code: json['code'] as String? ?? '',
      dimension: json['dimension'] as String,
      question: LocalizedString.fromJson(json['question'] as Map<String, dynamic>),
      options: options,
    );
  }
}

class MbtiData {
  final List<MbtiQuestion> questionnaire;

  MbtiData({required this.questionnaire});

  factory MbtiData.fromJson(Map<String, dynamic> json) {
    var qList = json['mbti_questionnaire'] as List;
    List<MbtiQuestion> questions =
        qList.map((i) => MbtiQuestion.fromJson(i)).toList();
    return MbtiData(questionnaire: questions);
  }
}
