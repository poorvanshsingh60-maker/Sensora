import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../database/database_helper.dart';
import '../models/session_model.dart';

class ExportResult {
  final bool success;
  final String filePath;
  final String format;
  final int recordCount;
  final String? errorMessage;

  ExportResult({
    required this.success,
    required this.filePath,
    required this.format,
    required this.recordCount,
    this.errorMessage,
  });
}

class ExportService {
  static final ExportService instance = ExportService._internal();

  ExportService._internal();

  /// Gets or creates the target export folder in Downloads/Documents
  Future<Directory> _getExportDirectory() async {
    Directory? baseDir;

    // 1. Try public/platform downloads directory
    try {
      baseDir = await getDownloadsDirectory();
    } catch (_) {}

    // 2. Fallback to external storage (Android)
    if (baseDir == null) {
      try {
        baseDir = await getExternalStorageDirectory();
      } catch (_) {}
    }

    // 3. Fallback to application documents directory
    baseDir ??= await getApplicationDocumentsDirectory();

    // Create a dedicated 'Sensora_Exports' sub-directory
    final exportDir = Directory(p.join(baseDir.path, 'Sensora_Exports'));
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }
    return exportDir;
  }

  String _sanitizeFileName(String name) {
    return name
        .replaceAll(RegExp(r'[\\/:*?"<>| ]'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .trim();
  }

  /// Exports a session and all its recorded points as a CSV file.
  Future<ExportResult> exportSessionToCsv(SessionModel session) async {
    try {
      final records = await DatabaseHelper.instance.getRecordsForSession(session.id!);
      final exportDir = await _getExportDirectory();

      final dateStamp = DateFormat('yyyyMMdd_HHmmss').format(session.startTime);
      final safeTitle = _sanitizeFileName(session.title);
      final fileName = '${safeTitle}_$dateStamp.csv';
      final file = File(p.join(exportDir.path, fileName));

      final buffer = StringBuffer();

      // Metadata header comments
      buffer.writeln('# Sensora — Offline Mobile Sensor Laboratory');
      buffer.writeln('# Session Title: ${session.title}');
      buffer.writeln('# Start Time: ${session.startTime.toIso8601String()}');
      buffer.writeln('# End Time: ${session.endTime?.toIso8601String() ?? "N/A"}');
      buffer.writeln('# Duration: ${session.formattedDuration} (${session.durationMs} ms)');
      buffer.writeln('# Total Samples: ${records.length}');
      buffer.writeln('# --------------------------------------------------');

      // CSV column headers
      buffer.writeln('timestamp,time_offset_ms,sensor_type,x,y,z,magnitude');

      // Records data rows
      for (final r in records) {
        buffer.writeln(
          '${r.timestamp.toIso8601String()},${r.timeOffsetMs},${r.sensorType},'
          '${r.x.toStringAsFixed(5)},${r.y.toStringAsFixed(5)},${r.z.toStringAsFixed(5)},'
          '${r.magnitude.toStringAsFixed(5)}',
        );
      }

      await file.writeAsString(buffer.toString(), flush: true);

      return ExportResult(
        success: true,
        filePath: file.path,
        format: 'CSV',
        recordCount: records.length,
      );
    } catch (e) {
      return ExportResult(
        success: false,
        filePath: '',
        format: 'CSV',
        recordCount: 0,
        errorMessage: e.toString(),
      );
    }
  }

  /// Exports a session and all its recorded points as a JSON file.
  Future<ExportResult> exportSessionToJson(SessionModel session) async {
    try {
      final records = await DatabaseHelper.instance.getRecordsForSession(session.id!);
      final exportDir = await _getExportDirectory();

      final dateStamp = DateFormat('yyyyMMdd_HHmmss').format(session.startTime);
      final safeTitle = _sanitizeFileName(session.title);
      final fileName = '${safeTitle}_$dateStamp.json';
      final file = File(p.join(exportDir.path, fileName));

      final data = {
        'metadata': {
          'app': 'Sensora — Offline Mobile Sensor Laboratory',
          'exportedAt': DateTime.now().toIso8601String(),
        },
        'session': {
          'id': session.id,
          'title': session.title,
          'startTime': session.startTime.toIso8601String(),
          'endTime': session.endTime?.toIso8601String(),
          'durationMs': session.durationMs,
          'formattedDuration': session.formattedDuration,
          'sampleCount': records.length,
        },
        'records': records.map((r) => {
          'timestamp': r.timestamp.toIso8601String(),
          'timeOffsetMs': r.timeOffsetMs,
          'sensorType': r.sensorType,
          'x': r.x,
          'y': r.y,
          'z': r.z,
          'magnitude': r.magnitude,
        }).toList(),
      };

      const encoder = JsonEncoder.withIndent('  ');
      await file.writeAsString(encoder.convert(data), flush: true);

      return ExportResult(
        success: true,
        filePath: file.path,
        format: 'JSON',
        recordCount: records.length,
      );
    } catch (e) {
      return ExportResult(
        success: false,
        filePath: '',
        format: 'JSON',
        recordCount: 0,
        errorMessage: e.toString(),
      );
    }
  }
}
