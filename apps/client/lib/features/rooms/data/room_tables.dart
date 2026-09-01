import 'package:drift/drift.dart';

import '../../../core/tracking/data/trackable_table.dart';
import '../../franchises/data/franchise_tables.dart';

@DataClassName('RoomRow')
class Rooms extends Table with TrackableTable {
  /// Rooms outlive their franchise: deleting one detaches instead of cascading.
  IntColumn get franchiseId => integer().nullable().references(
    Franchises,
    #id,
    onDelete: KeyAction.setNull,
  )();

  BoolColumn get escaped => boolean()();

  /// Minutes left on the clock. Meaningless unless [escaped].
  IntColumn get timeLeftMinutes => integer().nullable()();
}
