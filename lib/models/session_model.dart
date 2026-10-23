class SessionModel {
  final int? id;
  final String title;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationMs;
  final int sampleCount;

  SessionModel({
    this.id,
    required this.title,
    required this.startTime,
    this.endTime,
    this.durationMs = 0,
    this.sampleCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'duration_ms': durationMs,
      'sample_count': sampleCount,
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
    );
  }

  SessionModel copyWith({
    int? id,
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    int? durationMs,
    int? sampleCount,
  }) {
    return SessionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMs: durationMs ?? this.durationMs,
      sampleCount: sampleCount ?? this.sampleCount,
    );
  }

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
