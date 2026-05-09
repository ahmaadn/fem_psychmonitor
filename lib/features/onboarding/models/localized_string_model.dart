class LocalizedString {
  final String id;
  final String en;

  LocalizedString({
    required this.id,
    required this.en,
  });

  factory LocalizedString.fromJson(Map<String, dynamic> json) {
    return LocalizedString(
      id: json['id'] as String? ?? '',
      en: json['en'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'en': en,
    };
  }

  String get(bool isEnglish) {
    return isEnglish ? en : id;
  }
}
