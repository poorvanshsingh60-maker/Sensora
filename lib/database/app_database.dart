import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

class SensorLogsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get accX => real()();
  RealColumn get accY => real()();
  RealColumn get accZ => real()();
  RealColumn get gyroX => real()();
  RealColumn get gyroY => real()();
  RealColumn get gyroZ => real()();
  RealColumn get magX => real()();
  RealColumn get magY => real()();
  RealColumn get magZ => real()();
  RealColumn get heading => real()();
  BoolColumn get isStationary => boolean()();
  DateTimeColumn get timestamp => dateTime()();
}

@DriftDatabase(tables: [SensorLogsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          // Recreate table cleanly for sandbox schema upgrade
          await m.deleteTable('sensor_logs_table');
          await m.createAll();
        },
      );

  Future<void> batchInsertSensorLogs(List<SensorLogsTableCompanion> entries) async {
    await batch((batch) {
      batch.insertAll(sensorLogsTable, entries);
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'sensora_telemetry_v2.sqlite'));
    return NativeDatabase(file);
  });
}