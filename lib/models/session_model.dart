class SessionModel {
  final int? id;
  final String title;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationMs;
  final int sampleCount;
  final String sensorTypes;
  final String samplingRate;

  SessionModel({
    this.id,
    required this.title,
    required this.startTime,
    this.endTime,
    this.durationMs = 0,
    this.sampleCount = 0,
    this.sensorTypes = '',
    this.samplingRate = 'Standard (25 Hz)',
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'duration_ms': durationMs,
      'sample_count': sampleCount,
      'sensor_types': sensorTypes,
      'sampling_rate': samplingRate,
    };
  }

  factory SessionModel.fromMap(Map<String, dynamic> map) {
    return SessionModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      startTime: DateTime.parse(map['start_time'] as String),
      endTime: map['end_time'] != null
          ? DateTime.parse(map['end_time'] as String)
          : null,
      durationMs: (map['duration_ms'] as num?)?.toInt() ?? 0,
      sampleCount: (map['sample_count'] as num?)?.toInt() ?? 0,
      sensorTypes: (map['sensor_types'] as String?) ?? '',
      samplingRate: (map['sampling_rate'] as String?) ?? 'Standard (25 Hz)',
    );
  }

  SessionModel copyWith({
    int? id,
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    int? durationMs,
    int? sampleCount,
    String? sensorTypes,
    String? samplingRate,
  }) {
    return SessionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMs: durationMs ?? this.durationMs,
      sampleCount: sampleCount ?? this.sampleCount,
      sensorTypes: sensorTypes ?? this.sensorTypes,
      samplingRate: samplingRate ?? this.samplingRate,
    );
  }

  List<String> get sensorList => sensorTypes
      .split(',')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();

  String get formattedDuration {
    final duration = Duration(milliseconds: durationMs);
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final tenths = ((duration.inMilliseconds.remainder(1000)) ~/ 100).toString();
    if (duration.inHours > 0) {
      final hours = duration.inHours.toString().padLeft(2, '0');
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds.$tenths';
  }
}
