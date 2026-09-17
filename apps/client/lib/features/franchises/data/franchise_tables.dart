import 'package:drift/drift.dart';

import '../../../core/ids/uuid.dart';

@DataClassName('FranchiseRow')
class Franchises extends Table {
  TextColumn get id => text().clientDefault(newUuid)();
  TextColumn get name => text().withLength(min: 1, max: 120)();
  TextColumn get logoPath => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
