import 'package:drift/drift.dart';

@DataClassName('FranchiseRow')
class Franchises extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 120)();
  TextColumn get logoPath => text().nullable()();
}
