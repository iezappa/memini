import 'package:drift/drift.dart';

import '../../ids/uuid.dart';

/// The columns every tracked table carries, declared once.
///
/// Each feature mixes this into its own table and adds only what is specific
/// to its domain, so the shared query helpers can always find these.
///
/// Since schema v4 the id is a UUID and every row carries [updatedAt]
/// (STACK-APPS-DINAMICAS.md 1.1).
mixin TrackableTable on Table {
  TextColumn get id => text().clientDefault(newUuid)();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get description => text().nullable()();
  RealColumn get rating => real().nullable()();
  TextColumn get review => text().nullable()();
  DateTimeColumn get happenedOn => dateTime()();

  /// When the row was last written, by this device.
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
