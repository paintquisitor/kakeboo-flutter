/// A civil date, encoded exactly like java.time.LocalDate.toEpochDay().
/// UTC is used only for calendar arithmetic, never to reinterpret local instants.
final class CalendarDate implements Comparable<CalendarDate> {
  CalendarDate(int year, int month, int day)
    : this._(YearMonth(year, month).atDayEpoch(day));

  const CalendarDate._(this.epochDay);

  factory CalendarDate.fromEpochDay(int value) {
    if (value < -719162 || value > 2932896) {
      throw RangeError('Date outside years 1–9999');
    }
    return CalendarDate._(value);
  }

  factory CalendarDate.parse(String value) {
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
    if (match == null) throw FormatException('Invalid calendar date', value);
    return CalendarDate(
      int.parse(match[1]!),
      int.parse(match[2]!),
      int.parse(match[3]!),
    );
  }

  factory CalendarDate.fromCalendarFields(DateTime value) =>
      CalendarDate(value.year, value.month, value.day);

  final int epochDay;
  DateTime get _utc => DateTime.fromMillisecondsSinceEpoch(
    epochDay * Duration.millisecondsPerDay,
    isUtc: true,
  );
  int get year => _utc.year;
  int get month => _utc.month;
  int get day => _utc.day;
  YearMonth get yearMonth => YearMonth(year, month);
  CalendarDate plusDays(int days) => CalendarDate.fromEpochDay(epochDay + days);
  @override
  int compareTo(CalendarDate other) => epochDay.compareTo(other.epochDay);
  @override
  bool operator ==(Object other) =>
      other is CalendarDate && epochDay == other.epochDay;
  @override
  int get hashCode => epochDay.hashCode;
  @override
  String toString() => '$yearMonth-${day.toString().padLeft(2, '0')}';
}

final class YearMonth implements Comparable<YearMonth> {
  YearMonth(this.year, this.month) {
    if (year < 1 || year > 9999 || month < 1 || month > 12) {
      throw RangeError('Invalid year or month');
    }
  }
  factory YearMonth.parse(String value) {
    final match = RegExp(r'^(\d{4})-(\d{2})$').firstMatch(value);
    if (match == null) throw FormatException('Invalid month', value);
    return YearMonth(int.parse(match[1]!), int.parse(match[2]!));
  }
  final int year;
  final int month;
  int get _index => year * 12 + month - 1;
  int get lengthOfMonth => DateTime.utc(year, month + 1, 0).day;
  int atDayEpoch(int day) {
    if (day < 1 || day > lengthOfMonth) throw RangeError('Invalid day');
    return DateTime.utc(year, month, day).millisecondsSinceEpoch ~/
        Duration.millisecondsPerDay;
  }

  CalendarDate atDay(int day) => CalendarDate.fromEpochDay(atDayEpoch(day));
  CalendarDate get firstDay => atDay(1);
  CalendarDate get lastDay => atDay(lengthOfMonth);
  YearMonth plusMonths(int count) {
    final index = _index + count;
    return YearMonth((index - index % 12) ~/ 12, index % 12 + 1);
  }

  int monthsUntil(YearMonth target) => target._index - _index;
  @override
  int compareTo(YearMonth other) => _index.compareTo(other._index);
  @override
  bool operator ==(Object other) =>
      other is YearMonth && year == other.year && month == other.month;
  @override
  int get hashCode => Object.hash(year, month);
  @override
  String toString() =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}';
}

abstract interface class DateSource {
  CalendarDate today();
}

final class SystemDateSource implements DateSource {
  const SystemDateSource();
  @override
  CalendarDate today() => CalendarDate.fromCalendarFields(DateTime.now());
}
