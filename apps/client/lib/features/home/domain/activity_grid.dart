/// The window the grid covers, in whole days.
class ActivityWindow {
  ActivityWindow({required DateTime from, required DateTime to})
    : from = dateOnly(from),
      to = dateOnly(to);

  final DateTime from;
  final DateTime to;
}

/// Strips the time, keeping the day the user was living in.
DateTime dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

/// How much was written down on one day, as one square of the grid.
class ActivityDay {
  const ActivityDay({required this.day, required this.count});

  final DateTime day;

  /// Entries logged that day, across all five domains.
  final int count;

  /// Which shade the square gets, 0 to 4.
  ///
  /// Fixed thresholds rather than quartiles of the busiest day, which is
  /// what GitHub does. Relative shading makes every other day dimmer the
  /// moment one day is unusually full, so the grid would change meaning
  /// without anything about those days having changed. A square here means
  /// the same thing in January as in June.
  ///
  /// The steps are lower than a code-hosting site's because the unit is
  /// different: a day with two entries in a log of meals out and films is a
  /// busy day, not a quiet one.
  int get level => switch (count) {
    0 => 0,
    1 => 1,
    2 => 2,
    3 || 4 => 3,
    _ => 4,
  };

  bool get isEmpty => count == 0;
}

/// Everything logged per day over a window, laid out as weeks.
///
/// A day nobody wrote anything on is an empty square, which is the whole
/// point: the grid is a record of what was done, and a gap is a real answer.
class ActivityGrid {
  const ActivityGrid._({required this.weeks, required this.total});

  /// Builds the grid for [window] from a count per day.
  ///
  /// [counts] is keyed by the day at midnight; a day missing from it has
  /// nothing logged. The window is widened to whole weeks so every column
  /// holds seven squares and the rows line up under one weekday each — a
  /// ragged first column would put Monday and Thursday on the same row.
  factory ActivityGrid.from(
    ActivityWindow window,
    Map<DateTime, int> counts, {
    required int firstWeekday,
  }) {
    final start = _startOfWeek(window.from, firstWeekday);
    final end = window.to;

    final weeks = <List<ActivityDay>>[];
    var cursor = start;
    var total = 0;

    while (!cursor.isAfter(end)) {
      final week = <ActivityDay>[];
      for (var i = 0; i < 7; i++) {
        final day = DateTime(cursor.year, cursor.month, cursor.day + i);
        // Days past the end of the window are still squares, so the last
        // column is not shorter than the others. They hold nothing, which
        // is also true: they have not happened yet.
        final count = day.isAfter(end) ? 0 : counts[day] ?? 0;
        total += count;
        week.add(ActivityDay(day: day, count: count));
      }
      weeks.add(week);
      cursor = DateTime(cursor.year, cursor.month, cursor.day + 7);
    }

    return ActivityGrid._(weeks: weeks, total: total);
  }

  /// One list per week, each holding seven days in weekday order.
  final List<List<ActivityDay>> weeks;

  /// Everything logged inside the window.
  final int total;

  bool get isEmpty => total == 0;

  /// How many days of the window had something on them.
  int get activeDays =>
      weeks.expand((week) => week).where((day) => !day.isEmpty).length;

  /// The longest run of consecutive days with something logged.
  ///
  /// Days after today are not counted: a run cannot be broken by a day that
  /// has not arrived.
  int longestRun(DateTime today) {
    final limit = dateOnly(today);
    var best = 0;
    var current = 0;

    for (final day in weeks.expand((week) => week)) {
      if (day.day.isAfter(limit)) break;
      current = day.isEmpty ? 0 : current + 1;
      if (current > best) best = current;
    }

    return best;
  }

  static DateTime _startOfWeek(DateTime day, int firstWeekday) {
    final shift = (day.weekday - firstWeekday + 7) % 7;
    return DateTime(day.year, day.month, day.day - shift);
  }
}
