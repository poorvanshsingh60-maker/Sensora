// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SensorLogsTableTable extends SensorLogsTable
    with TableInfo<$SensorLogsTableTable, SensorLogsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SensorLogsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _accXMeta = const VerificationMeta('accX');
  @override
  late final GeneratedColumn<double> accX = GeneratedColumn<double>(
      'acc_x', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _accYMeta = const VerificationMeta('accY');
  @override
  late final GeneratedColumn<double> accY = GeneratedColumn<double>(
      'acc_y', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _accZMeta = const VerificationMeta('accZ');
  @override
  late final GeneratedColumn<double> accZ = GeneratedColumn<double>(
      'acc_z', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _gyroXMeta = const VerificationMeta('gyroX');
  @override
  late final GeneratedColumn<double> gyroX = GeneratedColumn<double>(
      'gyro_x', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _gyroYMeta = const VerificationMeta('gyroY');
  @override
  late final GeneratedColumn<double> gyroY = GeneratedColumn<double>(
      'gyro_y', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _gyroZMeta = const VerificationMeta('gyroZ');
  @override
  late final GeneratedColumn<double> gyroZ = GeneratedColumn<double>(
      'gyro_z', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _magXMeta = const VerificationMeta('magX');
  @override
  late final GeneratedColumn<double> magX = GeneratedColumn<double>(
      'mag_x', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _magYMeta = const VerificationMeta('magY');
  @override
  late final GeneratedColumn<double> magY = GeneratedColumn<double>(
      'mag_y', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _magZMeta = const VerificationMeta('magZ');
  @override
  late final GeneratedColumn<double> magZ = GeneratedColumn<double>(
      'mag_z', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _headingMeta =
      const VerificationMeta('heading');
  @override
  late final GeneratedColumn<double> heading = GeneratedColumn<double>(
      'heading', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _isStationaryMeta =
      const VerificationMeta('isStationary');
  @override
  late final GeneratedColumn<bool> isStationary = GeneratedColumn<bool>(
      'is_stationary', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_stationary" IN (0, 1))'));
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        accX,
        accY,
        accZ,
        gyroX,
        gyroY,
        gyroZ,
        magX,
        magY,
        magZ,
        heading,
        isStationary,
        timestamp
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sensor_logs_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<SensorLogsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('acc_x')) {
      context.handle(
          _accXMeta, accX.isAcceptableOrUnknown(data['acc_x']!, _accXMeta));
    } else if (isInserting) {
      context.missing(_accXMeta);
    }
    if (data.containsKey('acc_y')) {
      context.handle(
          _accYMeta, accY.isAcceptableOrUnknown(data['acc_y']!, _accYMeta));
    } else if (isInserting) {
      context.missing(_accYMeta);
    }
    if (data.containsKey('acc_z')) {
      context.handle(
          _accZMeta, accZ.isAcceptableOrUnknown(data['acc_z']!, _accZMeta));
    } else if (isInserting) {
      context.missing(_accZMeta);
    }
    if (data.containsKey('gyro_x')) {
      context.handle(
          _gyroXMeta, gyroX.isAcceptableOrUnknown(data['gyro_x']!, _gyroXMeta));
    } else if (isInserting) {
      context.missing(_gyroXMeta);
    }
    if (data.containsKey('gyro_y')) {
      context.handle(
          _gyroYMeta, gyroY.isAcceptableOrUnknown(data['gyro_y']!, _gyroYMeta));
    } else if (isInserting) {
      context.missing(_gyroYMeta);
    }
    if (data.containsKey('gyro_z')) {
      context.handle(
          _gyroZMeta, gyroZ.isAcceptableOrUnknown(data['gyro_z']!, _gyroZMeta));
    } else if (isInserting) {
      context.missing(_gyroZMeta);
    }
    if (data.containsKey('mag_x')) {
      context.handle(
          _magXMeta, magX.isAcceptableOrUnknown(data['mag_x']!, _magXMeta));
    } else if (isInserting) {
      context.missing(_magXMeta);
    }
    if (data.containsKey('mag_y')) {
      context.handle(
          _magYMeta, magY.isAcceptableOrUnknown(data['mag_y']!, _magYMeta));
    } else if (isInserting) {
      context.missing(_magYMeta);
    }
    if (data.containsKey('mag_z')) {
      context.handle(
          _magZMeta, magZ.isAcceptableOrUnknown(data['mag_z']!, _magZMeta));
    } else if (isInserting) {
      context.missing(_magZMeta);
    }
    if (data.containsKey('heading')) {
      context.handle(_headingMeta,
          heading.isAcceptableOrUnknown(data['heading']!, _headingMeta));
    } else if (isInserting) {
      context.missing(_headingMeta);
    }
    if (data.containsKey('is_stationary')) {
      context.handle(
          _isStationaryMeta,
          isStationary.isAcceptableOrUnknown(
              data['is_stationary']!, _isStationaryMeta));
    } else if (isInserting) {
      context.missing(_isStationaryMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SensorLogsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SensorLogsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      accX: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}acc_x'])!,
      accY: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}acc_y'])!,
      accZ: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}acc_z'])!,
      gyroX: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}gyro_x'])!,
      gyroY: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}gyro_y'])!,
      gyroZ: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}gyro_z'])!,
      magX: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}mag_x'])!,
      magY: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}mag_y'])!,
      magZ: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}mag_z'])!,
      heading: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}heading'])!,
      isStationary: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_stationary'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
    );
  }

  @override
  $SensorLogsTableTable createAlias(String alias) {
    return $SensorLogsTableTable(attachedDatabase, alias);
  }
}

class SensorLogsTableData extends DataClass
    implements Insertable<SensorLogsTableData> {
  final int id;
  final double accX;
  final double accY;
  final double accZ;
  final double gyroX;
  final double gyroY;
  final double gyroZ;
  final double magX;
  final double magY;
  final double magZ;
  final double heading;
  final bool isStationary;
  final DateTime timestamp;
  const SensorLogsTableData(
      {required this.id,
      required this.accX,
      required this.accY,
      required this.accZ,
      required this.gyroX,
      required this.gyroY,
      required this.gyroZ,
      required this.magX,
      required this.magY,
      required this.magZ,
      required this.heading,
      required this.isStationary,
      required this.timestamp});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['acc_x'] = Variable<double>(accX);
    map['acc_y'] = Variable<double>(accY);
    map['acc_z'] = Variable<double>(accZ);
    map['gyro_x'] = Variable<double>(gyroX);
    map['gyro_y'] = Variable<double>(gyroY);
    map['gyro_z'] = Variable<double>(gyroZ);
    map['mag_x'] = Variable<double>(magX);
    map['mag_y'] = Variable<double>(magY);
    map['mag_z'] = Variable<double>(magZ);
    map['heading'] = Variable<double>(heading);
    map['is_stationary'] = Variable<bool>(isStationary);
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  SensorLogsTableCompanion toCompanion(bool nullToAbsent) {
    return SensorLogsTableCompanion(
      id: Value(id),
      accX: Value(accX),
      accY: Value(accY),
      accZ: Value(accZ),
      gyroX: Value(gyroX),
      gyroY: Value(gyroY),
      gyroZ: Value(gyroZ),
      magX: Value(magX),
      magY: Value(magY),
      magZ: Value(magZ),
      heading: Value(heading),
      isStationary: Value(isStationary),
      timestamp: Value(timestamp),
    );
  }

  factory SensorLogsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SensorLogsTableData(
      id: serializer.fromJson<int>(json['id']),
      accX: serializer.fromJson<double>(json['accX']),
      accY: serializer.fromJson<double>(json['accY']),
      accZ: serializer.fromJson<double>(json['accZ']),
      gyroX: serializer.fromJson<double>(json['gyroX']),
      gyroY: serializer.fromJson<double>(json['gyroY']),
      gyroZ: serializer.fromJson<double>(json['gyroZ']),
      magX: serializer.fromJson<double>(json['magX']),
      magY: serializer.fromJson<double>(json['magY']),
      magZ: serializer.fromJson<double>(json['magZ']),
      heading: serializer.fromJson<double>(json['heading']),
      isStationary: serializer.fromJson<bool>(json['isStationary']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'accX': serializer.toJson<double>(accX),
      'accY': serializer.toJson<double>(accY),
      'accZ': serializer.toJson<double>(accZ),
      'gyroX': serializer.toJson<double>(gyroX),
      'gyroY': serializer.toJson<double>(gyroY),
      'gyroZ': serializer.toJson<double>(gyroZ),
      'magX': serializer.toJson<double>(magX),
      'magY': serializer.toJson<double>(magY),
      'magZ': serializer.toJson<double>(magZ),
      'heading': serializer.toJson<double>(heading),
      'isStationary': serializer.toJson<bool>(isStationary),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  SensorLogsTableData copyWith(
          {int? id,
          double? accX,
          double? accY,
          double? accZ,
          double? gyroX,
          double? gyroY,
          double? gyroZ,
          double? magX,
          double? magY,
          double? magZ,
          double? heading,
          bool? isStationary,
          DateTime? timestamp}) =>
      SensorLogsTableData(
        id: id ?? this.id,
        accX: accX ?? this.accX,
        accY: accY ?? this.accY,
        accZ: accZ ?? this.accZ,
        gyroX: gyroX ?? this.gyroX,
        gyroY: gyroY ?? this.gyroY,
        gyroZ: gyroZ ?? this.gyroZ,
        magX: magX ?? this.magX,
        magY: magY ?? this.magY,
        magZ: magZ ?? this.magZ,
        heading: heading ?? this.heading,
        isStationary: isStationary ?? this.isStationary,
        timestamp: timestamp ?? this.timestamp,
      );
  SensorLogsTableData copyWithCompanion(SensorLogsTableCompanion data) {
    return SensorLogsTableData(
      id: data.id.present ? data.id.value : this.id,
      accX: data.accX.present ? data.accX.value : this.accX,
      accY: data.accY.present ? data.accY.value : this.accY,
      accZ: data.accZ.present ? data.accZ.value : this.accZ,
      gyroX: data.gyroX.present ? data.gyroX.value : this.gyroX,
      gyroY: data.gyroY.present ? data.gyroY.value : this.gyroY,
      gyroZ: data.gyroZ.present ? data.gyroZ.value : this.gyroZ,
      magX: data.magX.present ? data.magX.value : this.magX,
      magY: data.magY.present ? data.magY.value : this.magY,
      magZ: data.magZ.present ? data.magZ.value : this.magZ,
      heading: data.heading.present ? data.heading.value : this.heading,
      isStationary: data.isStationary.present
          ? data.isStationary.value
          : this.isStationary,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SensorLogsTableData(')
          ..write('id: $id, ')
          ..write('accX: $accX, ')
          ..write('accY: $accY, ')
          ..write('accZ: $accZ, ')
          ..write('gyroX: $gyroX, ')
          ..write('gyroY: $gyroY, ')
          ..write('gyroZ: $gyroZ, ')
          ..write('magX: $magX, ')
          ..write('magY: $magY, ')
          ..write('magZ: $magZ, ')
          ..write('heading: $heading, ')
          ..write('isStationary: $isStationary, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, accX, accY, accZ, gyroX, gyroY, gyroZ,
      magX, magY, magZ, heading, isStationary, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SensorLogsTableData &&
          other.id == this.id &&
          other.accX == this.accX &&
          other.accY == this.accY &&
          other.accZ == this.accZ &&
          other.gyroX == this.gyroX &&
          other.gyroY == this.gyroY &&
          other.gyroZ == this.gyroZ &&
          other.magX == this.magX &&
          other.magY == this.magY &&
          other.magZ == this.magZ &&
          other.heading == this.heading &&
          other.isStationary == this.isStationary &&
          other.timestamp == this.timestamp);
}

class SensorLogsTableCompanion extends UpdateCompanion<SensorLogsTableData> {
  final Value<int> id;
  final Value<double> accX;
  final Value<double> accY;
  final Value<double> accZ;
  final Value<double> gyroX;
  final Value<double> gyroY;
  final Value<double> gyroZ;
  final Value<double> magX;
  final Value<double> magY;
  final Value<double> magZ;
  final Value<double> heading;
  final Value<bool> isStationary;
  final Value<DateTime> timestamp;
  const SensorLogsTableCompanion({
    this.id = const Value.absent(),
    this.accX = const Value.absent(),
    this.accY = const Value.absent(),
    this.accZ = const Value.absent(),
    this.gyroX = const Value.absent(),
    this.gyroY = const Value.absent(),
    this.gyroZ = const Value.absent(),
    this.magX = const Value.absent(),
    this.magY = const Value.absent(),
    this.magZ = const Value.absent(),
    this.heading = const Value.absent(),
    this.isStationary = const Value.absent(),
    this.timestamp = const Value.absent(),
  });
  SensorLogsTableCompanion.insert({
    this.id = const Value.absent(),
    required double accX,
    required double accY,
    required double accZ,
    required double gyroX,
    required double gyroY,
    required double gyroZ,
    required double magX,
    required double magY,
    required double magZ,
    required double heading,
    required bool isStationary,
    required DateTime timestamp,
  })  : accX = Value(accX),
        accY = Value(accY),
        accZ = Value(accZ),
        gyroX = Value(gyroX),
        gyroY = Value(gyroY),
        gyroZ = Value(gyroZ),
        magX = Value(magX),
        magY = Value(magY),
        magZ = Value(magZ),
        heading = Value(heading),
        isStationary = Value(isStationary),
        timestamp = Value(timestamp);
  static Insertable<SensorLogsTableData> custom({
    Expression<int>? id,
    Expression<double>? accX,
    Expression<double>? accY,
    Expression<double>? accZ,
    Expression<double>? gyroX,
    Expression<double>? gyroY,
    Expression<double>? gyroZ,
    Expression<double>? magX,
    Expression<double>? magY,
    Expression<double>? magZ,
    Expression<double>? heading,
    Expression<bool>? isStationary,
    Expression<DateTime>? timestamp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accX != null) 'acc_x': accX,
      if (accY != null) 'acc_y': accY,
      if (accZ != null) 'acc_z': accZ,
      if (gyroX != null) 'gyro_x': gyroX,
      if (gyroY != null) 'gyro_y': gyroY,
      if (gyroZ != null) 'gyro_z': gyroZ,
      if (magX != null) 'mag_x': magX,
      if (magY != null) 'mag_y': magY,
      if (magZ != null) 'mag_z': magZ,
      if (heading != null) 'heading': heading,
      if (isStationary != null) 'is_stationary': isStationary,
      if (timestamp != null) 'timestamp': timestamp,
    });
  }

  SensorLogsTableCompanion copyWith(
      {Value<int>? id,
      Value<double>? accX,
      Value<double>? accY,
      Value<double>? accZ,
      Value<double>? gyroX,
      Value<double>? gyroY,
      Value<double>? gyroZ,
      Value<double>? magX,
      Value<double>? magY,
      Value<double>? magZ,
      Value<double>? heading,
      Value<bool>? isStationary,
      Value<DateTime>? timestamp}) {
    return SensorLogsTableCompanion(
      id: id ?? this.id,
      accX: accX ?? this.accX,
      accY: accY ?? this.accY,
      accZ: accZ ?? this.accZ,
      gyroX: gyroX ?? this.gyroX,
      gyroY: gyroY ?? this.gyroY,
      gyroZ: gyroZ ?? this.gyroZ,
      magX: magX ?? this.magX,
      magY: magY ?? this.magY,
      magZ: magZ ?? this.magZ,
      heading: heading ?? this.heading,
      isStationary: isStationary ?? this.isStationary,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (accX.present) {
      map['acc_x'] = Variable<double>(accX.value);
    }
    if (accY.present) {
      map['acc_y'] = Variable<double>(accY.value);
    }
    if (accZ.present) {
      map['acc_z'] = Variable<double>(accZ.value);
    }
    if (gyroX.present) {
      map['gyro_x'] = Variable<double>(gyroX.value);
    }
    if (gyroY.present) {
      map['gyro_y'] = Variable<double>(gyroY.value);
    }
    if (gyroZ.present) {
      map['gyro_z'] = Variable<double>(gyroZ.value);
    }
    if (magX.present) {
      map['mag_x'] = Variable<double>(magX.value);
    }
    if (magY.present) {
      map['mag_y'] = Variable<double>(magY.value);
    }
    if (magZ.present) {
      map['mag_z'] = Variable<double>(magZ.value);
    }
    if (heading.present) {
      map['heading'] = Variable<double>(heading.value);
    }
    if (isStationary.present) {
      map['is_stationary'] = Variable<bool>(isStationary.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SensorLogsTableCompanion(')
          ..write('id: $id, ')
          ..write('accX: $accX, ')
          ..write('accY: $accY, ')
          ..write('accZ: $accZ, ')
          ..write('gyroX: $gyroX, ')
          ..write('gyroY: $gyroY, ')
          ..write('gyroZ: $gyroZ, ')
          ..write('magX: $magX, ')
          ..write('magY: $magY, ')
          ..write('magZ: $magZ, ')
          ..write('heading: $heading, ')
          ..write('isStationary: $isStationary, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SensorLogsTableTable sensorLogsTable =
      $SensorLogsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [sensorLogsTable];
}

typedef $$SensorLogsTableTableCreateCompanionBuilder = SensorLogsTableCompanion
    Function({
  Value<int> id,
  required double accX,
  required double accY,
  required double accZ,
  required double gyroX,
  required double gyroY,
  required double gyroZ,
  required double magX,
  required double magY,
  required double magZ,
  required double heading,
  required bool isStationary,
  required DateTime timestamp,
});
typedef $$SensorLogsTableTableUpdateCompanionBuilder = SensorLogsTableCompanion
    Function({
  Value<int> id,
  Value<double> accX,
  Value<double> accY,
  Value<double> accZ,
  Value<double> gyroX,
  Value<double> gyroY,
  Value<double> gyroZ,
  Value<double> magX,
  Value<double> magY,
  Value<double> magZ,
  Value<double> heading,
  Value<bool> isStationary,
  Value<DateTime> timestamp,
});

class $$SensorLogsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SensorLogsTableTable> {
  $$SensorLogsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get accX => $composableBuilder(
      column: $table.accX, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get accY => $composableBuilder(
      column: $table.accY, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get accZ => $composableBuilder(
      column: $table.accZ, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get gyroX => $composableBuilder(
      column: $table.gyroX, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get gyroY => $composableBuilder(
      column: $table.gyroY, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get gyroZ => $composableBuilder(
      column: $table.gyroZ, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get magX => $composableBuilder(
      column: $table.magX, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get magY => $composableBuilder(
      column: $table.magY, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get magZ => $composableBuilder(
      column: $table.magZ, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get heading => $composableBuilder(
      column: $table.heading, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isStationary => $composableBuilder(
      column: $table.isStationary, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));
}

class $$SensorLogsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SensorLogsTableTable> {
  $$SensorLogsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get accX => $composableBuilder(
      column: $table.accX, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get accY => $composableBuilder(
      column: $table.accY, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get accZ => $composableBuilder(
      column: $table.accZ, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get gyroX => $composableBuilder(
      column: $table.gyroX, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get gyroY => $composableBuilder(
      column: $table.gyroY, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get gyroZ => $composableBuilder(
      column: $table.gyroZ, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get magX => $composableBuilder(
      column: $table.magX, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get magY => $composableBuilder(
      column: $table.magY, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get magZ => $composableBuilder(
      column: $table.magZ, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get heading => $composableBuilder(
      column: $table.heading, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isStationary => $composableBuilder(
      column: $table.isStationary,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));
}

class $$SensorLogsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SensorLogsTableTable> {
  $$SensorLogsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get accX =>
      $composableBuilder(column: $table.accX, builder: (column) => column);

  GeneratedColumn<double> get accY =>
      $composableBuilder(column: $table.accY, builder: (column) => column);

  GeneratedColumn<double> get accZ =>
      $composableBuilder(column: $table.accZ, builder: (column) => column);

  GeneratedColumn<double> get gyroX =>
      $composableBuilder(column: $table.gyroX, builder: (column) => column);

  GeneratedColumn<double> get gyroY =>
      $composableBuilder(column: $table.gyroY, builder: (column) => column);

  GeneratedColumn<double> get gyroZ =>
      $composableBuilder(column: $table.gyroZ, builder: (column) => column);

  GeneratedColumn<double> get magX =>
      $composableBuilder(column: $table.magX, builder: (column) => column);

  GeneratedColumn<double> get magY =>
      $composableBuilder(column: $table.magY, builder: (column) => column);

  GeneratedColumn<double> get magZ =>
      $composableBuilder(column: $table.magZ, builder: (column) => column);

  GeneratedColumn<double> get heading =>
      $composableBuilder(column: $table.heading, builder: (column) => column);

  GeneratedColumn<bool> get isStationary => $composableBuilder(
      column: $table.isStationary, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);
}

class $$SensorLogsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SensorLogsTableTable,
    SensorLogsTableData,
    $$SensorLogsTableTableFilterComposer,
    $$SensorLogsTableTableOrderingComposer,
    $$SensorLogsTableTableAnnotationComposer,
    $$SensorLogsTableTableCreateCompanionBuilder,
    $$SensorLogsTableTableUpdateCompanionBuilder,
    (
      SensorLogsTableData,
      BaseReferences<_$AppDatabase, $SensorLogsTableTable, SensorLogsTableData>
    ),
    SensorLogsTableData,
    PrefetchHooks Function()> {
  $$SensorLogsTableTableTableManager(
      _$AppDatabase db, $SensorLogsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SensorLogsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SensorLogsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SensorLogsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<double> accX = const Value.absent(),
            Value<double> accY = const Value.absent(),
            Value<double> accZ = const Value.absent(),
            Value<double> gyroX = const Value.absent(),
            Value<double> gyroY = const Value.absent(),
            Value<double> gyroZ = const Value.absent(),
            Value<double> magX = const Value.absent(),
            Value<double> magY = const Value.absent(),
            Value<double> magZ = const Value.absent(),
            Value<double> heading = const Value.absent(),
            Value<bool> isStationary = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
          }) =>
              SensorLogsTableCompanion(
            id: id,
            accX: accX,
            accY: accY,
            accZ: accZ,
            gyroX: gyroX,
            gyroY: gyroY,
            gyroZ: gyroZ,
            magX: magX,
            magY: magY,
            magZ: magZ,
            heading: heading,
            isStationary: isStationary,
            timestamp: timestamp,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required double accX,
            required double accY,
            required double accZ,
            required double gyroX,
            required double gyroY,
            required double gyroZ,
            required double magX,
            required double magY,
            required double magZ,
            required double heading,
            required bool isStationary,
            required DateTime timestamp,
          }) =>
              SensorLogsTableCompanion.insert(
            id: id,
            accX: accX,
            accY: accY,
            accZ: accZ,
            gyroX: gyroX,
            gyroY: gyroY,
            gyroZ: gyroZ,
            magX: magX,
            magY: magY,
            magZ: magZ,
            heading: heading,
            isStationary: isStationary,
            timestamp: timestamp,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$SensorLogsTableTable, SensorLogsTableData>(
                        table),
                    BaseReferences<_$AppDatabase, $SensorLogsTableTable,
                        SensorLogsTableData>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SensorLogsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SensorLogsTableTable,
    SensorLogsTableData,
    $$SensorLogsTableTableFilterComposer,
    $$SensorLogsTableTableOrderingComposer,
    $$SensorLogsTableTableAnnotationComposer,
    $$SensorLogsTableTableCreateCompanionBuilder,
    $$SensorLogsTableTableUpdateCompanionBuilder,
    (
      SensorLogsTableData,
      BaseReferences<_$AppDatabase, $SensorLogsTableTable, SensorLogsTableData>
    ),
    SensorLogsTableData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SensorLogsTableTableTableManager get sensorLogsTable =>
      $$SensorLogsTableTableTableManager(_db, _db.sensorLogsTable);
}
