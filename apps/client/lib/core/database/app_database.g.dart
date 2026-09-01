// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $FranchisesTable extends Franchises
    with TableInfo<$FranchisesTable, FranchiseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FranchisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _logoPathMeta = const VerificationMeta(
    'logoPath',
  );
  @override
  late final GeneratedColumn<String> logoPath = GeneratedColumn<String>(
    'logo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, logoPath];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'franchises';
  @override
  VerificationContext validateIntegrity(
    Insertable<FranchiseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('logo_path')) {
      context.handle(
        _logoPathMeta,
        logoPath.isAcceptableOrUnknown(data['logo_path']!, _logoPathMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FranchiseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FranchiseRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      logoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}logo_path'],
      ),
    );
  }

  @override
  $FranchisesTable createAlias(String alias) {
    return $FranchisesTable(attachedDatabase, alias);
  }
}

class FranchiseRow extends DataClass implements Insertable<FranchiseRow> {
  final int id;
  final String name;
  final String? logoPath;
  const FranchiseRow({required this.id, required this.name, this.logoPath});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || logoPath != null) {
      map['logo_path'] = Variable<String>(logoPath);
    }
    return map;
  }

  FranchisesCompanion toCompanion(bool nullToAbsent) {
    return FranchisesCompanion(
      id: Value(id),
      name: Value(name),
      logoPath: logoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(logoPath),
    );
  }

  factory FranchiseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FranchiseRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      logoPath: serializer.fromJson<String?>(json['logoPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'logoPath': serializer.toJson<String?>(logoPath),
    };
  }

  FranchiseRow copyWith({
    int? id,
    String? name,
    Value<String?> logoPath = const Value.absent(),
  }) => FranchiseRow(
    id: id ?? this.id,
    name: name ?? this.name,
    logoPath: logoPath.present ? logoPath.value : this.logoPath,
  );
  FranchiseRow copyWithCompanion(FranchisesCompanion data) {
    return FranchiseRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      logoPath: data.logoPath.present ? data.logoPath.value : this.logoPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FranchiseRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('logoPath: $logoPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, logoPath);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FranchiseRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.logoPath == this.logoPath);
}

class FranchisesCompanion extends UpdateCompanion<FranchiseRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> logoPath;
  const FranchisesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.logoPath = const Value.absent(),
  });
  FranchisesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.logoPath = const Value.absent(),
  }) : name = Value(name);
  static Insertable<FranchiseRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? logoPath,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (logoPath != null) 'logo_path': logoPath,
    });
  }

  FranchisesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? logoPath,
  }) {
    return FranchisesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      logoPath: logoPath ?? this.logoPath,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (logoPath.present) {
      map['logo_path'] = Variable<String>(logoPath.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FranchisesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('logoPath: $logoPath')
          ..write(')'))
        .toString();
  }
}

class $RoomsTable extends Rooms with TableInfo<$RoomsTable, RoomRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoomsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _photoPathMeta = const VerificationMeta(
    'photoPath',
  );
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<double> rating = GeneratedColumn<double>(
    'rating',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reviewMeta = const VerificationMeta('review');
  @override
  late final GeneratedColumn<String> review = GeneratedColumn<String>(
    'review',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _happenedOnMeta = const VerificationMeta(
    'happenedOn',
  );
  @override
  late final GeneratedColumn<DateTime> happenedOn = GeneratedColumn<DateTime>(
    'happened_on',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _franchiseIdMeta = const VerificationMeta(
    'franchiseId',
  );
  @override
  late final GeneratedColumn<int> franchiseId = GeneratedColumn<int>(
    'franchise_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES franchises (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _escapedMeta = const VerificationMeta(
    'escaped',
  );
  @override
  late final GeneratedColumn<bool> escaped = GeneratedColumn<bool>(
    'escaped',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("escaped" IN (0, 1))',
    ),
  );
  static const VerificationMeta _timeLeftMinutesMeta = const VerificationMeta(
    'timeLeftMinutes',
  );
  @override
  late final GeneratedColumn<int> timeLeftMinutes = GeneratedColumn<int>(
    'time_left_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    photoPath,
    description,
    rating,
    review,
    happenedOn,
    franchiseId,
    escaped,
    timeLeftMinutes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rooms';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoomRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    if (data.containsKey('review')) {
      context.handle(
        _reviewMeta,
        review.isAcceptableOrUnknown(data['review']!, _reviewMeta),
      );
    }
    if (data.containsKey('happened_on')) {
      context.handle(
        _happenedOnMeta,
        happenedOn.isAcceptableOrUnknown(data['happened_on']!, _happenedOnMeta),
      );
    } else if (isInserting) {
      context.missing(_happenedOnMeta);
    }
    if (data.containsKey('franchise_id')) {
      context.handle(
        _franchiseIdMeta,
        franchiseId.isAcceptableOrUnknown(
          data['franchise_id']!,
          _franchiseIdMeta,
        ),
      );
    }
    if (data.containsKey('escaped')) {
      context.handle(
        _escapedMeta,
        escaped.isAcceptableOrUnknown(data['escaped']!, _escapedMeta),
      );
    } else if (isInserting) {
      context.missing(_escapedMeta);
    }
    if (data.containsKey('time_left_minutes')) {
      context.handle(
        _timeLeftMinutesMeta,
        timeLeftMinutes.isAcceptableOrUnknown(
          data['time_left_minutes']!,
          _timeLeftMinutesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoomRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoomRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rating'],
      ),
      review: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}review'],
      ),
      happenedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}happened_on'],
      )!,
      franchiseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}franchise_id'],
      ),
      escaped: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}escaped'],
      )!,
      timeLeftMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_left_minutes'],
      ),
    );
  }

  @override
  $RoomsTable createAlias(String alias) {
    return $RoomsTable(attachedDatabase, alias);
  }
}

class RoomRow extends DataClass implements Insertable<RoomRow> {
  final int id;
  final String title;
  final String? photoPath;
  final String? description;
  final double? rating;
  final String? review;
  final DateTime happenedOn;

  /// Rooms outlive their franchise: deleting one detaches instead of cascading.
  final int? franchiseId;
  final bool escaped;

  /// Minutes left on the clock. Meaningless unless [escaped].
  final int? timeLeftMinutes;
  const RoomRow({
    required this.id,
    required this.title,
    this.photoPath,
    this.description,
    this.rating,
    this.review,
    required this.happenedOn,
    this.franchiseId,
    required this.escaped,
    this.timeLeftMinutes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<double>(rating);
    }
    if (!nullToAbsent || review != null) {
      map['review'] = Variable<String>(review);
    }
    map['happened_on'] = Variable<DateTime>(happenedOn);
    if (!nullToAbsent || franchiseId != null) {
      map['franchise_id'] = Variable<int>(franchiseId);
    }
    map['escaped'] = Variable<bool>(escaped);
    if (!nullToAbsent || timeLeftMinutes != null) {
      map['time_left_minutes'] = Variable<int>(timeLeftMinutes);
    }
    return map;
  }

  RoomsCompanion toCompanion(bool nullToAbsent) {
    return RoomsCompanion(
      id: Value(id),
      title: Value(title),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      rating: rating == null && nullToAbsent
          ? const Value.absent()
          : Value(rating),
      review: review == null && nullToAbsent
          ? const Value.absent()
          : Value(review),
      happenedOn: Value(happenedOn),
      franchiseId: franchiseId == null && nullToAbsent
          ? const Value.absent()
          : Value(franchiseId),
      escaped: Value(escaped),
      timeLeftMinutes: timeLeftMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(timeLeftMinutes),
    );
  }

  factory RoomRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoomRow(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      description: serializer.fromJson<String?>(json['description']),
      rating: serializer.fromJson<double?>(json['rating']),
      review: serializer.fromJson<String?>(json['review']),
      happenedOn: serializer.fromJson<DateTime>(json['happenedOn']),
      franchiseId: serializer.fromJson<int?>(json['franchiseId']),
      escaped: serializer.fromJson<bool>(json['escaped']),
      timeLeftMinutes: serializer.fromJson<int?>(json['timeLeftMinutes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'photoPath': serializer.toJson<String?>(photoPath),
      'description': serializer.toJson<String?>(description),
      'rating': serializer.toJson<double?>(rating),
      'review': serializer.toJson<String?>(review),
      'happenedOn': serializer.toJson<DateTime>(happenedOn),
      'franchiseId': serializer.toJson<int?>(franchiseId),
      'escaped': serializer.toJson<bool>(escaped),
      'timeLeftMinutes': serializer.toJson<int?>(timeLeftMinutes),
    };
  }

  RoomRow copyWith({
    int? id,
    String? title,
    Value<String?> photoPath = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<double?> rating = const Value.absent(),
    Value<String?> review = const Value.absent(),
    DateTime? happenedOn,
    Value<int?> franchiseId = const Value.absent(),
    bool? escaped,
    Value<int?> timeLeftMinutes = const Value.absent(),
  }) => RoomRow(
    id: id ?? this.id,
    title: title ?? this.title,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
    description: description.present ? description.value : this.description,
    rating: rating.present ? rating.value : this.rating,
    review: review.present ? review.value : this.review,
    happenedOn: happenedOn ?? this.happenedOn,
    franchiseId: franchiseId.present ? franchiseId.value : this.franchiseId,
    escaped: escaped ?? this.escaped,
    timeLeftMinutes: timeLeftMinutes.present
        ? timeLeftMinutes.value
        : this.timeLeftMinutes,
  );
  RoomRow copyWithCompanion(RoomsCompanion data) {
    return RoomRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      description: data.description.present
          ? data.description.value
          : this.description,
      rating: data.rating.present ? data.rating.value : this.rating,
      review: data.review.present ? data.review.value : this.review,
      happenedOn: data.happenedOn.present
          ? data.happenedOn.value
          : this.happenedOn,
      franchiseId: data.franchiseId.present
          ? data.franchiseId.value
          : this.franchiseId,
      escaped: data.escaped.present ? data.escaped.value : this.escaped,
      timeLeftMinutes: data.timeLeftMinutes.present
          ? data.timeLeftMinutes.value
          : this.timeLeftMinutes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoomRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('photoPath: $photoPath, ')
          ..write('description: $description, ')
          ..write('rating: $rating, ')
          ..write('review: $review, ')
          ..write('happenedOn: $happenedOn, ')
          ..write('franchiseId: $franchiseId, ')
          ..write('escaped: $escaped, ')
          ..write('timeLeftMinutes: $timeLeftMinutes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    photoPath,
    description,
    rating,
    review,
    happenedOn,
    franchiseId,
    escaped,
    timeLeftMinutes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoomRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.photoPath == this.photoPath &&
          other.description == this.description &&
          other.rating == this.rating &&
          other.review == this.review &&
          other.happenedOn == this.happenedOn &&
          other.franchiseId == this.franchiseId &&
          other.escaped == this.escaped &&
          other.timeLeftMinutes == this.timeLeftMinutes);
}

class RoomsCompanion extends UpdateCompanion<RoomRow> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> photoPath;
  final Value<String?> description;
  final Value<double?> rating;
  final Value<String?> review;
  final Value<DateTime> happenedOn;
  final Value<int?> franchiseId;
  final Value<bool> escaped;
  final Value<int?> timeLeftMinutes;
  const RoomsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.description = const Value.absent(),
    this.rating = const Value.absent(),
    this.review = const Value.absent(),
    this.happenedOn = const Value.absent(),
    this.franchiseId = const Value.absent(),
    this.escaped = const Value.absent(),
    this.timeLeftMinutes = const Value.absent(),
  });
  RoomsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.photoPath = const Value.absent(),
    this.description = const Value.absent(),
    this.rating = const Value.absent(),
    this.review = const Value.absent(),
    required DateTime happenedOn,
    this.franchiseId = const Value.absent(),
    required bool escaped,
    this.timeLeftMinutes = const Value.absent(),
  }) : title = Value(title),
       happenedOn = Value(happenedOn),
       escaped = Value(escaped);
  static Insertable<RoomRow> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? photoPath,
    Expression<String>? description,
    Expression<double>? rating,
    Expression<String>? review,
    Expression<DateTime>? happenedOn,
    Expression<int>? franchiseId,
    Expression<bool>? escaped,
    Expression<int>? timeLeftMinutes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (photoPath != null) 'photo_path': photoPath,
      if (description != null) 'description': description,
      if (rating != null) 'rating': rating,
      if (review != null) 'review': review,
      if (happenedOn != null) 'happened_on': happenedOn,
      if (franchiseId != null) 'franchise_id': franchiseId,
      if (escaped != null) 'escaped': escaped,
      if (timeLeftMinutes != null) 'time_left_minutes': timeLeftMinutes,
    });
  }

  RoomsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String?>? photoPath,
    Value<String?>? description,
    Value<double?>? rating,
    Value<String?>? review,
    Value<DateTime>? happenedOn,
    Value<int?>? franchiseId,
    Value<bool>? escaped,
    Value<int?>? timeLeftMinutes,
  }) {
    return RoomsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      photoPath: photoPath ?? this.photoPath,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      happenedOn: happenedOn ?? this.happenedOn,
      franchiseId: franchiseId ?? this.franchiseId,
      escaped: escaped ?? this.escaped,
      timeLeftMinutes: timeLeftMinutes ?? this.timeLeftMinutes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (rating.present) {
      map['rating'] = Variable<double>(rating.value);
    }
    if (review.present) {
      map['review'] = Variable<String>(review.value);
    }
    if (happenedOn.present) {
      map['happened_on'] = Variable<DateTime>(happenedOn.value);
    }
    if (franchiseId.present) {
      map['franchise_id'] = Variable<int>(franchiseId.value);
    }
    if (escaped.present) {
      map['escaped'] = Variable<bool>(escaped.value);
    }
    if (timeLeftMinutes.present) {
      map['time_left_minutes'] = Variable<int>(timeLeftMinutes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoomsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('photoPath: $photoPath, ')
          ..write('description: $description, ')
          ..write('rating: $rating, ')
          ..write('review: $review, ')
          ..write('happenedOn: $happenedOn, ')
          ..write('franchiseId: $franchiseId, ')
          ..write('escaped: $escaped, ')
          ..write('timeLeftMinutes: $timeLeftMinutes')
          ..write(')'))
        .toString();
  }
}

class $MealsTable extends Meals with TableInfo<$MealsTable, MealRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MealsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _photoPathMeta = const VerificationMeta(
    'photoPath',
  );
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<double> rating = GeneratedColumn<double>(
    'rating',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reviewMeta = const VerificationMeta('review');
  @override
  late final GeneratedColumn<String> review = GeneratedColumn<String>(
    'review',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _happenedOnMeta = const VerificationMeta(
    'happenedOn',
  );
  @override
  late final GeneratedColumn<DateTime> happenedOn = GeneratedColumn<DateTime>(
    'happened_on',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dishMeta = const VerificationMeta('dish');
  @override
  late final GeneratedColumn<String> dish = GeneratedColumn<String>(
    'dish',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
    'price',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _companyMeta = const VerificationMeta(
    'company',
  );
  @override
  late final GeneratedColumn<String> company = GeneratedColumn<String>(
    'company',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    photoPath,
    description,
    rating,
    review,
    happenedOn,
    dish,
    price,
    company,
    location,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meals';
  @override
  VerificationContext validateIntegrity(
    Insertable<MealRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    if (data.containsKey('review')) {
      context.handle(
        _reviewMeta,
        review.isAcceptableOrUnknown(data['review']!, _reviewMeta),
      );
    }
    if (data.containsKey('happened_on')) {
      context.handle(
        _happenedOnMeta,
        happenedOn.isAcceptableOrUnknown(data['happened_on']!, _happenedOnMeta),
      );
    } else if (isInserting) {
      context.missing(_happenedOnMeta);
    }
    if (data.containsKey('dish')) {
      context.handle(
        _dishMeta,
        dish.isAcceptableOrUnknown(data['dish']!, _dishMeta),
      );
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    }
    if (data.containsKey('company')) {
      context.handle(
        _companyMeta,
        company.isAcceptableOrUnknown(data['company']!, _companyMeta),
      );
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MealRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MealRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rating'],
      ),
      review: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}review'],
      ),
      happenedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}happened_on'],
      )!,
      dish: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dish'],
      ),
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price'],
      ),
      company: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company'],
      ),
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
    );
  }

  @override
  $MealsTable createAlias(String alias) {
    return $MealsTable(attachedDatabase, alias);
  }
}

class MealRow extends DataClass implements Insertable<MealRow> {
  final int id;
  final String title;
  final String? photoPath;
  final String? description;
  final double? rating;
  final String? review;
  final DateTime happenedOn;
  final String? dish;
  final double? price;
  final String? company;
  final String? location;
  const MealRow({
    required this.id,
    required this.title,
    this.photoPath,
    this.description,
    this.rating,
    this.review,
    required this.happenedOn,
    this.dish,
    this.price,
    this.company,
    this.location,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<double>(rating);
    }
    if (!nullToAbsent || review != null) {
      map['review'] = Variable<String>(review);
    }
    map['happened_on'] = Variable<DateTime>(happenedOn);
    if (!nullToAbsent || dish != null) {
      map['dish'] = Variable<String>(dish);
    }
    if (!nullToAbsent || price != null) {
      map['price'] = Variable<double>(price);
    }
    if (!nullToAbsent || company != null) {
      map['company'] = Variable<String>(company);
    }
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    return map;
  }

  MealsCompanion toCompanion(bool nullToAbsent) {
    return MealsCompanion(
      id: Value(id),
      title: Value(title),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      rating: rating == null && nullToAbsent
          ? const Value.absent()
          : Value(rating),
      review: review == null && nullToAbsent
          ? const Value.absent()
          : Value(review),
      happenedOn: Value(happenedOn),
      dish: dish == null && nullToAbsent ? const Value.absent() : Value(dish),
      price: price == null && nullToAbsent
          ? const Value.absent()
          : Value(price),
      company: company == null && nullToAbsent
          ? const Value.absent()
          : Value(company),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
    );
  }

  factory MealRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MealRow(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      description: serializer.fromJson<String?>(json['description']),
      rating: serializer.fromJson<double?>(json['rating']),
      review: serializer.fromJson<String?>(json['review']),
      happenedOn: serializer.fromJson<DateTime>(json['happenedOn']),
      dish: serializer.fromJson<String?>(json['dish']),
      price: serializer.fromJson<double?>(json['price']),
      company: serializer.fromJson<String?>(json['company']),
      location: serializer.fromJson<String?>(json['location']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'photoPath': serializer.toJson<String?>(photoPath),
      'description': serializer.toJson<String?>(description),
      'rating': serializer.toJson<double?>(rating),
      'review': serializer.toJson<String?>(review),
      'happenedOn': serializer.toJson<DateTime>(happenedOn),
      'dish': serializer.toJson<String?>(dish),
      'price': serializer.toJson<double?>(price),
      'company': serializer.toJson<String?>(company),
      'location': serializer.toJson<String?>(location),
    };
  }

  MealRow copyWith({
    int? id,
    String? title,
    Value<String?> photoPath = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<double?> rating = const Value.absent(),
    Value<String?> review = const Value.absent(),
    DateTime? happenedOn,
    Value<String?> dish = const Value.absent(),
    Value<double?> price = const Value.absent(),
    Value<String?> company = const Value.absent(),
    Value<String?> location = const Value.absent(),
  }) => MealRow(
    id: id ?? this.id,
    title: title ?? this.title,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
    description: description.present ? description.value : this.description,
    rating: rating.present ? rating.value : this.rating,
    review: review.present ? review.value : this.review,
    happenedOn: happenedOn ?? this.happenedOn,
    dish: dish.present ? dish.value : this.dish,
    price: price.present ? price.value : this.price,
    company: company.present ? company.value : this.company,
    location: location.present ? location.value : this.location,
  );
  MealRow copyWithCompanion(MealsCompanion data) {
    return MealRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      description: data.description.present
          ? data.description.value
          : this.description,
      rating: data.rating.present ? data.rating.value : this.rating,
      review: data.review.present ? data.review.value : this.review,
      happenedOn: data.happenedOn.present
          ? data.happenedOn.value
          : this.happenedOn,
      dish: data.dish.present ? data.dish.value : this.dish,
      price: data.price.present ? data.price.value : this.price,
      company: data.company.present ? data.company.value : this.company,
      location: data.location.present ? data.location.value : this.location,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MealRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('photoPath: $photoPath, ')
          ..write('description: $description, ')
          ..write('rating: $rating, ')
          ..write('review: $review, ')
          ..write('happenedOn: $happenedOn, ')
          ..write('dish: $dish, ')
          ..write('price: $price, ')
          ..write('company: $company, ')
          ..write('location: $location')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    photoPath,
    description,
    rating,
    review,
    happenedOn,
    dish,
    price,
    company,
    location,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MealRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.photoPath == this.photoPath &&
          other.description == this.description &&
          other.rating == this.rating &&
          other.review == this.review &&
          other.happenedOn == this.happenedOn &&
          other.dish == this.dish &&
          other.price == this.price &&
          other.company == this.company &&
          other.location == this.location);
}

class MealsCompanion extends UpdateCompanion<MealRow> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> photoPath;
  final Value<String?> description;
  final Value<double?> rating;
  final Value<String?> review;
  final Value<DateTime> happenedOn;
  final Value<String?> dish;
  final Value<double?> price;
  final Value<String?> company;
  final Value<String?> location;
  const MealsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.description = const Value.absent(),
    this.rating = const Value.absent(),
    this.review = const Value.absent(),
    this.happenedOn = const Value.absent(),
    this.dish = const Value.absent(),
    this.price = const Value.absent(),
    this.company = const Value.absent(),
    this.location = const Value.absent(),
  });
  MealsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.photoPath = const Value.absent(),
    this.description = const Value.absent(),
    this.rating = const Value.absent(),
    this.review = const Value.absent(),
    required DateTime happenedOn,
    this.dish = const Value.absent(),
    this.price = const Value.absent(),
    this.company = const Value.absent(),
    this.location = const Value.absent(),
  }) : title = Value(title),
       happenedOn = Value(happenedOn);
  static Insertable<MealRow> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? photoPath,
    Expression<String>? description,
    Expression<double>? rating,
    Expression<String>? review,
    Expression<DateTime>? happenedOn,
    Expression<String>? dish,
    Expression<double>? price,
    Expression<String>? company,
    Expression<String>? location,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (photoPath != null) 'photo_path': photoPath,
      if (description != null) 'description': description,
      if (rating != null) 'rating': rating,
      if (review != null) 'review': review,
      if (happenedOn != null) 'happened_on': happenedOn,
      if (dish != null) 'dish': dish,
      if (price != null) 'price': price,
      if (company != null) 'company': company,
      if (location != null) 'location': location,
    });
  }

  MealsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String?>? photoPath,
    Value<String?>? description,
    Value<double?>? rating,
    Value<String?>? review,
    Value<DateTime>? happenedOn,
    Value<String?>? dish,
    Value<double?>? price,
    Value<String?>? company,
    Value<String?>? location,
  }) {
    return MealsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      photoPath: photoPath ?? this.photoPath,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      happenedOn: happenedOn ?? this.happenedOn,
      dish: dish ?? this.dish,
      price: price ?? this.price,
      company: company ?? this.company,
      location: location ?? this.location,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (rating.present) {
      map['rating'] = Variable<double>(rating.value);
    }
    if (review.present) {
      map['review'] = Variable<String>(review.value);
    }
    if (happenedOn.present) {
      map['happened_on'] = Variable<DateTime>(happenedOn.value);
    }
    if (dish.present) {
      map['dish'] = Variable<String>(dish.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (company.present) {
      map['company'] = Variable<String>(company.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MealsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('photoPath: $photoPath, ')
          ..write('description: $description, ')
          ..write('rating: $rating, ')
          ..write('review: $review, ')
          ..write('happenedOn: $happenedOn, ')
          ..write('dish: $dish, ')
          ..write('price: $price, ')
          ..write('company: $company, ')
          ..write('location: $location')
          ..write(')'))
        .toString();
  }
}

class $GigsTable extends Gigs with TableInfo<$GigsTable, GigRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GigsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _photoPathMeta = const VerificationMeta(
    'photoPath',
  );
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<double> rating = GeneratedColumn<double>(
    'rating',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reviewMeta = const VerificationMeta('review');
  @override
  late final GeneratedColumn<String> review = GeneratedColumn<String>(
    'review',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _happenedOnMeta = const VerificationMeta(
    'happenedOn',
  );
  @override
  late final GeneratedColumn<DateTime> happenedOn = GeneratedColumn<DateTime>(
    'happened_on',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _venueMeta = const VerificationMeta('venue');
  @override
  late final GeneratedColumn<String> venue = GeneratedColumn<String>(
    'venue',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String> city = GeneratedColumn<String>(
    'city',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _supportActsMeta = const VerificationMeta(
    'supportActs',
  );
  @override
  late final GeneratedColumn<String> supportActs = GeneratedColumn<String>(
    'support_acts',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _setlistMeta = const VerificationMeta(
    'setlist',
  );
  @override
  late final GeneratedColumn<String> setlist = GeneratedColumn<String>(
    'setlist',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _companyMeta = const VerificationMeta(
    'company',
  );
  @override
  late final GeneratedColumn<String> company = GeneratedColumn<String>(
    'company',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _externalIdMeta = const VerificationMeta(
    'externalId',
  );
  @override
  late final GeneratedColumn<String> externalId = GeneratedColumn<String>(
    'external_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    photoPath,
    description,
    rating,
    review,
    happenedOn,
    venue,
    city,
    supportActs,
    setlist,
    company,
    externalId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gigs';
  @override
  VerificationContext validateIntegrity(
    Insertable<GigRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    if (data.containsKey('review')) {
      context.handle(
        _reviewMeta,
        review.isAcceptableOrUnknown(data['review']!, _reviewMeta),
      );
    }
    if (data.containsKey('happened_on')) {
      context.handle(
        _happenedOnMeta,
        happenedOn.isAcceptableOrUnknown(data['happened_on']!, _happenedOnMeta),
      );
    } else if (isInserting) {
      context.missing(_happenedOnMeta);
    }
    if (data.containsKey('venue')) {
      context.handle(
        _venueMeta,
        venue.isAcceptableOrUnknown(data['venue']!, _venueMeta),
      );
    }
    if (data.containsKey('city')) {
      context.handle(
        _cityMeta,
        city.isAcceptableOrUnknown(data['city']!, _cityMeta),
      );
    }
    if (data.containsKey('support_acts')) {
      context.handle(
        _supportActsMeta,
        supportActs.isAcceptableOrUnknown(
          data['support_acts']!,
          _supportActsMeta,
        ),
      );
    }
    if (data.containsKey('setlist')) {
      context.handle(
        _setlistMeta,
        setlist.isAcceptableOrUnknown(data['setlist']!, _setlistMeta),
      );
    }
    if (data.containsKey('company')) {
      context.handle(
        _companyMeta,
        company.isAcceptableOrUnknown(data['company']!, _companyMeta),
      );
    }
    if (data.containsKey('external_id')) {
      context.handle(
        _externalIdMeta,
        externalId.isAcceptableOrUnknown(data['external_id']!, _externalIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GigRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GigRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rating'],
      ),
      review: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}review'],
      ),
      happenedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}happened_on'],
      )!,
      venue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}venue'],
      ),
      city: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city'],
      ),
      supportActs: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}support_acts'],
      ),
      setlist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}setlist'],
      ),
      company: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company'],
      ),
      externalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_id'],
      ),
    );
  }

  @override
  $GigsTable createAlias(String alias) {
    return $GigsTable(attachedDatabase, alias);
  }
}

class GigRow extends DataClass implements Insertable<GigRow> {
  final int id;
  final String title;
  final String? photoPath;
  final String? description;
  final double? rating;
  final String? review;
  final DateTime happenedOn;
  final String? venue;
  final String? city;
  final String? supportActs;
  final String? setlist;
  final String? company;

  /// MusicBrainz artist id, cached from an enrichment lookup.
  final String? externalId;
  const GigRow({
    required this.id,
    required this.title,
    this.photoPath,
    this.description,
    this.rating,
    this.review,
    required this.happenedOn,
    this.venue,
    this.city,
    this.supportActs,
    this.setlist,
    this.company,
    this.externalId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<double>(rating);
    }
    if (!nullToAbsent || review != null) {
      map['review'] = Variable<String>(review);
    }
    map['happened_on'] = Variable<DateTime>(happenedOn);
    if (!nullToAbsent || venue != null) {
      map['venue'] = Variable<String>(venue);
    }
    if (!nullToAbsent || city != null) {
      map['city'] = Variable<String>(city);
    }
    if (!nullToAbsent || supportActs != null) {
      map['support_acts'] = Variable<String>(supportActs);
    }
    if (!nullToAbsent || setlist != null) {
      map['setlist'] = Variable<String>(setlist);
    }
    if (!nullToAbsent || company != null) {
      map['company'] = Variable<String>(company);
    }
    if (!nullToAbsent || externalId != null) {
      map['external_id'] = Variable<String>(externalId);
    }
    return map;
  }

  GigsCompanion toCompanion(bool nullToAbsent) {
    return GigsCompanion(
      id: Value(id),
      title: Value(title),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      rating: rating == null && nullToAbsent
          ? const Value.absent()
          : Value(rating),
      review: review == null && nullToAbsent
          ? const Value.absent()
          : Value(review),
      happenedOn: Value(happenedOn),
      venue: venue == null && nullToAbsent
          ? const Value.absent()
          : Value(venue),
      city: city == null && nullToAbsent ? const Value.absent() : Value(city),
      supportActs: supportActs == null && nullToAbsent
          ? const Value.absent()
          : Value(supportActs),
      setlist: setlist == null && nullToAbsent
          ? const Value.absent()
          : Value(setlist),
      company: company == null && nullToAbsent
          ? const Value.absent()
          : Value(company),
      externalId: externalId == null && nullToAbsent
          ? const Value.absent()
          : Value(externalId),
    );
  }

  factory GigRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GigRow(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      description: serializer.fromJson<String?>(json['description']),
      rating: serializer.fromJson<double?>(json['rating']),
      review: serializer.fromJson<String?>(json['review']),
      happenedOn: serializer.fromJson<DateTime>(json['happenedOn']),
      venue: serializer.fromJson<String?>(json['venue']),
      city: serializer.fromJson<String?>(json['city']),
      supportActs: serializer.fromJson<String?>(json['supportActs']),
      setlist: serializer.fromJson<String?>(json['setlist']),
      company: serializer.fromJson<String?>(json['company']),
      externalId: serializer.fromJson<String?>(json['externalId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'photoPath': serializer.toJson<String?>(photoPath),
      'description': serializer.toJson<String?>(description),
      'rating': serializer.toJson<double?>(rating),
      'review': serializer.toJson<String?>(review),
      'happenedOn': serializer.toJson<DateTime>(happenedOn),
      'venue': serializer.toJson<String?>(venue),
      'city': serializer.toJson<String?>(city),
      'supportActs': serializer.toJson<String?>(supportActs),
      'setlist': serializer.toJson<String?>(setlist),
      'company': serializer.toJson<String?>(company),
      'externalId': serializer.toJson<String?>(externalId),
    };
  }

  GigRow copyWith({
    int? id,
    String? title,
    Value<String?> photoPath = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<double?> rating = const Value.absent(),
    Value<String?> review = const Value.absent(),
    DateTime? happenedOn,
    Value<String?> venue = const Value.absent(),
    Value<String?> city = const Value.absent(),
    Value<String?> supportActs = const Value.absent(),
    Value<String?> setlist = const Value.absent(),
    Value<String?> company = const Value.absent(),
    Value<String?> externalId = const Value.absent(),
  }) => GigRow(
    id: id ?? this.id,
    title: title ?? this.title,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
    description: description.present ? description.value : this.description,
    rating: rating.present ? rating.value : this.rating,
    review: review.present ? review.value : this.review,
    happenedOn: happenedOn ?? this.happenedOn,
    venue: venue.present ? venue.value : this.venue,
    city: city.present ? city.value : this.city,
    supportActs: supportActs.present ? supportActs.value : this.supportActs,
    setlist: setlist.present ? setlist.value : this.setlist,
    company: company.present ? company.value : this.company,
    externalId: externalId.present ? externalId.value : this.externalId,
  );
  GigRow copyWithCompanion(GigsCompanion data) {
    return GigRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      description: data.description.present
          ? data.description.value
          : this.description,
      rating: data.rating.present ? data.rating.value : this.rating,
      review: data.review.present ? data.review.value : this.review,
      happenedOn: data.happenedOn.present
          ? data.happenedOn.value
          : this.happenedOn,
      venue: data.venue.present ? data.venue.value : this.venue,
      city: data.city.present ? data.city.value : this.city,
      supportActs: data.supportActs.present
          ? data.supportActs.value
          : this.supportActs,
      setlist: data.setlist.present ? data.setlist.value : this.setlist,
      company: data.company.present ? data.company.value : this.company,
      externalId: data.externalId.present
          ? data.externalId.value
          : this.externalId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GigRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('photoPath: $photoPath, ')
          ..write('description: $description, ')
          ..write('rating: $rating, ')
          ..write('review: $review, ')
          ..write('happenedOn: $happenedOn, ')
          ..write('venue: $venue, ')
          ..write('city: $city, ')
          ..write('supportActs: $supportActs, ')
          ..write('setlist: $setlist, ')
          ..write('company: $company, ')
          ..write('externalId: $externalId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    photoPath,
    description,
    rating,
    review,
    happenedOn,
    venue,
    city,
    supportActs,
    setlist,
    company,
    externalId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GigRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.photoPath == this.photoPath &&
          other.description == this.description &&
          other.rating == this.rating &&
          other.review == this.review &&
          other.happenedOn == this.happenedOn &&
          other.venue == this.venue &&
          other.city == this.city &&
          other.supportActs == this.supportActs &&
          other.setlist == this.setlist &&
          other.company == this.company &&
          other.externalId == this.externalId);
}

class GigsCompanion extends UpdateCompanion<GigRow> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> photoPath;
  final Value<String?> description;
  final Value<double?> rating;
  final Value<String?> review;
  final Value<DateTime> happenedOn;
  final Value<String?> venue;
  final Value<String?> city;
  final Value<String?> supportActs;
  final Value<String?> setlist;
  final Value<String?> company;
  final Value<String?> externalId;
  const GigsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.description = const Value.absent(),
    this.rating = const Value.absent(),
    this.review = const Value.absent(),
    this.happenedOn = const Value.absent(),
    this.venue = const Value.absent(),
    this.city = const Value.absent(),
    this.supportActs = const Value.absent(),
    this.setlist = const Value.absent(),
    this.company = const Value.absent(),
    this.externalId = const Value.absent(),
  });
  GigsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.photoPath = const Value.absent(),
    this.description = const Value.absent(),
    this.rating = const Value.absent(),
    this.review = const Value.absent(),
    required DateTime happenedOn,
    this.venue = const Value.absent(),
    this.city = const Value.absent(),
    this.supportActs = const Value.absent(),
    this.setlist = const Value.absent(),
    this.company = const Value.absent(),
    this.externalId = const Value.absent(),
  }) : title = Value(title),
       happenedOn = Value(happenedOn);
  static Insertable<GigRow> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? photoPath,
    Expression<String>? description,
    Expression<double>? rating,
    Expression<String>? review,
    Expression<DateTime>? happenedOn,
    Expression<String>? venue,
    Expression<String>? city,
    Expression<String>? supportActs,
    Expression<String>? setlist,
    Expression<String>? company,
    Expression<String>? externalId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (photoPath != null) 'photo_path': photoPath,
      if (description != null) 'description': description,
      if (rating != null) 'rating': rating,
      if (review != null) 'review': review,
      if (happenedOn != null) 'happened_on': happenedOn,
      if (venue != null) 'venue': venue,
      if (city != null) 'city': city,
      if (supportActs != null) 'support_acts': supportActs,
      if (setlist != null) 'setlist': setlist,
      if (company != null) 'company': company,
      if (externalId != null) 'external_id': externalId,
    });
  }

  GigsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String?>? photoPath,
    Value<String?>? description,
    Value<double?>? rating,
    Value<String?>? review,
    Value<DateTime>? happenedOn,
    Value<String?>? venue,
    Value<String?>? city,
    Value<String?>? supportActs,
    Value<String?>? setlist,
    Value<String?>? company,
    Value<String?>? externalId,
  }) {
    return GigsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      photoPath: photoPath ?? this.photoPath,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      happenedOn: happenedOn ?? this.happenedOn,
      venue: venue ?? this.venue,
      city: city ?? this.city,
      supportActs: supportActs ?? this.supportActs,
      setlist: setlist ?? this.setlist,
      company: company ?? this.company,
      externalId: externalId ?? this.externalId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (rating.present) {
      map['rating'] = Variable<double>(rating.value);
    }
    if (review.present) {
      map['review'] = Variable<String>(review.value);
    }
    if (happenedOn.present) {
      map['happened_on'] = Variable<DateTime>(happenedOn.value);
    }
    if (venue.present) {
      map['venue'] = Variable<String>(venue.value);
    }
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (supportActs.present) {
      map['support_acts'] = Variable<String>(supportActs.value);
    }
    if (setlist.present) {
      map['setlist'] = Variable<String>(setlist.value);
    }
    if (company.present) {
      map['company'] = Variable<String>(company.value);
    }
    if (externalId.present) {
      map['external_id'] = Variable<String>(externalId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GigsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('photoPath: $photoPath, ')
          ..write('description: $description, ')
          ..write('rating: $rating, ')
          ..write('review: $review, ')
          ..write('happenedOn: $happenedOn, ')
          ..write('venue: $venue, ')
          ..write('city: $city, ')
          ..write('supportActs: $supportActs, ')
          ..write('setlist: $setlist, ')
          ..write('company: $company, ')
          ..write('externalId: $externalId')
          ..write(')'))
        .toString();
  }
}

class $ViewingsTable extends Viewings
    with TableInfo<$ViewingsTable, ViewingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ViewingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _photoPathMeta = const VerificationMeta(
    'photoPath',
  );
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<double> rating = GeneratedColumn<double>(
    'rating',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reviewMeta = const VerificationMeta('review');
  @override
  late final GeneratedColumn<String> review = GeneratedColumn<String>(
    'review',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _happenedOnMeta = const VerificationMeta(
    'happenedOn',
  );
  @override
  late final GeneratedColumn<DateTime> happenedOn = GeneratedColumn<DateTime>(
    'happened_on',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ViewingKind, int> kind =
      GeneratedColumn<int>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<ViewingKind>($ViewingsTable.$converterkind);
  static const VerificationMeta _releaseYearMeta = const VerificationMeta(
    'releaseYear',
  );
  @override
  late final GeneratedColumn<int> releaseYear = GeneratedColumn<int>(
    'release_year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _directorMeta = const VerificationMeta(
    'director',
  );
  @override
  late final GeneratedColumn<String> director = GeneratedColumn<String>(
    'director',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _castMeta = const VerificationMeta('cast');
  @override
  late final GeneratedColumn<String> cast = GeneratedColumn<String>(
    'cast',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _seasonMeta = const VerificationMeta('season');
  @override
  late final GeneratedColumn<int> season = GeneratedColumn<int>(
    'season',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _externalIdMeta = const VerificationMeta(
    'externalId',
  );
  @override
  late final GeneratedColumn<String> externalId = GeneratedColumn<String>(
    'external_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    photoPath,
    description,
    rating,
    review,
    happenedOn,
    kind,
    releaseYear,
    director,
    cast,
    season,
    externalId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'viewings';
  @override
  VerificationContext validateIntegrity(
    Insertable<ViewingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    if (data.containsKey('review')) {
      context.handle(
        _reviewMeta,
        review.isAcceptableOrUnknown(data['review']!, _reviewMeta),
      );
    }
    if (data.containsKey('happened_on')) {
      context.handle(
        _happenedOnMeta,
        happenedOn.isAcceptableOrUnknown(data['happened_on']!, _happenedOnMeta),
      );
    } else if (isInserting) {
      context.missing(_happenedOnMeta);
    }
    if (data.containsKey('release_year')) {
      context.handle(
        _releaseYearMeta,
        releaseYear.isAcceptableOrUnknown(
          data['release_year']!,
          _releaseYearMeta,
        ),
      );
    }
    if (data.containsKey('director')) {
      context.handle(
        _directorMeta,
        director.isAcceptableOrUnknown(data['director']!, _directorMeta),
      );
    }
    if (data.containsKey('cast')) {
      context.handle(
        _castMeta,
        cast.isAcceptableOrUnknown(data['cast']!, _castMeta),
      );
    }
    if (data.containsKey('season')) {
      context.handle(
        _seasonMeta,
        season.isAcceptableOrUnknown(data['season']!, _seasonMeta),
      );
    }
    if (data.containsKey('external_id')) {
      context.handle(
        _externalIdMeta,
        externalId.isAcceptableOrUnknown(data['external_id']!, _externalIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ViewingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ViewingRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rating'],
      ),
      review: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}review'],
      ),
      happenedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}happened_on'],
      )!,
      kind: $ViewingsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}kind'],
        )!,
      ),
      releaseYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}release_year'],
      ),
      director: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}director'],
      ),
      cast: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cast'],
      ),
      season: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}season'],
      ),
      externalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_id'],
      ),
    );
  }

  @override
  $ViewingsTable createAlias(String alias) {
    return $ViewingsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ViewingKind, int, int> $converterkind =
      const EnumIndexConverter<ViewingKind>(ViewingKind.values);
}

class ViewingRow extends DataClass implements Insertable<ViewingRow> {
  final int id;
  final String title;
  final String? photoPath;
  final String? description;
  final double? rating;
  final String? review;
  final DateTime happenedOn;

  /// Stored by index rather than name: the set is closed and owned by this
  /// app, so a rename never has to touch stored rows.
  final ViewingKind kind;
  final int? releaseYear;
  final String? director;
  final String? cast;
  final int? season;

  /// TMDB id, cached from an enrichment lookup.
  final String? externalId;
  const ViewingRow({
    required this.id,
    required this.title,
    this.photoPath,
    this.description,
    this.rating,
    this.review,
    required this.happenedOn,
    required this.kind,
    this.releaseYear,
    this.director,
    this.cast,
    this.season,
    this.externalId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<double>(rating);
    }
    if (!nullToAbsent || review != null) {
      map['review'] = Variable<String>(review);
    }
    map['happened_on'] = Variable<DateTime>(happenedOn);
    {
      map['kind'] = Variable<int>($ViewingsTable.$converterkind.toSql(kind));
    }
    if (!nullToAbsent || releaseYear != null) {
      map['release_year'] = Variable<int>(releaseYear);
    }
    if (!nullToAbsent || director != null) {
      map['director'] = Variable<String>(director);
    }
    if (!nullToAbsent || cast != null) {
      map['cast'] = Variable<String>(cast);
    }
    if (!nullToAbsent || season != null) {
      map['season'] = Variable<int>(season);
    }
    if (!nullToAbsent || externalId != null) {
      map['external_id'] = Variable<String>(externalId);
    }
    return map;
  }

  ViewingsCompanion toCompanion(bool nullToAbsent) {
    return ViewingsCompanion(
      id: Value(id),
      title: Value(title),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      rating: rating == null && nullToAbsent
          ? const Value.absent()
          : Value(rating),
      review: review == null && nullToAbsent
          ? const Value.absent()
          : Value(review),
      happenedOn: Value(happenedOn),
      kind: Value(kind),
      releaseYear: releaseYear == null && nullToAbsent
          ? const Value.absent()
          : Value(releaseYear),
      director: director == null && nullToAbsent
          ? const Value.absent()
          : Value(director),
      cast: cast == null && nullToAbsent ? const Value.absent() : Value(cast),
      season: season == null && nullToAbsent
          ? const Value.absent()
          : Value(season),
      externalId: externalId == null && nullToAbsent
          ? const Value.absent()
          : Value(externalId),
    );
  }

  factory ViewingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ViewingRow(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      description: serializer.fromJson<String?>(json['description']),
      rating: serializer.fromJson<double?>(json['rating']),
      review: serializer.fromJson<String?>(json['review']),
      happenedOn: serializer.fromJson<DateTime>(json['happenedOn']),
      kind: $ViewingsTable.$converterkind.fromJson(
        serializer.fromJson<int>(json['kind']),
      ),
      releaseYear: serializer.fromJson<int?>(json['releaseYear']),
      director: serializer.fromJson<String?>(json['director']),
      cast: serializer.fromJson<String?>(json['cast']),
      season: serializer.fromJson<int?>(json['season']),
      externalId: serializer.fromJson<String?>(json['externalId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'photoPath': serializer.toJson<String?>(photoPath),
      'description': serializer.toJson<String?>(description),
      'rating': serializer.toJson<double?>(rating),
      'review': serializer.toJson<String?>(review),
      'happenedOn': serializer.toJson<DateTime>(happenedOn),
      'kind': serializer.toJson<int>(
        $ViewingsTable.$converterkind.toJson(kind),
      ),
      'releaseYear': serializer.toJson<int?>(releaseYear),
      'director': serializer.toJson<String?>(director),
      'cast': serializer.toJson<String?>(cast),
      'season': serializer.toJson<int?>(season),
      'externalId': serializer.toJson<String?>(externalId),
    };
  }

  ViewingRow copyWith({
    int? id,
    String? title,
    Value<String?> photoPath = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<double?> rating = const Value.absent(),
    Value<String?> review = const Value.absent(),
    DateTime? happenedOn,
    ViewingKind? kind,
    Value<int?> releaseYear = const Value.absent(),
    Value<String?> director = const Value.absent(),
    Value<String?> cast = const Value.absent(),
    Value<int?> season = const Value.absent(),
    Value<String?> externalId = const Value.absent(),
  }) => ViewingRow(
    id: id ?? this.id,
    title: title ?? this.title,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
    description: description.present ? description.value : this.description,
    rating: rating.present ? rating.value : this.rating,
    review: review.present ? review.value : this.review,
    happenedOn: happenedOn ?? this.happenedOn,
    kind: kind ?? this.kind,
    releaseYear: releaseYear.present ? releaseYear.value : this.releaseYear,
    director: director.present ? director.value : this.director,
    cast: cast.present ? cast.value : this.cast,
    season: season.present ? season.value : this.season,
    externalId: externalId.present ? externalId.value : this.externalId,
  );
  ViewingRow copyWithCompanion(ViewingsCompanion data) {
    return ViewingRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      description: data.description.present
          ? data.description.value
          : this.description,
      rating: data.rating.present ? data.rating.value : this.rating,
      review: data.review.present ? data.review.value : this.review,
      happenedOn: data.happenedOn.present
          ? data.happenedOn.value
          : this.happenedOn,
      kind: data.kind.present ? data.kind.value : this.kind,
      releaseYear: data.releaseYear.present
          ? data.releaseYear.value
          : this.releaseYear,
      director: data.director.present ? data.director.value : this.director,
      cast: data.cast.present ? data.cast.value : this.cast,
      season: data.season.present ? data.season.value : this.season,
      externalId: data.externalId.present
          ? data.externalId.value
          : this.externalId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ViewingRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('photoPath: $photoPath, ')
          ..write('description: $description, ')
          ..write('rating: $rating, ')
          ..write('review: $review, ')
          ..write('happenedOn: $happenedOn, ')
          ..write('kind: $kind, ')
          ..write('releaseYear: $releaseYear, ')
          ..write('director: $director, ')
          ..write('cast: $cast, ')
          ..write('season: $season, ')
          ..write('externalId: $externalId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    photoPath,
    description,
    rating,
    review,
    happenedOn,
    kind,
    releaseYear,
    director,
    cast,
    season,
    externalId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ViewingRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.photoPath == this.photoPath &&
          other.description == this.description &&
          other.rating == this.rating &&
          other.review == this.review &&
          other.happenedOn == this.happenedOn &&
          other.kind == this.kind &&
          other.releaseYear == this.releaseYear &&
          other.director == this.director &&
          other.cast == this.cast &&
          other.season == this.season &&
          other.externalId == this.externalId);
}

class ViewingsCompanion extends UpdateCompanion<ViewingRow> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> photoPath;
  final Value<String?> description;
  final Value<double?> rating;
  final Value<String?> review;
  final Value<DateTime> happenedOn;
  final Value<ViewingKind> kind;
  final Value<int?> releaseYear;
  final Value<String?> director;
  final Value<String?> cast;
  final Value<int?> season;
  final Value<String?> externalId;
  const ViewingsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.description = const Value.absent(),
    this.rating = const Value.absent(),
    this.review = const Value.absent(),
    this.happenedOn = const Value.absent(),
    this.kind = const Value.absent(),
    this.releaseYear = const Value.absent(),
    this.director = const Value.absent(),
    this.cast = const Value.absent(),
    this.season = const Value.absent(),
    this.externalId = const Value.absent(),
  });
  ViewingsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.photoPath = const Value.absent(),
    this.description = const Value.absent(),
    this.rating = const Value.absent(),
    this.review = const Value.absent(),
    required DateTime happenedOn,
    required ViewingKind kind,
    this.releaseYear = const Value.absent(),
    this.director = const Value.absent(),
    this.cast = const Value.absent(),
    this.season = const Value.absent(),
    this.externalId = const Value.absent(),
  }) : title = Value(title),
       happenedOn = Value(happenedOn),
       kind = Value(kind);
  static Insertable<ViewingRow> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? photoPath,
    Expression<String>? description,
    Expression<double>? rating,
    Expression<String>? review,
    Expression<DateTime>? happenedOn,
    Expression<int>? kind,
    Expression<int>? releaseYear,
    Expression<String>? director,
    Expression<String>? cast,
    Expression<int>? season,
    Expression<String>? externalId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (photoPath != null) 'photo_path': photoPath,
      if (description != null) 'description': description,
      if (rating != null) 'rating': rating,
      if (review != null) 'review': review,
      if (happenedOn != null) 'happened_on': happenedOn,
      if (kind != null) 'kind': kind,
      if (releaseYear != null) 'release_year': releaseYear,
      if (director != null) 'director': director,
      if (cast != null) 'cast': cast,
      if (season != null) 'season': season,
      if (externalId != null) 'external_id': externalId,
    });
  }

  ViewingsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String?>? photoPath,
    Value<String?>? description,
    Value<double?>? rating,
    Value<String?>? review,
    Value<DateTime>? happenedOn,
    Value<ViewingKind>? kind,
    Value<int?>? releaseYear,
    Value<String?>? director,
    Value<String?>? cast,
    Value<int?>? season,
    Value<String?>? externalId,
  }) {
    return ViewingsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      photoPath: photoPath ?? this.photoPath,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      happenedOn: happenedOn ?? this.happenedOn,
      kind: kind ?? this.kind,
      releaseYear: releaseYear ?? this.releaseYear,
      director: director ?? this.director,
      cast: cast ?? this.cast,
      season: season ?? this.season,
      externalId: externalId ?? this.externalId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (rating.present) {
      map['rating'] = Variable<double>(rating.value);
    }
    if (review.present) {
      map['review'] = Variable<String>(review.value);
    }
    if (happenedOn.present) {
      map['happened_on'] = Variable<DateTime>(happenedOn.value);
    }
    if (kind.present) {
      map['kind'] = Variable<int>(
        $ViewingsTable.$converterkind.toSql(kind.value),
      );
    }
    if (releaseYear.present) {
      map['release_year'] = Variable<int>(releaseYear.value);
    }
    if (director.present) {
      map['director'] = Variable<String>(director.value);
    }
    if (cast.present) {
      map['cast'] = Variable<String>(cast.value);
    }
    if (season.present) {
      map['season'] = Variable<int>(season.value);
    }
    if (externalId.present) {
      map['external_id'] = Variable<String>(externalId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ViewingsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('photoPath: $photoPath, ')
          ..write('description: $description, ')
          ..write('rating: $rating, ')
          ..write('review: $review, ')
          ..write('happenedOn: $happenedOn, ')
          ..write('kind: $kind, ')
          ..write('releaseYear: $releaseYear, ')
          ..write('director: $director, ')
          ..write('cast: $cast, ')
          ..write('season: $season, ')
          ..write('externalId: $externalId')
          ..write(')'))
        .toString();
  }
}

class $GamesTable extends Games with TableInfo<$GamesTable, GameRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GamesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _photoPathMeta = const VerificationMeta(
    'photoPath',
  );
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<double> rating = GeneratedColumn<double>(
    'rating',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reviewMeta = const VerificationMeta('review');
  @override
  late final GeneratedColumn<String> review = GeneratedColumn<String>(
    'review',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _happenedOnMeta = const VerificationMeta(
    'happenedOn',
  );
  @override
  late final GeneratedColumn<DateTime> happenedOn = GeneratedColumn<DateTime>(
    'happened_on',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<GameStatus, int> status =
      GeneratedColumn<int>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<GameStatus>($GamesTable.$converterstatus);
  static const VerificationMeta _platformMeta = const VerificationMeta(
    'platform',
  );
  @override
  late final GeneratedColumn<String> platform = GeneratedColumn<String>(
    'platform',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hoursPlayedMeta = const VerificationMeta(
    'hoursPlayed',
  );
  @override
  late final GeneratedColumn<double> hoursPlayed = GeneratedColumn<double>(
    'hours_played',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _releaseYearMeta = const VerificationMeta(
    'releaseYear',
  );
  @override
  late final GeneratedColumn<int> releaseYear = GeneratedColumn<int>(
    'release_year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _externalIdMeta = const VerificationMeta(
    'externalId',
  );
  @override
  late final GeneratedColumn<String> externalId = GeneratedColumn<String>(
    'external_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    photoPath,
    description,
    rating,
    review,
    happenedOn,
    status,
    platform,
    hoursPlayed,
    releaseYear,
    externalId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'games';
  @override
  VerificationContext validateIntegrity(
    Insertable<GameRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    if (data.containsKey('review')) {
      context.handle(
        _reviewMeta,
        review.isAcceptableOrUnknown(data['review']!, _reviewMeta),
      );
    }
    if (data.containsKey('happened_on')) {
      context.handle(
        _happenedOnMeta,
        happenedOn.isAcceptableOrUnknown(data['happened_on']!, _happenedOnMeta),
      );
    } else if (isInserting) {
      context.missing(_happenedOnMeta);
    }
    if (data.containsKey('platform')) {
      context.handle(
        _platformMeta,
        platform.isAcceptableOrUnknown(data['platform']!, _platformMeta),
      );
    }
    if (data.containsKey('hours_played')) {
      context.handle(
        _hoursPlayedMeta,
        hoursPlayed.isAcceptableOrUnknown(
          data['hours_played']!,
          _hoursPlayedMeta,
        ),
      );
    }
    if (data.containsKey('release_year')) {
      context.handle(
        _releaseYearMeta,
        releaseYear.isAcceptableOrUnknown(
          data['release_year']!,
          _releaseYearMeta,
        ),
      );
    }
    if (data.containsKey('external_id')) {
      context.handle(
        _externalIdMeta,
        externalId.isAcceptableOrUnknown(data['external_id']!, _externalIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GameRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GameRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rating'],
      ),
      review: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}review'],
      ),
      happenedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}happened_on'],
      )!,
      status: $GamesTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}status'],
        )!,
      ),
      platform: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}platform'],
      ),
      hoursPlayed: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hours_played'],
      ),
      releaseYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}release_year'],
      ),
      externalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_id'],
      ),
    );
  }

  @override
  $GamesTable createAlias(String alias) {
    return $GamesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<GameStatus, int, int> $converterstatus =
      const EnumIndexConverter<GameStatus>(GameStatus.values);
}

class GameRow extends DataClass implements Insertable<GameRow> {
  final int id;
  final String title;
  final String? photoPath;
  final String? description;
  final double? rating;
  final String? review;
  final DateTime happenedOn;
  final GameStatus status;
  final String? platform;
  final double? hoursPlayed;
  final int? releaseYear;

  /// RAWG or IGDB id, cached from an enrichment lookup.
  final String? externalId;
  const GameRow({
    required this.id,
    required this.title,
    this.photoPath,
    this.description,
    this.rating,
    this.review,
    required this.happenedOn,
    required this.status,
    this.platform,
    this.hoursPlayed,
    this.releaseYear,
    this.externalId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<double>(rating);
    }
    if (!nullToAbsent || review != null) {
      map['review'] = Variable<String>(review);
    }
    map['happened_on'] = Variable<DateTime>(happenedOn);
    {
      map['status'] = Variable<int>($GamesTable.$converterstatus.toSql(status));
    }
    if (!nullToAbsent || platform != null) {
      map['platform'] = Variable<String>(platform);
    }
    if (!nullToAbsent || hoursPlayed != null) {
      map['hours_played'] = Variable<double>(hoursPlayed);
    }
    if (!nullToAbsent || releaseYear != null) {
      map['release_year'] = Variable<int>(releaseYear);
    }
    if (!nullToAbsent || externalId != null) {
      map['external_id'] = Variable<String>(externalId);
    }
    return map;
  }

  GamesCompanion toCompanion(bool nullToAbsent) {
    return GamesCompanion(
      id: Value(id),
      title: Value(title),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      rating: rating == null && nullToAbsent
          ? const Value.absent()
          : Value(rating),
      review: review == null && nullToAbsent
          ? const Value.absent()
          : Value(review),
      happenedOn: Value(happenedOn),
      status: Value(status),
      platform: platform == null && nullToAbsent
          ? const Value.absent()
          : Value(platform),
      hoursPlayed: hoursPlayed == null && nullToAbsent
          ? const Value.absent()
          : Value(hoursPlayed),
      releaseYear: releaseYear == null && nullToAbsent
          ? const Value.absent()
          : Value(releaseYear),
      externalId: externalId == null && nullToAbsent
          ? const Value.absent()
          : Value(externalId),
    );
  }

  factory GameRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GameRow(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      description: serializer.fromJson<String?>(json['description']),
      rating: serializer.fromJson<double?>(json['rating']),
      review: serializer.fromJson<String?>(json['review']),
      happenedOn: serializer.fromJson<DateTime>(json['happenedOn']),
      status: $GamesTable.$converterstatus.fromJson(
        serializer.fromJson<int>(json['status']),
      ),
      platform: serializer.fromJson<String?>(json['platform']),
      hoursPlayed: serializer.fromJson<double?>(json['hoursPlayed']),
      releaseYear: serializer.fromJson<int?>(json['releaseYear']),
      externalId: serializer.fromJson<String?>(json['externalId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'photoPath': serializer.toJson<String?>(photoPath),
      'description': serializer.toJson<String?>(description),
      'rating': serializer.toJson<double?>(rating),
      'review': serializer.toJson<String?>(review),
      'happenedOn': serializer.toJson<DateTime>(happenedOn),
      'status': serializer.toJson<int>(
        $GamesTable.$converterstatus.toJson(status),
      ),
      'platform': serializer.toJson<String?>(platform),
      'hoursPlayed': serializer.toJson<double?>(hoursPlayed),
      'releaseYear': serializer.toJson<int?>(releaseYear),
      'externalId': serializer.toJson<String?>(externalId),
    };
  }

  GameRow copyWith({
    int? id,
    String? title,
    Value<String?> photoPath = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<double?> rating = const Value.absent(),
    Value<String?> review = const Value.absent(),
    DateTime? happenedOn,
    GameStatus? status,
    Value<String?> platform = const Value.absent(),
    Value<double?> hoursPlayed = const Value.absent(),
    Value<int?> releaseYear = const Value.absent(),
    Value<String?> externalId = const Value.absent(),
  }) => GameRow(
    id: id ?? this.id,
    title: title ?? this.title,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
    description: description.present ? description.value : this.description,
    rating: rating.present ? rating.value : this.rating,
    review: review.present ? review.value : this.review,
    happenedOn: happenedOn ?? this.happenedOn,
    status: status ?? this.status,
    platform: platform.present ? platform.value : this.platform,
    hoursPlayed: hoursPlayed.present ? hoursPlayed.value : this.hoursPlayed,
    releaseYear: releaseYear.present ? releaseYear.value : this.releaseYear,
    externalId: externalId.present ? externalId.value : this.externalId,
  );
  GameRow copyWithCompanion(GamesCompanion data) {
    return GameRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      description: data.description.present
          ? data.description.value
          : this.description,
      rating: data.rating.present ? data.rating.value : this.rating,
      review: data.review.present ? data.review.value : this.review,
      happenedOn: data.happenedOn.present
          ? data.happenedOn.value
          : this.happenedOn,
      status: data.status.present ? data.status.value : this.status,
      platform: data.platform.present ? data.platform.value : this.platform,
      hoursPlayed: data.hoursPlayed.present
          ? data.hoursPlayed.value
          : this.hoursPlayed,
      releaseYear: data.releaseYear.present
          ? data.releaseYear.value
          : this.releaseYear,
      externalId: data.externalId.present
          ? data.externalId.value
          : this.externalId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GameRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('photoPath: $photoPath, ')
          ..write('description: $description, ')
          ..write('rating: $rating, ')
          ..write('review: $review, ')
          ..write('happenedOn: $happenedOn, ')
          ..write('status: $status, ')
          ..write('platform: $platform, ')
          ..write('hoursPlayed: $hoursPlayed, ')
          ..write('releaseYear: $releaseYear, ')
          ..write('externalId: $externalId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    photoPath,
    description,
    rating,
    review,
    happenedOn,
    status,
    platform,
    hoursPlayed,
    releaseYear,
    externalId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.photoPath == this.photoPath &&
          other.description == this.description &&
          other.rating == this.rating &&
          other.review == this.review &&
          other.happenedOn == this.happenedOn &&
          other.status == this.status &&
          other.platform == this.platform &&
          other.hoursPlayed == this.hoursPlayed &&
          other.releaseYear == this.releaseYear &&
          other.externalId == this.externalId);
}

class GamesCompanion extends UpdateCompanion<GameRow> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> photoPath;
  final Value<String?> description;
  final Value<double?> rating;
  final Value<String?> review;
  final Value<DateTime> happenedOn;
  final Value<GameStatus> status;
  final Value<String?> platform;
  final Value<double?> hoursPlayed;
  final Value<int?> releaseYear;
  final Value<String?> externalId;
  const GamesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.description = const Value.absent(),
    this.rating = const Value.absent(),
    this.review = const Value.absent(),
    this.happenedOn = const Value.absent(),
    this.status = const Value.absent(),
    this.platform = const Value.absent(),
    this.hoursPlayed = const Value.absent(),
    this.releaseYear = const Value.absent(),
    this.externalId = const Value.absent(),
  });
  GamesCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.photoPath = const Value.absent(),
    this.description = const Value.absent(),
    this.rating = const Value.absent(),
    this.review = const Value.absent(),
    required DateTime happenedOn,
    required GameStatus status,
    this.platform = const Value.absent(),
    this.hoursPlayed = const Value.absent(),
    this.releaseYear = const Value.absent(),
    this.externalId = const Value.absent(),
  }) : title = Value(title),
       happenedOn = Value(happenedOn),
       status = Value(status);
  static Insertable<GameRow> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? photoPath,
    Expression<String>? description,
    Expression<double>? rating,
    Expression<String>? review,
    Expression<DateTime>? happenedOn,
    Expression<int>? status,
    Expression<String>? platform,
    Expression<double>? hoursPlayed,
    Expression<int>? releaseYear,
    Expression<String>? externalId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (photoPath != null) 'photo_path': photoPath,
      if (description != null) 'description': description,
      if (rating != null) 'rating': rating,
      if (review != null) 'review': review,
      if (happenedOn != null) 'happened_on': happenedOn,
      if (status != null) 'status': status,
      if (platform != null) 'platform': platform,
      if (hoursPlayed != null) 'hours_played': hoursPlayed,
      if (releaseYear != null) 'release_year': releaseYear,
      if (externalId != null) 'external_id': externalId,
    });
  }

  GamesCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String?>? photoPath,
    Value<String?>? description,
    Value<double?>? rating,
    Value<String?>? review,
    Value<DateTime>? happenedOn,
    Value<GameStatus>? status,
    Value<String?>? platform,
    Value<double?>? hoursPlayed,
    Value<int?>? releaseYear,
    Value<String?>? externalId,
  }) {
    return GamesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      photoPath: photoPath ?? this.photoPath,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      happenedOn: happenedOn ?? this.happenedOn,
      status: status ?? this.status,
      platform: platform ?? this.platform,
      hoursPlayed: hoursPlayed ?? this.hoursPlayed,
      releaseYear: releaseYear ?? this.releaseYear,
      externalId: externalId ?? this.externalId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (rating.present) {
      map['rating'] = Variable<double>(rating.value);
    }
    if (review.present) {
      map['review'] = Variable<String>(review.value);
    }
    if (happenedOn.present) {
      map['happened_on'] = Variable<DateTime>(happenedOn.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(
        $GamesTable.$converterstatus.toSql(status.value),
      );
    }
    if (platform.present) {
      map['platform'] = Variable<String>(platform.value);
    }
    if (hoursPlayed.present) {
      map['hours_played'] = Variable<double>(hoursPlayed.value);
    }
    if (releaseYear.present) {
      map['release_year'] = Variable<int>(releaseYear.value);
    }
    if (externalId.present) {
      map['external_id'] = Variable<String>(externalId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GamesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('photoPath: $photoPath, ')
          ..write('description: $description, ')
          ..write('rating: $rating, ')
          ..write('review: $review, ')
          ..write('happenedOn: $happenedOn, ')
          ..write('status: $status, ')
          ..write('platform: $platform, ')
          ..write('hoursPlayed: $hoursPlayed, ')
          ..write('releaseYear: $releaseYear, ')
          ..write('externalId: $externalId')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FranchisesTable franchises = $FranchisesTable(this);
  late final $RoomsTable rooms = $RoomsTable(this);
  late final $MealsTable meals = $MealsTable(this);
  late final $GigsTable gigs = $GigsTable(this);
  late final $ViewingsTable viewings = $ViewingsTable(this);
  late final $GamesTable games = $GamesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    franchises,
    rooms,
    meals,
    gigs,
    viewings,
    games,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'franchises',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('rooms', kind: UpdateKind.update)],
    ),
  ]);
}

typedef $$FranchisesTableCreateCompanionBuilder = FranchisesCompanion Function({
  Value<int> id,
  required String name,
  Value<String?> logoPath,
});
typedef $$FranchisesTableUpdateCompanionBuilder = FranchisesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String?> logoPath,
});

final class $$FranchisesTableReferences
    extends BaseReferences<_$AppDatabase, $FranchisesTable, FranchiseRow> {
  $$FranchisesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RoomsTable, List<RoomRow>> _roomsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.rooms,
    aliasName: 'franchises__id__rooms__franchise_id',
  );

  $$RoomsTableProcessedTableManager get roomsRefs {
    final manager = $$RoomsTableTableManager(
      $_db,
      $_db.rooms,
    ).filter((f) => f.franchiseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_roomsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FranchisesTableFilterComposer
    extends Composer<_$AppDatabase, $FranchisesTable> {
  $$FranchisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get logoPath => $composableBuilder(
    column: $table.logoPath,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> roomsRefs(
    Expression<bool> Function($$RoomsTableFilterComposer f) f,
  ) {
    final $$RoomsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rooms,
      getReferencedColumn: (t) => t.franchiseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoomsTableFilterComposer(
            $db: $db,
            $table: $db.rooms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FranchisesTableOrderingComposer
    extends Composer<_$AppDatabase, $FranchisesTable> {
  $$FranchisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get logoPath => $composableBuilder(
    column: $table.logoPath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FranchisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FranchisesTable> {
  $$FranchisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get logoPath =>
      $composableBuilder(column: $table.logoPath, builder: (column) => column);

  Expression<T> roomsRefs<T extends Object>(
    Expression<T> Function($$RoomsTableAnnotationComposer a) f,
  ) {
    final $$RoomsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rooms,
      getReferencedColumn: (t) => t.franchiseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoomsTableAnnotationComposer(
            $db: $db,
            $table: $db.rooms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FranchisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FranchisesTable,
          FranchiseRow,
          $$FranchisesTableFilterComposer,
          $$FranchisesTableOrderingComposer,
          $$FranchisesTableAnnotationComposer,
          $$FranchisesTableCreateCompanionBuilder,
          $$FranchisesTableUpdateCompanionBuilder,
          (FranchiseRow, $$FranchisesTableReferences),
          FranchiseRow,
          PrefetchHooks Function({bool roomsRefs})
        > {
  $$FranchisesTableTableManager(_$AppDatabase db, $FranchisesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FranchisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FranchisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FranchisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> logoPath = const Value.absent(),
          }) => FranchisesCompanion(id: id, name: name, logoPath: logoPath),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> logoPath = const Value.absent(),
              }) => FranchisesCompanion.insert(
                id: id,
                name: name,
                logoPath: logoPath,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FranchisesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({roomsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (roomsRefs) db.rooms],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (roomsRefs)
                    await $_getPrefetchedData<
                      FranchiseRow,
                      $FranchisesTable,
                      RoomRow
                    >(
                      currentTable: table,
                      referencedTable: $$FranchisesTableReferences
                          ._roomsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$FranchisesTableReferences(db, table, p0).roomsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.franchiseId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$FranchisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FranchisesTable,
      FranchiseRow,
      $$FranchisesTableFilterComposer,
      $$FranchisesTableOrderingComposer,
      $$FranchisesTableAnnotationComposer,
      $$FranchisesTableCreateCompanionBuilder,
      $$FranchisesTableUpdateCompanionBuilder,
      (FranchiseRow, $$FranchisesTableReferences),
      FranchiseRow,
      PrefetchHooks Function({bool roomsRefs})
    >;
typedef $$RoomsTableCreateCompanionBuilder = RoomsCompanion Function({
  Value<int> id,
  required String title,
  Value<String?> photoPath,
  Value<String?> description,
  Value<double?> rating,
  Value<String?> review,
  required DateTime happenedOn,
  Value<int?> franchiseId,
  required bool escaped,
  Value<int?> timeLeftMinutes,
});
typedef $$RoomsTableUpdateCompanionBuilder = RoomsCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<String?> photoPath,
  Value<String?> description,
  Value<double?> rating,
  Value<String?> review,
  Value<DateTime> happenedOn,
  Value<int?> franchiseId,
  Value<bool> escaped,
  Value<int?> timeLeftMinutes,
});

final class $$RoomsTableReferences
    extends BaseReferences<_$AppDatabase, $RoomsTable, RoomRow> {
  $$RoomsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FranchisesTable _franchiseIdTable(_$AppDatabase db) =>
      db.franchises.createAlias('rooms__franchise_id__franchises__id');

  $$FranchisesTableProcessedTableManager? get franchiseId {
    final $_column = $_itemColumn<int>('franchise_id');
    if ($_column == null) return null;
    final manager = $$FranchisesTableTableManager(
      $_db,
      $_db.franchises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_franchiseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RoomsTableFilterComposer extends Composer<_$AppDatabase, $RoomsTable> {
  $$RoomsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get review => $composableBuilder(
    column: $table.review,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get happenedOn => $composableBuilder(
    column: $table.happenedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get escaped => $composableBuilder(
    column: $table.escaped,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeLeftMinutes => $composableBuilder(
    column: $table.timeLeftMinutes,
    builder: (column) => ColumnFilters(column),
  );

  $$FranchisesTableFilterComposer get franchiseId {
    final $$FranchisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.franchiseId,
      referencedTable: $db.franchises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FranchisesTableFilterComposer(
            $db: $db,
            $table: $db.franchises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoomsTableOrderingComposer
    extends Composer<_$AppDatabase, $RoomsTable> {
  $$RoomsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get review => $composableBuilder(
    column: $table.review,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get happenedOn => $composableBuilder(
    column: $table.happenedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get escaped => $composableBuilder(
    column: $table.escaped,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeLeftMinutes => $composableBuilder(
    column: $table.timeLeftMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  $$FranchisesTableOrderingComposer get franchiseId {
    final $$FranchisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.franchiseId,
      referencedTable: $db.franchises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FranchisesTableOrderingComposer(
            $db: $db,
            $table: $db.franchises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoomsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoomsTable> {
  $$RoomsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<double> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<String> get review =>
      $composableBuilder(column: $table.review, builder: (column) => column);

  GeneratedColumn<DateTime> get happenedOn => $composableBuilder(
    column: $table.happenedOn,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get escaped =>
      $composableBuilder(column: $table.escaped, builder: (column) => column);

  GeneratedColumn<int> get timeLeftMinutes => $composableBuilder(
    column: $table.timeLeftMinutes,
    builder: (column) => column,
  );

  $$FranchisesTableAnnotationComposer get franchiseId {
    final $$FranchisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.franchiseId,
      referencedTable: $db.franchises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FranchisesTableAnnotationComposer(
            $db: $db,
            $table: $db.franchises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoomsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoomsTable,
          RoomRow,
          $$RoomsTableFilterComposer,
          $$RoomsTableOrderingComposer,
          $$RoomsTableAnnotationComposer,
          $$RoomsTableCreateCompanionBuilder,
          $$RoomsTableUpdateCompanionBuilder,
          (RoomRow, $$RoomsTableReferences),
          RoomRow,
          PrefetchHooks Function({bool franchiseId})
        > {
  $$RoomsTableTableManager(_$AppDatabase db, $RoomsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoomsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoomsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoomsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<double?> rating = const Value.absent(),
                Value<String?> review = const Value.absent(),
                Value<DateTime> happenedOn = const Value.absent(),
                Value<int?> franchiseId = const Value.absent(),
                Value<bool> escaped = const Value.absent(),
                Value<int?> timeLeftMinutes = const Value.absent(),
              }) => RoomsCompanion(
                id: id,
                title: title,
                photoPath: photoPath,
                description: description,
                rating: rating,
                review: review,
                happenedOn: happenedOn,
                franchiseId: franchiseId,
                escaped: escaped,
                timeLeftMinutes: timeLeftMinutes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String?> photoPath = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<double?> rating = const Value.absent(),
                Value<String?> review = const Value.absent(),
                required DateTime happenedOn,
                Value<int?> franchiseId = const Value.absent(),
                required bool escaped,
                Value<int?> timeLeftMinutes = const Value.absent(),
              }) => RoomsCompanion.insert(
                id: id,
                title: title,
                photoPath: photoPath,
                description: description,
                rating: rating,
                review: review,
                happenedOn: happenedOn,
                franchiseId: franchiseId,
                escaped: escaped,
                timeLeftMinutes: timeLeftMinutes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$RoomsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({franchiseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (franchiseId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.franchiseId,
                        referencedTable: $$RoomsTableReferences
                            ._franchiseIdTable(db),
                        referencedColumn: $$RoomsTableReferences
                            ._franchiseIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RoomsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoomsTable,
      RoomRow,
      $$RoomsTableFilterComposer,
      $$RoomsTableOrderingComposer,
      $$RoomsTableAnnotationComposer,
      $$RoomsTableCreateCompanionBuilder,
      $$RoomsTableUpdateCompanionBuilder,
      (RoomRow, $$RoomsTableReferences),
      RoomRow,
      PrefetchHooks Function({bool franchiseId})
    >;
typedef $$MealsTableCreateCompanionBuilder = MealsCompanion Function({
  Value<int> id,
  required String title,
  Value<String?> photoPath,
  Value<String?> description,
  Value<double?> rating,
  Value<String?> review,
  required DateTime happenedOn,
  Value<String?> dish,
  Value<double?> price,
  Value<String?> company,
  Value<String?> location,
});
typedef $$MealsTableUpdateCompanionBuilder = MealsCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<String?> photoPath,
  Value<String?> description,
  Value<double?> rating,
  Value<String?> review,
  Value<DateTime> happenedOn,
  Value<String?> dish,
  Value<double?> price,
  Value<String?> company,
  Value<String?> location,
});

class $$MealsTableFilterComposer extends Composer<_$AppDatabase, $MealsTable> {
  $$MealsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get review => $composableBuilder(
    column: $table.review,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get happenedOn => $composableBuilder(
    column: $table.happenedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dish => $composableBuilder(
    column: $table.dish,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get company => $composableBuilder(
    column: $table.company,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MealsTableOrderingComposer
    extends Composer<_$AppDatabase, $MealsTable> {
  $$MealsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get review => $composableBuilder(
    column: $table.review,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get happenedOn => $composableBuilder(
    column: $table.happenedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dish => $composableBuilder(
    column: $table.dish,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get company => $composableBuilder(
    column: $table.company,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MealsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MealsTable> {
  $$MealsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<double> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<String> get review =>
      $composableBuilder(column: $table.review, builder: (column) => column);

  GeneratedColumn<DateTime> get happenedOn => $composableBuilder(
    column: $table.happenedOn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dish =>
      $composableBuilder(column: $table.dish, builder: (column) => column);

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<String> get company =>
      $composableBuilder(column: $table.company, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);
}

class $$MealsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MealsTable,
          MealRow,
          $$MealsTableFilterComposer,
          $$MealsTableOrderingComposer,
          $$MealsTableAnnotationComposer,
          $$MealsTableCreateCompanionBuilder,
          $$MealsTableUpdateCompanionBuilder,
          (MealRow, BaseReferences<_$AppDatabase, $MealsTable, MealRow>),
          MealRow,
          PrefetchHooks Function()
        > {
  $$MealsTableTableManager(_$AppDatabase db, $MealsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MealsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MealsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MealsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<double?> rating = const Value.absent(),
                Value<String?> review = const Value.absent(),
                Value<DateTime> happenedOn = const Value.absent(),
                Value<String?> dish = const Value.absent(),
                Value<double?> price = const Value.absent(),
                Value<String?> company = const Value.absent(),
                Value<String?> location = const Value.absent(),
              }) => MealsCompanion(
                id: id,
                title: title,
                photoPath: photoPath,
                description: description,
                rating: rating,
                review: review,
                happenedOn: happenedOn,
                dish: dish,
                price: price,
                company: company,
                location: location,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String?> photoPath = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<double?> rating = const Value.absent(),
                Value<String?> review = const Value.absent(),
                required DateTime happenedOn,
                Value<String?> dish = const Value.absent(),
                Value<double?> price = const Value.absent(),
                Value<String?> company = const Value.absent(),
                Value<String?> location = const Value.absent(),
              }) => MealsCompanion.insert(
                id: id,
                title: title,
                photoPath: photoPath,
                description: description,
                rating: rating,
                review: review,
                happenedOn: happenedOn,
                dish: dish,
                price: price,
                company: company,
                location: location,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MealsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MealsTable,
      MealRow,
      $$MealsTableFilterComposer,
      $$MealsTableOrderingComposer,
      $$MealsTableAnnotationComposer,
      $$MealsTableCreateCompanionBuilder,
      $$MealsTableUpdateCompanionBuilder,
      (MealRow, BaseReferences<_$AppDatabase, $MealsTable, MealRow>),
      MealRow,
      PrefetchHooks Function()
    >;
typedef $$GigsTableCreateCompanionBuilder = GigsCompanion Function({
  Value<int> id,
  required String title,
  Value<String?> photoPath,
  Value<String?> description,
  Value<double?> rating,
  Value<String?> review,
  required DateTime happenedOn,
  Value<String?> venue,
  Value<String?> city,
  Value<String?> supportActs,
  Value<String?> setlist,
  Value<String?> company,
  Value<String?> externalId,
});
typedef $$GigsTableUpdateCompanionBuilder = GigsCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<String?> photoPath,
  Value<String?> description,
  Value<double?> rating,
  Value<String?> review,
  Value<DateTime> happenedOn,
  Value<String?> venue,
  Value<String?> city,
  Value<String?> supportActs,
  Value<String?> setlist,
  Value<String?> company,
  Value<String?> externalId,
});

class $$GigsTableFilterComposer extends Composer<_$AppDatabase, $GigsTable> {
  $$GigsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get review => $composableBuilder(
    column: $table.review,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get happenedOn => $composableBuilder(
    column: $table.happenedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get venue => $composableBuilder(
    column: $table.venue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supportActs => $composableBuilder(
    column: $table.supportActs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get setlist => $composableBuilder(
    column: $table.setlist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get company => $composableBuilder(
    column: $table.company,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GigsTableOrderingComposer extends Composer<_$AppDatabase, $GigsTable> {
  $$GigsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get review => $composableBuilder(
    column: $table.review,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get happenedOn => $composableBuilder(
    column: $table.happenedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get venue => $composableBuilder(
    column: $table.venue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supportActs => $composableBuilder(
    column: $table.supportActs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get setlist => $composableBuilder(
    column: $table.setlist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get company => $composableBuilder(
    column: $table.company,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GigsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GigsTable> {
  $$GigsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<double> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<String> get review =>
      $composableBuilder(column: $table.review, builder: (column) => column);

  GeneratedColumn<DateTime> get happenedOn => $composableBuilder(
    column: $table.happenedOn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get venue =>
      $composableBuilder(column: $table.venue, builder: (column) => column);

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<String> get supportActs => $composableBuilder(
    column: $table.supportActs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get setlist =>
      $composableBuilder(column: $table.setlist, builder: (column) => column);

  GeneratedColumn<String> get company =>
      $composableBuilder(column: $table.company, builder: (column) => column);

  GeneratedColumn<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => column,
  );
}

class $$GigsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GigsTable,
          GigRow,
          $$GigsTableFilterComposer,
          $$GigsTableOrderingComposer,
          $$GigsTableAnnotationComposer,
          $$GigsTableCreateCompanionBuilder,
          $$GigsTableUpdateCompanionBuilder,
          (GigRow, BaseReferences<_$AppDatabase, $GigsTable, GigRow>),
          GigRow,
          PrefetchHooks Function()
        > {
  $$GigsTableTableManager(_$AppDatabase db, $GigsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GigsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GigsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GigsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<double?> rating = const Value.absent(),
                Value<String?> review = const Value.absent(),
                Value<DateTime> happenedOn = const Value.absent(),
                Value<String?> venue = const Value.absent(),
                Value<String?> city = const Value.absent(),
                Value<String?> supportActs = const Value.absent(),
                Value<String?> setlist = const Value.absent(),
                Value<String?> company = const Value.absent(),
                Value<String?> externalId = const Value.absent(),
              }) => GigsCompanion(
                id: id,
                title: title,
                photoPath: photoPath,
                description: description,
                rating: rating,
                review: review,
                happenedOn: happenedOn,
                venue: venue,
                city: city,
                supportActs: supportActs,
                setlist: setlist,
                company: company,
                externalId: externalId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String?> photoPath = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<double?> rating = const Value.absent(),
                Value<String?> review = const Value.absent(),
                required DateTime happenedOn,
                Value<String?> venue = const Value.absent(),
                Value<String?> city = const Value.absent(),
                Value<String?> supportActs = const Value.absent(),
                Value<String?> setlist = const Value.absent(),
                Value<String?> company = const Value.absent(),
                Value<String?> externalId = const Value.absent(),
              }) => GigsCompanion.insert(
                id: id,
                title: title,
                photoPath: photoPath,
                description: description,
                rating: rating,
                review: review,
                happenedOn: happenedOn,
                venue: venue,
                city: city,
                supportActs: supportActs,
                setlist: setlist,
                company: company,
                externalId: externalId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GigsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GigsTable,
      GigRow,
      $$GigsTableFilterComposer,
      $$GigsTableOrderingComposer,
      $$GigsTableAnnotationComposer,
      $$GigsTableCreateCompanionBuilder,
      $$GigsTableUpdateCompanionBuilder,
      (GigRow, BaseReferences<_$AppDatabase, $GigsTable, GigRow>),
      GigRow,
      PrefetchHooks Function()
    >;
typedef $$ViewingsTableCreateCompanionBuilder = ViewingsCompanion Function({
  Value<int> id,
  required String title,
  Value<String?> photoPath,
  Value<String?> description,
  Value<double?> rating,
  Value<String?> review,
  required DateTime happenedOn,
  required ViewingKind kind,
  Value<int?> releaseYear,
  Value<String?> director,
  Value<String?> cast,
  Value<int?> season,
  Value<String?> externalId,
});
typedef $$ViewingsTableUpdateCompanionBuilder = ViewingsCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<String?> photoPath,
  Value<String?> description,
  Value<double?> rating,
  Value<String?> review,
  Value<DateTime> happenedOn,
  Value<ViewingKind> kind,
  Value<int?> releaseYear,
  Value<String?> director,
  Value<String?> cast,
  Value<int?> season,
  Value<String?> externalId,
});

class $$ViewingsTableFilterComposer
    extends Composer<_$AppDatabase, $ViewingsTable> {
  $$ViewingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get review => $composableBuilder(
    column: $table.review,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get happenedOn => $composableBuilder(
    column: $table.happenedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ViewingKind, ViewingKind, int> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get releaseYear => $composableBuilder(
    column: $table.releaseYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get director => $composableBuilder(
    column: $table.director,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cast => $composableBuilder(
    column: $table.cast,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get season => $composableBuilder(
    column: $table.season,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ViewingsTableOrderingComposer
    extends Composer<_$AppDatabase, $ViewingsTable> {
  $$ViewingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get review => $composableBuilder(
    column: $table.review,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get happenedOn => $composableBuilder(
    column: $table.happenedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get releaseYear => $composableBuilder(
    column: $table.releaseYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get director => $composableBuilder(
    column: $table.director,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cast => $composableBuilder(
    column: $table.cast,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get season => $composableBuilder(
    column: $table.season,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ViewingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ViewingsTable> {
  $$ViewingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<double> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<String> get review =>
      $composableBuilder(column: $table.review, builder: (column) => column);

  GeneratedColumn<DateTime> get happenedOn => $composableBuilder(
    column: $table.happenedOn,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ViewingKind, int> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get releaseYear => $composableBuilder(
    column: $table.releaseYear,
    builder: (column) => column,
  );

  GeneratedColumn<String> get director =>
      $composableBuilder(column: $table.director, builder: (column) => column);

  GeneratedColumn<String> get cast =>
      $composableBuilder(column: $table.cast, builder: (column) => column);

  GeneratedColumn<int> get season =>
      $composableBuilder(column: $table.season, builder: (column) => column);

  GeneratedColumn<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => column,
  );
}

class $$ViewingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ViewingsTable,
          ViewingRow,
          $$ViewingsTableFilterComposer,
          $$ViewingsTableOrderingComposer,
          $$ViewingsTableAnnotationComposer,
          $$ViewingsTableCreateCompanionBuilder,
          $$ViewingsTableUpdateCompanionBuilder,
          (
            ViewingRow,
            BaseReferences<_$AppDatabase, $ViewingsTable, ViewingRow>,
          ),
          ViewingRow,
          PrefetchHooks Function()
        > {
  $$ViewingsTableTableManager(_$AppDatabase db, $ViewingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ViewingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ViewingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ViewingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<double?> rating = const Value.absent(),
                Value<String?> review = const Value.absent(),
                Value<DateTime> happenedOn = const Value.absent(),
                Value<ViewingKind> kind = const Value.absent(),
                Value<int?> releaseYear = const Value.absent(),
                Value<String?> director = const Value.absent(),
                Value<String?> cast = const Value.absent(),
                Value<int?> season = const Value.absent(),
                Value<String?> externalId = const Value.absent(),
              }) => ViewingsCompanion(
                id: id,
                title: title,
                photoPath: photoPath,
                description: description,
                rating: rating,
                review: review,
                happenedOn: happenedOn,
                kind: kind,
                releaseYear: releaseYear,
                director: director,
                cast: cast,
                season: season,
                externalId: externalId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String?> photoPath = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<double?> rating = const Value.absent(),
                Value<String?> review = const Value.absent(),
                required DateTime happenedOn,
                required ViewingKind kind,
                Value<int?> releaseYear = const Value.absent(),
                Value<String?> director = const Value.absent(),
                Value<String?> cast = const Value.absent(),
                Value<int?> season = const Value.absent(),
                Value<String?> externalId = const Value.absent(),
              }) => ViewingsCompanion.insert(
                id: id,
                title: title,
                photoPath: photoPath,
                description: description,
                rating: rating,
                review: review,
                happenedOn: happenedOn,
                kind: kind,
                releaseYear: releaseYear,
                director: director,
                cast: cast,
                season: season,
                externalId: externalId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ViewingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ViewingsTable,
      ViewingRow,
      $$ViewingsTableFilterComposer,
      $$ViewingsTableOrderingComposer,
      $$ViewingsTableAnnotationComposer,
      $$ViewingsTableCreateCompanionBuilder,
      $$ViewingsTableUpdateCompanionBuilder,
      (ViewingRow, BaseReferences<_$AppDatabase, $ViewingsTable, ViewingRow>),
      ViewingRow,
      PrefetchHooks Function()
    >;
typedef $$GamesTableCreateCompanionBuilder = GamesCompanion Function({
  Value<int> id,
  required String title,
  Value<String?> photoPath,
  Value<String?> description,
  Value<double?> rating,
  Value<String?> review,
  required DateTime happenedOn,
  required GameStatus status,
  Value<String?> platform,
  Value<double?> hoursPlayed,
  Value<int?> releaseYear,
  Value<String?> externalId,
});
typedef $$GamesTableUpdateCompanionBuilder = GamesCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<String?> photoPath,
  Value<String?> description,
  Value<double?> rating,
  Value<String?> review,
  Value<DateTime> happenedOn,
  Value<GameStatus> status,
  Value<String?> platform,
  Value<double?> hoursPlayed,
  Value<int?> releaseYear,
  Value<String?> externalId,
});

class $$GamesTableFilterComposer extends Composer<_$AppDatabase, $GamesTable> {
  $$GamesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get review => $composableBuilder(
    column: $table.review,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get happenedOn => $composableBuilder(
    column: $table.happenedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<GameStatus, GameStatus, int> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hoursPlayed => $composableBuilder(
    column: $table.hoursPlayed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get releaseYear => $composableBuilder(
    column: $table.releaseYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GamesTableOrderingComposer
    extends Composer<_$AppDatabase, $GamesTable> {
  $$GamesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get review => $composableBuilder(
    column: $table.review,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get happenedOn => $composableBuilder(
    column: $table.happenedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hoursPlayed => $composableBuilder(
    column: $table.hoursPlayed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get releaseYear => $composableBuilder(
    column: $table.releaseYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GamesTableAnnotationComposer
    extends Composer<_$AppDatabase, $GamesTable> {
  $$GamesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<double> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<String> get review =>
      $composableBuilder(column: $table.review, builder: (column) => column);

  GeneratedColumn<DateTime> get happenedOn => $composableBuilder(
    column: $table.happenedOn,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<GameStatus, int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get platform =>
      $composableBuilder(column: $table.platform, builder: (column) => column);

  GeneratedColumn<double> get hoursPlayed => $composableBuilder(
    column: $table.hoursPlayed,
    builder: (column) => column,
  );

  GeneratedColumn<int> get releaseYear => $composableBuilder(
    column: $table.releaseYear,
    builder: (column) => column,
  );

  GeneratedColumn<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => column,
  );
}

class $$GamesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GamesTable,
          GameRow,
          $$GamesTableFilterComposer,
          $$GamesTableOrderingComposer,
          $$GamesTableAnnotationComposer,
          $$GamesTableCreateCompanionBuilder,
          $$GamesTableUpdateCompanionBuilder,
          (GameRow, BaseReferences<_$AppDatabase, $GamesTable, GameRow>),
          GameRow,
          PrefetchHooks Function()
        > {
  $$GamesTableTableManager(_$AppDatabase db, $GamesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GamesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GamesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GamesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<double?> rating = const Value.absent(),
                Value<String?> review = const Value.absent(),
                Value<DateTime> happenedOn = const Value.absent(),
                Value<GameStatus> status = const Value.absent(),
                Value<String?> platform = const Value.absent(),
                Value<double?> hoursPlayed = const Value.absent(),
                Value<int?> releaseYear = const Value.absent(),
                Value<String?> externalId = const Value.absent(),
              }) => GamesCompanion(
                id: id,
                title: title,
                photoPath: photoPath,
                description: description,
                rating: rating,
                review: review,
                happenedOn: happenedOn,
                status: status,
                platform: platform,
                hoursPlayed: hoursPlayed,
                releaseYear: releaseYear,
                externalId: externalId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String?> photoPath = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<double?> rating = const Value.absent(),
                Value<String?> review = const Value.absent(),
                required DateTime happenedOn,
                required GameStatus status,
                Value<String?> platform = const Value.absent(),
                Value<double?> hoursPlayed = const Value.absent(),
                Value<int?> releaseYear = const Value.absent(),
                Value<String?> externalId = const Value.absent(),
              }) => GamesCompanion.insert(
                id: id,
                title: title,
                photoPath: photoPath,
                description: description,
                rating: rating,
                review: review,
                happenedOn: happenedOn,
                status: status,
                platform: platform,
                hoursPlayed: hoursPlayed,
                releaseYear: releaseYear,
                externalId: externalId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GamesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GamesTable,
      GameRow,
      $$GamesTableFilterComposer,
      $$GamesTableOrderingComposer,
      $$GamesTableAnnotationComposer,
      $$GamesTableCreateCompanionBuilder,
      $$GamesTableUpdateCompanionBuilder,
      (GameRow, BaseReferences<_$AppDatabase, $GamesTable, GameRow>),
      GameRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FranchisesTableTableManager get franchises =>
      $$FranchisesTableTableManager(_db, _db.franchises);
  $$RoomsTableTableManager get rooms =>
      $$RoomsTableTableManager(_db, _db.rooms);
  $$MealsTableTableManager get meals =>
      $$MealsTableTableManager(_db, _db.meals);
  $$GigsTableTableManager get gigs => $$GigsTableTableManager(_db, _db.gigs);
  $$ViewingsTableTableManager get viewings =>
      $$ViewingsTableTableManager(_db, _db.viewings);
  $$GamesTableTableManager get games =>
      $$GamesTableTableManager(_db, _db.games);
}
