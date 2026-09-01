import 'package:drift/drift.dart';

import '../../../core/tracking/data/trackable_table.dart';

@DataClassName('MealRow')
class Meals extends Table with TrackableTable {
  TextColumn get dish => text().nullable()();
  RealColumn get price => real().nullable()();
  TextColumn get company => text().nullable()();
  TextColumn get location => text().nullable()();
}
