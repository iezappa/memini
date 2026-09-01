library;

import '../../concerts/domain/gig.dart';
import '../../dining/domain/meal.dart';
import '../../franchises/domain/franchise.dart';
import '../../games/domain/game.dart';
import '../../rooms/domain/room.dart';
import '../../screen/domain/viewing.dart';

/// Renders each domain as CSV for humans (spreadsheets), never for re-import
/// — JSON stays the source of truth.
///
/// One sheet per domain: sharing a header across five shapes would mean a
/// column for "escaped" on a meal and one for "dish" on a game.
String roomsToCsv({
  required List<Room> rooms,
  required List<Franchise> franchises,
}) {
  final byId = {for (final f in franchises) f.id: f.name};

  final buffer = StringBuffer()
    ..writeln(
      _row([
        'title',
        'franchise',
        'happened_on',
        'escaped',
        'time_left_minutes',
        'rating',
        'description',
        'review',
      ]),
    );

  for (final room in rooms) {
    buffer.writeln(
      _row([
        room.title,
        room.franchiseId == null ? '' : (byId[room.franchiseId] ?? ''),
        _dateOnly(room.happenedOn),
        room.escaped ? 'yes' : 'no',
        room.timeLeftMinutes?.toString() ?? '',
        room.rating?.toString() ?? '',
        room.description ?? '',
        room.review ?? '',
      ]),
    );
  }

  return buffer.toString();
}

String mealsToCsv(List<Meal> meals) {
  final buffer = StringBuffer()
    ..writeln(
      _row([
        'place',
        'location',
        'happened_on',
        'dish',
        'price',
        'company',
        'rating',
        'description',
        'review',
      ]),
    );

  for (final meal in meals) {
    buffer.writeln(
      _row([
        meal.title,
        meal.location ?? '',
        _dateOnly(meal.happenedOn),
        meal.dish ?? '',
        meal.price?.toString() ?? '',
        meal.company ?? '',
        meal.rating?.toString() ?? '',
        meal.description ?? '',
        meal.review ?? '',
      ]),
    );
  }

  return buffer.toString();
}

String gigsToCsv(List<Gig> gigs) {
  final buffer = StringBuffer()
    ..writeln(
      _row([
        'band',
        'venue',
        'city',
        'happened_on',
        'support_acts',
        'company',
        'rating',
        'setlist',
        'description',
        'review',
      ]),
    );

  for (final gig in gigs) {
    buffer.writeln(
      _row([
        gig.title,
        gig.venue ?? '',
        gig.city ?? '',
        _dateOnly(gig.happenedOn),
        gig.supportActs ?? '',
        gig.company ?? '',
        gig.rating?.toString() ?? '',
        // A setlist is one song per line; the escaping quotes it so the cell
        // survives as a single field rather than breaking the row.
        gig.setlist ?? '',
        gig.description ?? '',
        gig.review ?? '',
      ]),
    );
  }

  return buffer.toString();
}

String viewingsToCsv(List<Viewing> viewings) {
  final buffer = StringBuffer()
    ..writeln(
      _row([
        'title',
        'kind',
        'release_year',
        'season',
        'happened_on',
        'director',
        'cast',
        'rating',
        'description',
        'review',
      ]),
    );

  for (final viewing in viewings) {
    buffer.writeln(
      _row([
        viewing.title,
        viewing.kind.name,
        viewing.releaseYear?.toString() ?? '',
        viewing.season?.toString() ?? '',
        _dateOnly(viewing.happenedOn),
        viewing.director ?? '',
        viewing.cast ?? '',
        viewing.rating?.toString() ?? '',
        viewing.description ?? '',
        viewing.review ?? '',
      ]),
    );
  }

  return buffer.toString();
}

String gamesToCsv(List<Game> games) {
  final buffer = StringBuffer()
    ..writeln(
      _row([
        'title',
        'status',
        'platform',
        'hours_played',
        'release_year',
        'happened_on',
        'rating',
        'description',
        'review',
      ]),
    );

  for (final game in games) {
    buffer.writeln(
      _row([
        game.title,
        game.status.name,
        game.platform ?? '',
        game.hoursPlayed?.toString() ?? '',
        game.releaseYear?.toString() ?? '',
        _dateOnly(game.happenedOn),
        game.rating?.toString() ?? '',
        game.description ?? '',
        game.review ?? '',
      ]),
    );
  }

  return buffer.toString();
}

String _row(List<String> cells) => cells.map(_escape).join(',');

/// RFC 4180: quote a field that contains a comma, a quote or a line break,
/// and double any quote inside it.
String _escape(String value) {
  final needsQuotes = value.contains(RegExp(r'[",\r\n]'));
  final escaped = value.replaceAll('"', '""');
  return needsQuotes ? '"$escaped"' : escaped;
}

String _dateOnly(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}
