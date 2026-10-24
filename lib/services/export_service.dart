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
  final String displayPath;
  final String fileName;
  final String format;
  final int recordCount;
  final String? errorMessage;

  ExportResult({
    required this.success,
    required this.filePath,
    required this.displayPath,
    required this.fileName,
    required this.format,
    required this.recordCount,
    this.errorMessage,
  });
}

class ExportService {
  static final ExportService instance = ExportService._internal();

  ExportService._internal();

  /// Gets or creates an easily accessible user export folder.
  /// Prioritizes the public Downloads/Sensora folder on Android so files are immediately
  /// visible in the device's Files/Downloads app.
  Future<Directory> _getExportDirectory() async {
    // 1. Android: Primary user-visible public Download directory
    if (Platform.isAndroid) {
      try {
        final publicDownload = Directory('/storage/emulated/0/Download');
        if (await publicDownload.exists()) {
          final sensoraFolder = Directory(p.join(publicDownload.path, 'Sensora'));
          if (!await sensoraFolder.exists()) {
            await sensoraFolder.create(recursive: true);
          }
          return sensoraFolder;
        }
      } catch (_) {
        // Fallback if permissions or Scoped Storage block direct path
      }
    }

    // 2. Standard Downloads directory via path_provider
    try {
      final downloads = await getDownloadsDirectory();
      if (downloads != null) {
        final sensoraFolder = Directory(p.join(downloads.path, 'Sensora'));
        if (!await sensoraFolder.exists()) {
          await sensoraFolder.create(recursive: true);
        }
        return sensoraFolder;
      }
    } catch (_) {}

    // 3. Android: App External Storage directory fallback
    if (Platform.isAndroid) {
      try {
        final ext = await getExternalStorageDirectory();
        if (ext != null) {
          final sensoraFolder = Directory(p.join(ext.path, 'Sensora'));
          if (!await sensoraFolder.exists()) {
            await sensoraFolder.create(recursive: true);
          }
          return sensoraFolder;
        }
      } catch (_) {}
    }

    // 4. Final fallback: Application Documents directory
    final appDocs = await getApplicationDocumentsDirectory();
    final sensoraFolder = Directory(p.join(appDocs.path, 'Sensora'));
    if (!await sensoraFolder.exists()) {
      await sensoraFolder.create(recursive: true);
    }
    return sensoraFolder;
  }

  String _sanitizeFileName(String name) {
    return name
        .replaceAll(RegExp(r'[\\/:*?"<>| ]'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .trim();
  }

  /// Formats long system directory paths into concise, recognizable paths for users
  String _formatDisplayPath(String fullPath, String fileName) {
    if (fullPath.contains('/storage/emulated/0/Download/Sensora/')) {
      return 'Downloads > Sensora > $fileName';
    }
    if (fullPath.contains('/storage/emulated/0/Download/')) {
      return 'Downloads > $fileName';
    }
    if (fullPath.contains('/storage/emulated/0/')) {
      final relative = fullPath.replaceFirst('/storage/emulated/0/', '');
      return 'Internal Storage > $relative';
    }
    // Desktop / iOS user path shortening
    final userHome = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
    if (userHome != null && fullPath.startsWith(userHome)) {
      return fullPath.replaceFirst(userHome, '~');
    }
    return fullPath;
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
      buffer.writeln('# Sampling Rate: ${session.samplingRate}');
      if (session.sensorTypes.isNotEmpty) {
        buffer.writeln('# Sensors Recorded: ${session.sensorTypes}');
      }
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
        displayPath: _formatDisplayPath(file.path, fileName),
        fileName: fileName,
        format: 'CSV',
        recordCount: records.length,
      );
    } catch (e) {
      return ExportResult(
        success: false,
        filePath: '',
        displayPath: '',
        fileName: '',
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
          'samplingRate': session.samplingRate,
          'sensorTypes': session.sensorTypes,
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
        displayPath: _formatDisplayPath(file.path, fileName),
        fileName: fileName,
        format: 'JSON',
        recordCount: records.length,
      );
    } catch (e) {
      return ExportResult(
        success: false,
        filePath: '',
        displayPath: '',
        fileName: '',
        format: 'JSON',
        recordCount: 0,
        errorMessage: e.toString(),
      );
    }
  }
}
