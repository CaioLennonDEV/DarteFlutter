class AudioMemo {
  final String id;
  final String title;
  final int durationSeconds;
  final String? transcript;
  final DateTime recordedAt;

  const AudioMemo({
    required this.id,
    required this.title,
    required this.durationSeconds,
    this.transcript,
    required this.recordedAt,
  });

  String get formattedDuration {
    final minutes = (durationSeconds / 60).floor().toString().padLeft(2, '0');
    final seconds = (durationSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'durationSeconds': durationSeconds,
      'transcript': transcript,
      'recordedAt': recordedAt.toIso8601String(),
    };
  }

  factory AudioMemo.fromMap(Map<dynamic, dynamic> map) {
    return AudioMemo(
      id: (map['id'] as String?) ?? '',
      title: (map['title'] as String?) ?? 'Áudio sem título',
      durationSeconds: (map['durationSeconds'] as num?)?.toInt() ?? 0,
      transcript: map['transcript'] as String?,
      recordedAt: map['recordedAt'] != null
          ? DateTime.tryParse(map['recordedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
