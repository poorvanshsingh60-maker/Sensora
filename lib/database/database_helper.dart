import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/sensor_record_model.dart';
import '../models/session_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'sensora_laboratory.db');

    return await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE sessions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            start_time TEXT NOT NULL,
            end_time TEXT,
            duration_ms INTEGER NOT NULL DEFAULT 0,
            sample_count INTEGER NOT NULL DEFAULT 0
          )
        ''');

        await db.execute('''
          CREATE TABLE sensor_records (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            session_id INTEGER NOT NULL,
            sensor_type TEXT NOT NULL,
            timestamp TEXT NOT NULL,
            time_offset_ms INTEGER NOT NULL,
            x REAL NOT NULL,
            y REAL NOT NULL,
            z REAL NOT NULL,
            magnitude REAL NOT NULL,
            FOREIGN KEY (session_id) REFERENCES sessions (id) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE INDEX idx_sensor_records_session_id 
          ON sensor_records (session_id)
        ''');
      },
    );
  }

  // --------------------------------------------------
  // SESSION OPERATIONS
  // --------------------------------------------------

  Future<int> insertSession(SessionModel session) async {
    final db = await database;
    return await db.insert('sessions', session.toMap());
  }

  Future<int> updateSession(SessionModel session) async {
    final db = await database;
    return await db.update(
      'sessions',
      session.toMap(),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  Future<List<SessionModel>> getAllSessions() async {
    final db = await database;
    final maps = await db.query(
      'sessions',
      orderBy: 'start_time DESC',
    );
    return maps.map((m) => SessionModel.fromMap(m)).toList();
  }

  Future<SessionModel?> getSessionById(int id) async {
    final db = await database;
    final maps = await db.query(
      'sessions',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return SessionModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> deleteSession(int id) async {
    final db = await database;
    return await db.delete(
      'sessions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearAllSessions() async {
    final db = await database;
    await db.delete('sessions');
  }

  // --------------------------------------------------
  // SENSOR RECORD OPERATIONS (BATCHED)
  // --------------------------------------------------

  Future<void> insertBatchRecords(List<SensorRecordModel> records) async {
    if (records.isEmpty) return;
    final db = await database;
    final batch = db.batch();

    for (final record in records) {
      batch.insert('sensor_records', record.toMap());
    }

    await batch.commit(noResult: true);
  }

  Future<List<SensorRecordModel>> getRecordsForSession(int sessionId) async {
    final db = await database;
    final maps = await db.query(
      'sensor_records',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'time_offset_ms ASC, id ASC',
    );
    return maps.map((m) => SensorRecordModel.fromMap(m)).toList();
  }

  Future<int> getRecordCountForSession(int sessionId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM sensor_records WHERE session_id = ?',
      [sessionId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
