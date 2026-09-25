import 'package:drift/drift.dart';

import '../../../core/tracking/data/trackable_table.dart';

@DataClassName('MealRow')
class Meals extends Table with TrackableTable {
  TextColumn get dish => text().nullable()();
  RealColumn get price => real().nullable()();
  TextColumn get company => text().nullable()();

  /// A link to the place on a map, as the owner pasted it.
  ///
  /// The link rather than coordinates, because a link is what a phone gives
  /// you when you share a pin and it is what opens the place again in
  /// whatever map app the owner actually uses. The coordinates are read back
  /// out of it when it has any — see `parseMapLink`.
  ///
  /// This replaced a free-text neighbourhood in schema v9. A neighbourhood
  /// was something you typed and then could not do anything with; a link
  /// draws the map.
  TextColumn get mapsUrl => text().nullable()();
}
