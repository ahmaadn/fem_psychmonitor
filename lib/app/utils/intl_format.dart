enum DayEnumType {
  sunday,
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
}

extension DayEnumTypeExtension on DayEnumType {
  String get displayName {
    switch (this) {
      case DayEnumType.sunday:
        return 'Sunday';
      case DayEnumType.monday:
        return 'Monday';
      case DayEnumType.tuesday:
        return 'Tuesday';
      case DayEnumType.wednesday:
        return 'Wednesday';
      case DayEnumType.thursday:
        return 'Thursday';
      case DayEnumType.friday:
        return 'Friday';
      case DayEnumType.saturday:
        return 'Saturday';
    }
  }

  String get shortName {
    switch (this) {
      case DayEnumType.sunday:
        return 'S';
      case DayEnumType.monday:
        return 'M';
      case DayEnumType.tuesday:
        return 'T';
      case DayEnumType.wednesday:
        return 'W';
      case DayEnumType.thursday:
        return 'T';
      case DayEnumType.friday:
        return 'F';
      case DayEnumType.saturday:
        return 'S';
    }
  }
}

enum MonthEnumType {
  january,
  february,
  march,
  april,
  may,
  june,
  july,
  august,
  september,
  october,
  november,
  december,
}

extension MonthEnumTypeExtension on MonthEnumType {
  String get displayName {
    switch (this) {
      case MonthEnumType.january:
        return 'January';
      case MonthEnumType.february:
        return 'February';
      case MonthEnumType.march:
        return 'March';
      case MonthEnumType.april:
        return 'April';
      case MonthEnumType.may:
        return 'May';
      case MonthEnumType.june:
        return 'June';
      case MonthEnumType.july:
        return 'July';
      case MonthEnumType.august:
        return 'August';
      case MonthEnumType.september:
        return 'September';
      case MonthEnumType.october:
        return 'October';
      case MonthEnumType.november:
        return 'November';
      case MonthEnumType.december:
        return 'December';
    }
  }
}
