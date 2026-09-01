import 'package:drift/drift.dart';

/// The columns every tracked table carries, declared once.
///
/// Each feature mixes this into its own table and adds only what is specific
/// to its domain, so the shared query helpers can always find these six.
mixin TrackableTable on Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get photoPath => text().nullable()();
  TextColumn get description => text().nullable()();
  RealColumn get rating => real().nullable()();
  TextColumn get review => text().nullable()();
  DateTimeColumn get happenedOn => dateTime()();
}
