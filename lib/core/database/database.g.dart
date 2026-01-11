// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $UsersDaoTable extends UsersDao
    with TableInfo<$UsersDaoTable, UsersDaoData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersDaoTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ageMeta = const VerificationMeta('age');
  @override
  late final GeneratedColumn<int> age = GeneratedColumn<int>(
      'age', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _hasMeasuringMeta =
      const VerificationMeta('hasMeasuring');
  @override
  late final GeneratedColumn<bool> hasMeasuring = GeneratedColumn<bool>(
      'has_measuring', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("has_measuring" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _measuringNameMeta =
      const VerificationMeta('measuringName');
  @override
  late final GeneratedColumn<String> measuringName = GeneratedColumn<String>(
      'measuring_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _enableNotificationsMeta =
      const VerificationMeta('enableNotifications');
  @override
  late final GeneratedColumn<bool> enableNotifications = GeneratedColumn<bool>(
      'enable_notifications', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("enable_notifications" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        age,
        hasMeasuring,
        measuringName,
        enableNotifications,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(Insertable<UsersDaoData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('age')) {
      context.handle(
          _ageMeta, age.isAcceptableOrUnknown(data['age']!, _ageMeta));
    }
    if (data.containsKey('has_measuring')) {
      context.handle(
          _hasMeasuringMeta,
          hasMeasuring.isAcceptableOrUnknown(
              data['has_measuring']!, _hasMeasuringMeta));
    }
    if (data.containsKey('measuring_name')) {
      context.handle(
          _measuringNameMeta,
          measuringName.isAcceptableOrUnknown(
              data['measuring_name']!, _measuringNameMeta));
    }
    if (data.containsKey('enable_notifications')) {
      context.handle(
          _enableNotificationsMeta,
          enableNotifications.isAcceptableOrUnknown(
              data['enable_notifications']!, _enableNotificationsMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UsersDaoData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UsersDaoData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      age: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}age']),
      hasMeasuring: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}has_measuring'])!,
      measuringName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}measuring_name']),
      enableNotifications: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}enable_notifications'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $UsersDaoTable createAlias(String alias) {
    return $UsersDaoTable(attachedDatabase, alias);
  }
}

class UsersDaoData extends DataClass implements Insertable<UsersDaoData> {
  final String id;
  final String name;
  final int? age;
  final bool hasMeasuring;
  final String? measuringName;
  final bool enableNotifications;
  final DateTime createdAt;
  final DateTime updatedAt;
  const UsersDaoData(
      {required this.id,
      required this.name,
      this.age,
      required this.hasMeasuring,
      this.measuringName,
      required this.enableNotifications,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || age != null) {
      map['age'] = Variable<int>(age);
    }
    map['has_measuring'] = Variable<bool>(hasMeasuring);
    if (!nullToAbsent || measuringName != null) {
      map['measuring_name'] = Variable<String>(measuringName);
    }
    map['enable_notifications'] = Variable<bool>(enableNotifications);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UsersDaoCompanion toCompanion(bool nullToAbsent) {
    return UsersDaoCompanion(
      id: Value(id),
      name: Value(name),
      age: age == null && nullToAbsent ? const Value.absent() : Value(age),
      hasMeasuring: Value(hasMeasuring),
      measuringName: measuringName == null && nullToAbsent
          ? const Value.absent()
          : Value(measuringName),
      enableNotifications: Value(enableNotifications),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory UsersDaoData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UsersDaoData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      age: serializer.fromJson<int?>(json['age']),
      hasMeasuring: serializer.fromJson<bool>(json['hasMeasuring']),
      measuringName: serializer.fromJson<String?>(json['measuringName']),
      enableNotifications:
          serializer.fromJson<bool>(json['enableNotifications']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'age': serializer.toJson<int?>(age),
      'hasMeasuring': serializer.toJson<bool>(hasMeasuring),
      'measuringName': serializer.toJson<String?>(measuringName),
      'enableNotifications': serializer.toJson<bool>(enableNotifications),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UsersDaoData copyWith(
          {String? id,
          String? name,
          Value<int?> age = const Value.absent(),
          bool? hasMeasuring,
          Value<String?> measuringName = const Value.absent(),
          bool? enableNotifications,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      UsersDaoData(
        id: id ?? this.id,
        name: name ?? this.name,
        age: age.present ? age.value : this.age,
        hasMeasuring: hasMeasuring ?? this.hasMeasuring,
        measuringName:
            measuringName.present ? measuringName.value : this.measuringName,
        enableNotifications: enableNotifications ?? this.enableNotifications,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  UsersDaoData copyWithCompanion(UsersDaoCompanion data) {
    return UsersDaoData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      age: data.age.present ? data.age.value : this.age,
      hasMeasuring: data.hasMeasuring.present
          ? data.hasMeasuring.value
          : this.hasMeasuring,
      measuringName: data.measuringName.present
          ? data.measuringName.value
          : this.measuringName,
      enableNotifications: data.enableNotifications.present
          ? data.enableNotifications.value
          : this.enableNotifications,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UsersDaoData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('age: $age, ')
          ..write('hasMeasuring: $hasMeasuring, ')
          ..write('measuringName: $measuringName, ')
          ..write('enableNotifications: $enableNotifications, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, age, hasMeasuring, measuringName,
      enableNotifications, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UsersDaoData &&
          other.id == this.id &&
          other.name == this.name &&
          other.age == this.age &&
          other.hasMeasuring == this.hasMeasuring &&
          other.measuringName == this.measuringName &&
          other.enableNotifications == this.enableNotifications &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UsersDaoCompanion extends UpdateCompanion<UsersDaoData> {
  final Value<String> id;
  final Value<String> name;
  final Value<int?> age;
  final Value<bool> hasMeasuring;
  final Value<String?> measuringName;
  final Value<bool> enableNotifications;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const UsersDaoCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.age = const Value.absent(),
    this.hasMeasuring = const Value.absent(),
    this.measuringName = const Value.absent(),
    this.enableNotifications = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersDaoCompanion.insert({
    required String id,
    required String name,
    this.age = const Value.absent(),
    this.hasMeasuring = const Value.absent(),
    this.measuringName = const Value.absent(),
    this.enableNotifications = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<UsersDaoData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? age,
    Expression<bool>? hasMeasuring,
    Expression<String>? measuringName,
    Expression<bool>? enableNotifications,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (age != null) 'age': age,
      if (hasMeasuring != null) 'has_measuring': hasMeasuring,
      if (measuringName != null) 'measuring_name': measuringName,
      if (enableNotifications != null)
        'enable_notifications': enableNotifications,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersDaoCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<int?>? age,
      Value<bool>? hasMeasuring,
      Value<String?>? measuringName,
      Value<bool>? enableNotifications,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return UsersDaoCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      hasMeasuring: hasMeasuring ?? this.hasMeasuring,
      measuringName: measuringName ?? this.measuringName,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (age.present) {
      map['age'] = Variable<int>(age.value);
    }
    if (hasMeasuring.present) {
      map['has_measuring'] = Variable<bool>(hasMeasuring.value);
    }
    if (measuringName.present) {
      map['measuring_name'] = Variable<String>(measuringName.value);
    }
    if (enableNotifications.present) {
      map['enable_notifications'] = Variable<bool>(enableNotifications.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersDaoCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('age: $age, ')
          ..write('hasMeasuring: $hasMeasuring, ')
          ..write('measuringName: $measuringName, ')
          ..write('enableNotifications: $enableNotifications, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MeasurementsDaoTable extends MeasurementsDao
    with TableInfo<$MeasurementsDaoTable, MeasurementsDaoData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MeasurementsDaoTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES users (id) ON DELETE CASCADE'));
  static const VerificationMeta _measurementTimeMeta =
      const VerificationMeta('measurementTime');
  @override
  late final GeneratedColumn<DateTime> measurementTime =
      GeneratedColumn<DateTime>('measurement_time', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _measurementNumberMeta =
      const VerificationMeta('measurementNumber');
  @override
  late final GeneratedColumn<int> measurementNumber = GeneratedColumn<int>(
      'measurement_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _systolicMeta =
      const VerificationMeta('systolic');
  @override
  late final GeneratedColumn<int> systolic = GeneratedColumn<int>(
      'systolic', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _diastolicMeta =
      const VerificationMeta('diastolic');
  @override
  late final GeneratedColumn<int> diastolic = GeneratedColumn<int>(
      'diastolic', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _pulseMeta = const VerificationMeta('pulse');
  @override
  late final GeneratedColumn<int> pulse = GeneratedColumn<int>(
      'pulse', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        measurementTime,
        measurementNumber,
        systolic,
        diastolic,
        pulse,
        note,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'measurements';
  @override
  VerificationContext validateIntegrity(
      Insertable<MeasurementsDaoData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('measurement_time')) {
      context.handle(
          _measurementTimeMeta,
          measurementTime.isAcceptableOrUnknown(
              data['measurement_time']!, _measurementTimeMeta));
    } else if (isInserting) {
      context.missing(_measurementTimeMeta);
    }
    if (data.containsKey('measurement_number')) {
      context.handle(
          _measurementNumberMeta,
          measurementNumber.isAcceptableOrUnknown(
              data['measurement_number']!, _measurementNumberMeta));
    } else if (isInserting) {
      context.missing(_measurementNumberMeta);
    }
    if (data.containsKey('systolic')) {
      context.handle(_systolicMeta,
          systolic.isAcceptableOrUnknown(data['systolic']!, _systolicMeta));
    } else if (isInserting) {
      context.missing(_systolicMeta);
    }
    if (data.containsKey('diastolic')) {
      context.handle(_diastolicMeta,
          diastolic.isAcceptableOrUnknown(data['diastolic']!, _diastolicMeta));
    } else if (isInserting) {
      context.missing(_diastolicMeta);
    }
    if (data.containsKey('pulse')) {
      context.handle(
          _pulseMeta, pulse.isAcceptableOrUnknown(data['pulse']!, _pulseMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MeasurementsDaoData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MeasurementsDaoData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      measurementTime: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}measurement_time'])!,
      measurementNumber: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}measurement_number'])!,
      systolic: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}systolic'])!,
      diastolic: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}diastolic'])!,
      pulse: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}pulse']),
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $MeasurementsDaoTable createAlias(String alias) {
    return $MeasurementsDaoTable(attachedDatabase, alias);
  }
}

class MeasurementsDaoData extends DataClass
    implements Insertable<MeasurementsDaoData> {
  final String id;
  final String userId;
  final DateTime measurementTime;
  final int measurementNumber;
  final int systolic;
  final int diastolic;
  final int? pulse;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  const MeasurementsDaoData(
      {required this.id,
      required this.userId,
      required this.measurementTime,
      required this.measurementNumber,
      required this.systolic,
      required this.diastolic,
      this.pulse,
      this.note,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['measurement_time'] = Variable<DateTime>(measurementTime);
    map['measurement_number'] = Variable<int>(measurementNumber);
    map['systolic'] = Variable<int>(systolic);
    map['diastolic'] = Variable<int>(diastolic);
    if (!nullToAbsent || pulse != null) {
      map['pulse'] = Variable<int>(pulse);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MeasurementsDaoCompanion toCompanion(bool nullToAbsent) {
    return MeasurementsDaoCompanion(
      id: Value(id),
      userId: Value(userId),
      measurementTime: Value(measurementTime),
      measurementNumber: Value(measurementNumber),
      systolic: Value(systolic),
      diastolic: Value(diastolic),
      pulse:
          pulse == null && nullToAbsent ? const Value.absent() : Value(pulse),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory MeasurementsDaoData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MeasurementsDaoData(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      measurementTime: serializer.fromJson<DateTime>(json['measurementTime']),
      measurementNumber: serializer.fromJson<int>(json['measurementNumber']),
      systolic: serializer.fromJson<int>(json['systolic']),
      diastolic: serializer.fromJson<int>(json['diastolic']),
      pulse: serializer.fromJson<int?>(json['pulse']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'measurementTime': serializer.toJson<DateTime>(measurementTime),
      'measurementNumber': serializer.toJson<int>(measurementNumber),
      'systolic': serializer.toJson<int>(systolic),
      'diastolic': serializer.toJson<int>(diastolic),
      'pulse': serializer.toJson<int?>(pulse),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MeasurementsDaoData copyWith(
          {String? id,
          String? userId,
          DateTime? measurementTime,
          int? measurementNumber,
          int? systolic,
          int? diastolic,
          Value<int?> pulse = const Value.absent(),
          Value<String?> note = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      MeasurementsDaoData(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        measurementTime: measurementTime ?? this.measurementTime,
        measurementNumber: measurementNumber ?? this.measurementNumber,
        systolic: systolic ?? this.systolic,
        diastolic: diastolic ?? this.diastolic,
        pulse: pulse.present ? pulse.value : this.pulse,
        note: note.present ? note.value : this.note,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  MeasurementsDaoData copyWithCompanion(MeasurementsDaoCompanion data) {
    return MeasurementsDaoData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      measurementTime: data.measurementTime.present
          ? data.measurementTime.value
          : this.measurementTime,
      measurementNumber: data.measurementNumber.present
          ? data.measurementNumber.value
          : this.measurementNumber,
      systolic: data.systolic.present ? data.systolic.value : this.systolic,
      diastolic: data.diastolic.present ? data.diastolic.value : this.diastolic,
      pulse: data.pulse.present ? data.pulse.value : this.pulse,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MeasurementsDaoData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('measurementTime: $measurementTime, ')
          ..write('measurementNumber: $measurementNumber, ')
          ..write('systolic: $systolic, ')
          ..write('diastolic: $diastolic, ')
          ..write('pulse: $pulse, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      userId,
      measurementTime,
      measurementNumber,
      systolic,
      diastolic,
      pulse,
      note,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MeasurementsDaoData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.measurementTime == this.measurementTime &&
          other.measurementNumber == this.measurementNumber &&
          other.systolic == this.systolic &&
          other.diastolic == this.diastolic &&
          other.pulse == this.pulse &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MeasurementsDaoCompanion extends UpdateCompanion<MeasurementsDaoData> {
  final Value<String> id;
  final Value<String> userId;
  final Value<DateTime> measurementTime;
  final Value<int> measurementNumber;
  final Value<int> systolic;
  final Value<int> diastolic;
  final Value<int?> pulse;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const MeasurementsDaoCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.measurementTime = const Value.absent(),
    this.measurementNumber = const Value.absent(),
    this.systolic = const Value.absent(),
    this.diastolic = const Value.absent(),
    this.pulse = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MeasurementsDaoCompanion.insert({
    required String id,
    required String userId,
    required DateTime measurementTime,
    required int measurementNumber,
    required int systolic,
    required int diastolic,
    this.pulse = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        measurementTime = Value(measurementTime),
        measurementNumber = Value(measurementNumber),
        systolic = Value(systolic),
        diastolic = Value(diastolic),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<MeasurementsDaoData> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<DateTime>? measurementTime,
    Expression<int>? measurementNumber,
    Expression<int>? systolic,
    Expression<int>? diastolic,
    Expression<int>? pulse,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (measurementTime != null) 'measurement_time': measurementTime,
      if (measurementNumber != null) 'measurement_number': measurementNumber,
      if (systolic != null) 'systolic': systolic,
      if (diastolic != null) 'diastolic': diastolic,
      if (pulse != null) 'pulse': pulse,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MeasurementsDaoCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<DateTime>? measurementTime,
      Value<int>? measurementNumber,
      Value<int>? systolic,
      Value<int>? diastolic,
      Value<int?>? pulse,
      Value<String?>? note,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return MeasurementsDaoCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      measurementTime: measurementTime ?? this.measurementTime,
      measurementNumber: measurementNumber ?? this.measurementNumber,
      systolic: systolic ?? this.systolic,
      diastolic: diastolic ?? this.diastolic,
      pulse: pulse ?? this.pulse,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (measurementTime.present) {
      map['measurement_time'] = Variable<DateTime>(measurementTime.value);
    }
    if (measurementNumber.present) {
      map['measurement_number'] = Variable<int>(measurementNumber.value);
    }
    if (systolic.present) {
      map['systolic'] = Variable<int>(systolic.value);
    }
    if (diastolic.present) {
      map['diastolic'] = Variable<int>(diastolic.value);
    }
    if (pulse.present) {
      map['pulse'] = Variable<int>(pulse.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MeasurementsDaoCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('measurementTime: $measurementTime, ')
          ..write('measurementNumber: $measurementNumber, ')
          ..write('systolic: $systolic, ')
          ..write('diastolic: $diastolic, ')
          ..write('pulse: $pulse, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SchedulesDaoTable extends SchedulesDao
    with TableInfo<$SchedulesDaoTable, SchedulesDaoData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SchedulesDaoTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES users (id) ON DELETE CASCADE'));
  static const VerificationMeta _hourMeta = const VerificationMeta('hour');
  @override
  late final GeneratedColumn<int> hour = GeneratedColumn<int>(
      'hour', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _minuteMeta = const VerificationMeta('minute');
  @override
  late final GeneratedColumn<int> minute = GeneratedColumn<int>(
      'minute', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isEnabledMeta =
      const VerificationMeta('isEnabled');
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
      'is_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, userId, hour, minute, isEnabled, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schedules';
  @override
  VerificationContext validateIntegrity(Insertable<SchedulesDaoData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('hour')) {
      context.handle(
          _hourMeta, hour.isAcceptableOrUnknown(data['hour']!, _hourMeta));
    } else if (isInserting) {
      context.missing(_hourMeta);
    }
    if (data.containsKey('minute')) {
      context.handle(_minuteMeta,
          minute.isAcceptableOrUnknown(data['minute']!, _minuteMeta));
    } else if (isInserting) {
      context.missing(_minuteMeta);
    }
    if (data.containsKey('is_enabled')) {
      context.handle(_isEnabledMeta,
          isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SchedulesDaoData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SchedulesDaoData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      hour: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}hour'])!,
      minute: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}minute'])!,
      isEnabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_enabled'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $SchedulesDaoTable createAlias(String alias) {
    return $SchedulesDaoTable(attachedDatabase, alias);
  }
}

class SchedulesDaoData extends DataClass
    implements Insertable<SchedulesDaoData> {
  final String id;
  final String userId;
  final int hour;
  final int minute;
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;
  const SchedulesDaoData(
      {required this.id,
      required this.userId,
      required this.hour,
      required this.minute,
      required this.isEnabled,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['hour'] = Variable<int>(hour);
    map['minute'] = Variable<int>(minute);
    map['is_enabled'] = Variable<bool>(isEnabled);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SchedulesDaoCompanion toCompanion(bool nullToAbsent) {
    return SchedulesDaoCompanion(
      id: Value(id),
      userId: Value(userId),
      hour: Value(hour),
      minute: Value(minute),
      isEnabled: Value(isEnabled),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SchedulesDaoData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SchedulesDaoData(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      hour: serializer.fromJson<int>(json['hour']),
      minute: serializer.fromJson<int>(json['minute']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'hour': serializer.toJson<int>(hour),
      'minute': serializer.toJson<int>(minute),
      'isEnabled': serializer.toJson<bool>(isEnabled),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SchedulesDaoData copyWith(
          {String? id,
          String? userId,
          int? hour,
          int? minute,
          bool? isEnabled,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      SchedulesDaoData(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        hour: hour ?? this.hour,
        minute: minute ?? this.minute,
        isEnabled: isEnabled ?? this.isEnabled,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  SchedulesDaoData copyWithCompanion(SchedulesDaoCompanion data) {
    return SchedulesDaoData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      hour: data.hour.present ? data.hour.value : this.hour,
      minute: data.minute.present ? data.minute.value : this.minute,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SchedulesDaoData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('hour: $hour, ')
          ..write('minute: $minute, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, hour, minute, isEnabled, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SchedulesDaoData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.hour == this.hour &&
          other.minute == this.minute &&
          other.isEnabled == this.isEnabled &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SchedulesDaoCompanion extends UpdateCompanion<SchedulesDaoData> {
  final Value<String> id;
  final Value<String> userId;
  final Value<int> hour;
  final Value<int> minute;
  final Value<bool> isEnabled;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SchedulesDaoCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.hour = const Value.absent(),
    this.minute = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SchedulesDaoCompanion.insert({
    required String id,
    required String userId,
    required int hour,
    required int minute,
    this.isEnabled = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        hour = Value(hour),
        minute = Value(minute),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<SchedulesDaoData> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<int>? hour,
    Expression<int>? minute,
    Expression<bool>? isEnabled,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (hour != null) 'hour': hour,
      if (minute != null) 'minute': minute,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SchedulesDaoCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<int>? hour,
      Value<int>? minute,
      Value<bool>? isEnabled,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return SchedulesDaoCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (hour.present) {
      map['hour'] = Variable<int>(hour.value);
    }
    if (minute.present) {
      map['minute'] = Variable<int>(minute.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SchedulesDaoCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('hour: $hour, ')
          ..write('minute: $minute, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersDaoTable usersDao = $UsersDaoTable(this);
  late final $MeasurementsDaoTable measurementsDao =
      $MeasurementsDaoTable(this);
  late final $SchedulesDaoTable schedulesDao = $SchedulesDaoTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [usersDao, measurementsDao, schedulesDao];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('users',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('measurements', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('users',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('schedules', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$UsersDaoTableCreateCompanionBuilder = UsersDaoCompanion Function({
  required String id,
  required String name,
  Value<int?> age,
  Value<bool> hasMeasuring,
  Value<String?> measuringName,
  Value<bool> enableNotifications,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$UsersDaoTableUpdateCompanionBuilder = UsersDaoCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int?> age,
  Value<bool> hasMeasuring,
  Value<String?> measuringName,
  Value<bool> enableNotifications,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$UsersDaoTableReferences
    extends BaseReferences<_$AppDatabase, $UsersDaoTable, UsersDaoData> {
  $$UsersDaoTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MeasurementsDaoTable, List<MeasurementsDaoData>>
      _measurementsDaoRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.measurementsDao,
              aliasName: $_aliasNameGenerator(
                  db.usersDao.id, db.measurementsDao.userId));

  $$MeasurementsDaoTableProcessedTableManager get measurementsDaoRefs {
    final manager =
        $$MeasurementsDaoTableTableManager($_db, $_db.measurementsDao)
            .filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_measurementsDaoRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$SchedulesDaoTable, List<SchedulesDaoData>>
      _schedulesDaoRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.schedulesDao,
              aliasName:
                  $_aliasNameGenerator(db.usersDao.id, db.schedulesDao.userId));

  $$SchedulesDaoTableProcessedTableManager get schedulesDaoRefs {
    final manager = $$SchedulesDaoTableTableManager($_db, $_db.schedulesDao)
        .filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_schedulesDaoRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$UsersDaoTableFilterComposer
    extends Composer<_$AppDatabase, $UsersDaoTable> {
  $$UsersDaoTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get age => $composableBuilder(
      column: $table.age, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get hasMeasuring => $composableBuilder(
      column: $table.hasMeasuring, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get measuringName => $composableBuilder(
      column: $table.measuringName, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get enableNotifications => $composableBuilder(
      column: $table.enableNotifications,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> measurementsDaoRefs(
      Expression<bool> Function($$MeasurementsDaoTableFilterComposer f) f) {
    final $$MeasurementsDaoTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.measurementsDao,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MeasurementsDaoTableFilterComposer(
              $db: $db,
              $table: $db.measurementsDao,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> schedulesDaoRefs(
      Expression<bool> Function($$SchedulesDaoTableFilterComposer f) f) {
    final $$SchedulesDaoTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.schedulesDao,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SchedulesDaoTableFilterComposer(
              $db: $db,
              $table: $db.schedulesDao,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$UsersDaoTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersDaoTable> {
  $$UsersDaoTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get age => $composableBuilder(
      column: $table.age, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get hasMeasuring => $composableBuilder(
      column: $table.hasMeasuring,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get measuringName => $composableBuilder(
      column: $table.measuringName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get enableNotifications => $composableBuilder(
      column: $table.enableNotifications,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$UsersDaoTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersDaoTable> {
  $$UsersDaoTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get age =>
      $composableBuilder(column: $table.age, builder: (column) => column);

  GeneratedColumn<bool> get hasMeasuring => $composableBuilder(
      column: $table.hasMeasuring, builder: (column) => column);

  GeneratedColumn<String> get measuringName => $composableBuilder(
      column: $table.measuringName, builder: (column) => column);

  GeneratedColumn<bool> get enableNotifications => $composableBuilder(
      column: $table.enableNotifications, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> measurementsDaoRefs<T extends Object>(
      Expression<T> Function($$MeasurementsDaoTableAnnotationComposer a) f) {
    final $$MeasurementsDaoTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.measurementsDao,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MeasurementsDaoTableAnnotationComposer(
              $db: $db,
              $table: $db.measurementsDao,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> schedulesDaoRefs<T extends Object>(
      Expression<T> Function($$SchedulesDaoTableAnnotationComposer a) f) {
    final $$SchedulesDaoTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.schedulesDao,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SchedulesDaoTableAnnotationComposer(
              $db: $db,
              $table: $db.schedulesDao,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$UsersDaoTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UsersDaoTable,
    UsersDaoData,
    $$UsersDaoTableFilterComposer,
    $$UsersDaoTableOrderingComposer,
    $$UsersDaoTableAnnotationComposer,
    $$UsersDaoTableCreateCompanionBuilder,
    $$UsersDaoTableUpdateCompanionBuilder,
    (UsersDaoData, $$UsersDaoTableReferences),
    UsersDaoData,
    PrefetchHooks Function({bool measurementsDaoRefs, bool schedulesDaoRefs})> {
  $$UsersDaoTableTableManager(_$AppDatabase db, $UsersDaoTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersDaoTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersDaoTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersDaoTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int?> age = const Value.absent(),
            Value<bool> hasMeasuring = const Value.absent(),
            Value<String?> measuringName = const Value.absent(),
            Value<bool> enableNotifications = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersDaoCompanion(
            id: id,
            name: name,
            age: age,
            hasMeasuring: hasMeasuring,
            measuringName: measuringName,
            enableNotifications: enableNotifications,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<int?> age = const Value.absent(),
            Value<bool> hasMeasuring = const Value.absent(),
            Value<String?> measuringName = const Value.absent(),
            Value<bool> enableNotifications = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersDaoCompanion.insert(
            id: id,
            name: name,
            age: age,
            hasMeasuring: hasMeasuring,
            measuringName: measuringName,
            enableNotifications: enableNotifications,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$UsersDaoTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {measurementsDaoRefs = false, schedulesDaoRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (measurementsDaoRefs) db.measurementsDao,
                if (schedulesDaoRefs) db.schedulesDao
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (measurementsDaoRefs)
                    await $_getPrefetchedData<UsersDaoData, $UsersDaoTable, MeasurementsDaoData>(
                        currentTable: table,
                        referencedTable: $$UsersDaoTableReferences
                            ._measurementsDaoRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UsersDaoTableReferences(db, table, p0)
                                .measurementsDaoRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.userId == item.id),
                        typedResults: items),
                  if (schedulesDaoRefs)
                    await $_getPrefetchedData<UsersDaoData, $UsersDaoTable, SchedulesDaoData>(
                        currentTable: table,
                        referencedTable: $$UsersDaoTableReferences
                            ._schedulesDaoRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UsersDaoTableReferences(db, table, p0)
                                .schedulesDaoRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.userId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$UsersDaoTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UsersDaoTable,
    UsersDaoData,
    $$UsersDaoTableFilterComposer,
    $$UsersDaoTableOrderingComposer,
    $$UsersDaoTableAnnotationComposer,
    $$UsersDaoTableCreateCompanionBuilder,
    $$UsersDaoTableUpdateCompanionBuilder,
    (UsersDaoData, $$UsersDaoTableReferences),
    UsersDaoData,
    PrefetchHooks Function({bool measurementsDaoRefs, bool schedulesDaoRefs})>;
typedef $$MeasurementsDaoTableCreateCompanionBuilder = MeasurementsDaoCompanion
    Function({
  required String id,
  required String userId,
  required DateTime measurementTime,
  required int measurementNumber,
  required int systolic,
  required int diastolic,
  Value<int?> pulse,
  Value<String?> note,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$MeasurementsDaoTableUpdateCompanionBuilder = MeasurementsDaoCompanion
    Function({
  Value<String> id,
  Value<String> userId,
  Value<DateTime> measurementTime,
  Value<int> measurementNumber,
  Value<int> systolic,
  Value<int> diastolic,
  Value<int?> pulse,
  Value<String?> note,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$MeasurementsDaoTableReferences extends BaseReferences<
    _$AppDatabase, $MeasurementsDaoTable, MeasurementsDaoData> {
  $$MeasurementsDaoTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $UsersDaoTable _userIdTable(_$AppDatabase db) =>
      db.usersDao.createAlias(
          $_aliasNameGenerator(db.measurementsDao.userId, db.usersDao.id));

  $$UsersDaoTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UsersDaoTableTableManager($_db, $_db.usersDao)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$MeasurementsDaoTableFilterComposer
    extends Composer<_$AppDatabase, $MeasurementsDaoTable> {
  $$MeasurementsDaoTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get measurementTime => $composableBuilder(
      column: $table.measurementTime,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get measurementNumber => $composableBuilder(
      column: $table.measurementNumber,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get systolic => $composableBuilder(
      column: $table.systolic, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get diastolic => $composableBuilder(
      column: $table.diastolic, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pulse => $composableBuilder(
      column: $table.pulse, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$UsersDaoTableFilterComposer get userId {
    final $$UsersDaoTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.usersDao,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersDaoTableFilterComposer(
              $db: $db,
              $table: $db.usersDao,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MeasurementsDaoTableOrderingComposer
    extends Composer<_$AppDatabase, $MeasurementsDaoTable> {
  $$MeasurementsDaoTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get measurementTime => $composableBuilder(
      column: $table.measurementTime,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get measurementNumber => $composableBuilder(
      column: $table.measurementNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get systolic => $composableBuilder(
      column: $table.systolic, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get diastolic => $composableBuilder(
      column: $table.diastolic, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pulse => $composableBuilder(
      column: $table.pulse, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$UsersDaoTableOrderingComposer get userId {
    final $$UsersDaoTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.usersDao,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersDaoTableOrderingComposer(
              $db: $db,
              $table: $db.usersDao,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MeasurementsDaoTableAnnotationComposer
    extends Composer<_$AppDatabase, $MeasurementsDaoTable> {
  $$MeasurementsDaoTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get measurementTime => $composableBuilder(
      column: $table.measurementTime, builder: (column) => column);

  GeneratedColumn<int> get measurementNumber => $composableBuilder(
      column: $table.measurementNumber, builder: (column) => column);

  GeneratedColumn<int> get systolic =>
      $composableBuilder(column: $table.systolic, builder: (column) => column);

  GeneratedColumn<int> get diastolic =>
      $composableBuilder(column: $table.diastolic, builder: (column) => column);

  GeneratedColumn<int> get pulse =>
      $composableBuilder(column: $table.pulse, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$UsersDaoTableAnnotationComposer get userId {
    final $$UsersDaoTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.usersDao,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersDaoTableAnnotationComposer(
              $db: $db,
              $table: $db.usersDao,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MeasurementsDaoTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MeasurementsDaoTable,
    MeasurementsDaoData,
    $$MeasurementsDaoTableFilterComposer,
    $$MeasurementsDaoTableOrderingComposer,
    $$MeasurementsDaoTableAnnotationComposer,
    $$MeasurementsDaoTableCreateCompanionBuilder,
    $$MeasurementsDaoTableUpdateCompanionBuilder,
    (MeasurementsDaoData, $$MeasurementsDaoTableReferences),
    MeasurementsDaoData,
    PrefetchHooks Function({bool userId})> {
  $$MeasurementsDaoTableTableManager(
      _$AppDatabase db, $MeasurementsDaoTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MeasurementsDaoTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MeasurementsDaoTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MeasurementsDaoTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<DateTime> measurementTime = const Value.absent(),
            Value<int> measurementNumber = const Value.absent(),
            Value<int> systolic = const Value.absent(),
            Value<int> diastolic = const Value.absent(),
            Value<int?> pulse = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MeasurementsDaoCompanion(
            id: id,
            userId: userId,
            measurementTime: measurementTime,
            measurementNumber: measurementNumber,
            systolic: systolic,
            diastolic: diastolic,
            pulse: pulse,
            note: note,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            required DateTime measurementTime,
            required int measurementNumber,
            required int systolic,
            required int diastolic,
            Value<int?> pulse = const Value.absent(),
            Value<String?> note = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              MeasurementsDaoCompanion.insert(
            id: id,
            userId: userId,
            measurementTime: measurementTime,
            measurementNumber: measurementNumber,
            systolic: systolic,
            diastolic: diastolic,
            pulse: pulse,
            note: note,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$MeasurementsDaoTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (userId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.userId,
                    referencedTable:
                        $$MeasurementsDaoTableReferences._userIdTable(db),
                    referencedColumn:
                        $$MeasurementsDaoTableReferences._userIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$MeasurementsDaoTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MeasurementsDaoTable,
    MeasurementsDaoData,
    $$MeasurementsDaoTableFilterComposer,
    $$MeasurementsDaoTableOrderingComposer,
    $$MeasurementsDaoTableAnnotationComposer,
    $$MeasurementsDaoTableCreateCompanionBuilder,
    $$MeasurementsDaoTableUpdateCompanionBuilder,
    (MeasurementsDaoData, $$MeasurementsDaoTableReferences),
    MeasurementsDaoData,
    PrefetchHooks Function({bool userId})>;
typedef $$SchedulesDaoTableCreateCompanionBuilder = SchedulesDaoCompanion
    Function({
  required String id,
  required String userId,
  required int hour,
  required int minute,
  Value<bool> isEnabled,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$SchedulesDaoTableUpdateCompanionBuilder = SchedulesDaoCompanion
    Function({
  Value<String> id,
  Value<String> userId,
  Value<int> hour,
  Value<int> minute,
  Value<bool> isEnabled,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$SchedulesDaoTableReferences extends BaseReferences<_$AppDatabase,
    $SchedulesDaoTable, SchedulesDaoData> {
  $$SchedulesDaoTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersDaoTable _userIdTable(_$AppDatabase db) =>
      db.usersDao.createAlias(
          $_aliasNameGenerator(db.schedulesDao.userId, db.usersDao.id));

  $$UsersDaoTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UsersDaoTableTableManager($_db, $_db.usersDao)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$SchedulesDaoTableFilterComposer
    extends Composer<_$AppDatabase, $SchedulesDaoTable> {
  $$SchedulesDaoTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get hour => $composableBuilder(
      column: $table.hour, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get minute => $composableBuilder(
      column: $table.minute, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isEnabled => $composableBuilder(
      column: $table.isEnabled, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$UsersDaoTableFilterComposer get userId {
    final $$UsersDaoTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.usersDao,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersDaoTableFilterComposer(
              $db: $db,
              $table: $db.usersDao,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SchedulesDaoTableOrderingComposer
    extends Composer<_$AppDatabase, $SchedulesDaoTable> {
  $$SchedulesDaoTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get hour => $composableBuilder(
      column: $table.hour, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get minute => $composableBuilder(
      column: $table.minute, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
      column: $table.isEnabled, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$UsersDaoTableOrderingComposer get userId {
    final $$UsersDaoTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.usersDao,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersDaoTableOrderingComposer(
              $db: $db,
              $table: $db.usersDao,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SchedulesDaoTableAnnotationComposer
    extends Composer<_$AppDatabase, $SchedulesDaoTable> {
  $$SchedulesDaoTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get hour =>
      $composableBuilder(column: $table.hour, builder: (column) => column);

  GeneratedColumn<int> get minute =>
      $composableBuilder(column: $table.minute, builder: (column) => column);

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$UsersDaoTableAnnotationComposer get userId {
    final $$UsersDaoTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.usersDao,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersDaoTableAnnotationComposer(
              $db: $db,
              $table: $db.usersDao,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SchedulesDaoTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SchedulesDaoTable,
    SchedulesDaoData,
    $$SchedulesDaoTableFilterComposer,
    $$SchedulesDaoTableOrderingComposer,
    $$SchedulesDaoTableAnnotationComposer,
    $$SchedulesDaoTableCreateCompanionBuilder,
    $$SchedulesDaoTableUpdateCompanionBuilder,
    (SchedulesDaoData, $$SchedulesDaoTableReferences),
    SchedulesDaoData,
    PrefetchHooks Function({bool userId})> {
  $$SchedulesDaoTableTableManager(_$AppDatabase db, $SchedulesDaoTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SchedulesDaoTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SchedulesDaoTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SchedulesDaoTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<int> hour = const Value.absent(),
            Value<int> minute = const Value.absent(),
            Value<bool> isEnabled = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SchedulesDaoCompanion(
            id: id,
            userId: userId,
            hour: hour,
            minute: minute,
            isEnabled: isEnabled,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            required int hour,
            required int minute,
            Value<bool> isEnabled = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              SchedulesDaoCompanion.insert(
            id: id,
            userId: userId,
            hour: hour,
            minute: minute,
            isEnabled: isEnabled,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SchedulesDaoTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (userId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.userId,
                    referencedTable:
                        $$SchedulesDaoTableReferences._userIdTable(db),
                    referencedColumn:
                        $$SchedulesDaoTableReferences._userIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$SchedulesDaoTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SchedulesDaoTable,
    SchedulesDaoData,
    $$SchedulesDaoTableFilterComposer,
    $$SchedulesDaoTableOrderingComposer,
    $$SchedulesDaoTableAnnotationComposer,
    $$SchedulesDaoTableCreateCompanionBuilder,
    $$SchedulesDaoTableUpdateCompanionBuilder,
    (SchedulesDaoData, $$SchedulesDaoTableReferences),
    SchedulesDaoData,
    PrefetchHooks Function({bool userId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersDaoTableTableManager get usersDao =>
      $$UsersDaoTableTableManager(_db, _db.usersDao);
  $$MeasurementsDaoTableTableManager get measurementsDao =>
      $$MeasurementsDaoTableTableManager(_db, _db.measurementsDao);
  $$SchedulesDaoTableTableManager get schedulesDao =>
      $$SchedulesDaoTableTableManager(_db, _db.schedulesDao);
}
