class SaranEmotions {
  final List<String> happy;
  final List<String> fear;
  final List<String> angry;
  final List<String> sad;
  final List<String> disgust;
  final List<String> neutral;

  SaranEmotions({
    required this.happy,
    required this.fear,
    required this.angry,
    required this.sad,
    required this.disgust,
    required this.neutral,
  });

  factory SaranEmotions.fromJson(Map<String, dynamic> json) {
    return SaranEmotions(
      happy: List<String>.from(json['Happy'] ?? []),
      fear: List<String>.from(json['Fear'] ?? []),
      angry: List<String>.from(json['Angry'] ?? []),
      sad: List<String>.from(json['Sad'] ?? []),
      disgust: List<String>.from(json['Disgust'] ?? []),
      neutral: List<String>.from(json['Neutral'] ?? []),
    );
  }
}

class SaranRecommendation {
  final String mbtiType;
  final String alias;
  final String group;
  final SaranEmotions emotions;

  SaranRecommendation({
    required this.mbtiType,
    required this.alias,
    required this.group,
    required this.emotions,
  });

  factory SaranRecommendation.fromJson(Map<String, dynamic> json) {
    return SaranRecommendation(
      mbtiType: json['mbti_type'] as String,
      alias: json['alias'] as String,
      group: json['group'] as String,
      emotions: SaranEmotions.fromJson(json['emotions']),
    );
  }
}

class SaranData {
  final List<SaranRecommendation> recommendations;

  SaranData({required this.recommendations});

  factory SaranData.fromJson(Map<String, dynamic> json) {
    var recList = json['mbti_recommendations'] as List;
    List<SaranRecommendation> recommendations =
        recList.map((i) => SaranRecommendation.fromJson(i)).toList();
    return SaranData(recommendations: recommendations);
  }
}
