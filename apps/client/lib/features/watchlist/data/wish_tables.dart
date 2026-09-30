import 'package:drift/drift.dart';

import '../../../core/ids/uuid.dart';
import '../domain/wish.dart';

/// The watchlist: things the owner means to watch, play or see.
///
/// Its own table rather than a flag on the five tracked ones, because a wish
/// has none of what a tracked entry must have — no day it happened, no
/// score, no review — and a nullable version of each of those, five times
/// over, would be five tables that no longer mean what they say.
@DataClassName('WishRow')
@TableIndex.sql('CREATE INDEX IF NOT EXISTS wish_by_kind ON wishes (kind)')
class Wishes extends Table {
  TextColumn get id => text().clientDefault(newUuid)();
  IntColumn get kind => intEnum<WishKind>()();
  TextColumn get title => text().withLength(min: 1, max: 200)();

  /// The owner's own reason for adding it.
  TextColumn get note => text().nullable()();

  /// The synopsis a lookup found.
  TextColumn get description => text().nullable()();
  IntColumn get releaseYear => integer().nullable()();

  /// The source's id and cover, carried into the entry made from this wish.
  TextColumn get externalId => text().nullable()();
  TextColumn get posterUrl => text().nullable()();

  DateTimeColumn get addedOn => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
