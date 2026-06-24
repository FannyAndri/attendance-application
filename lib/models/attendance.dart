class AttendanceRecord {
  final String id;
  final String userId;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final double checkInLat;
  final double checkInLng;
  final double? checkOutLat;
  final double? checkOutLng;
  final String status; // 'present', 'absent', 'wfh', 'late', 'half-day'
  final String? notes;
  final bool isWFH;
  final DateTime date;
  final List<LocationTrack> locationTracks;

  AttendanceRecord({
    required this.id,
    required this.userId,
    required this.checkInTime,
    this.checkOutTime,
    required this.checkInLat,
    required this.checkInLng,
    this.checkOutLat,
    this.checkOutLng,
    required this.status,
    this.notes,
    required this.isWFH,
    required this.date,
    this.locationTracks = const [],
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] as String,
      userId: json['userId'] as String,
      checkInTime: DateTime.parse(json['checkInTime'] as String),
      checkOutTime: json['checkOutTime'] != null
          ? DateTime.parse(json['checkOutTime'] as String)
          : null,
      checkInLat: (json['checkInLat'] as num).toDouble(),
      checkInLng: (json['checkInLng'] as num).toDouble(),
      checkOutLat: json['checkOutLat'] != null
          ? (json['checkOutLat'] as num).toDouble()
          : null,
      checkOutLng: json['checkOutLng'] != null
          ? (json['checkOutLng'] as num).toDouble()
          : null,
      status: json['status'] as String,
      notes: json['notes'] as String?,
      isWFH: json['isWFH'] as bool? ?? false,
      date: DateTime.parse(json['date'] as String),
      locationTracks: (json['locationTracks'] as List<dynamic>?)
              ?.map((e) => LocationTrack.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'checkInTime': checkInTime.toIso8601String(),
    'checkOutTime': checkOutTime?.toIso8601String(),
    'checkInLat': checkInLat,
    'checkInLng': checkInLng,
    'checkOutLat': checkOutLat,
    'checkOutLng': checkOutLng,
    'status': status,
    'notes': notes,
    'isWFH': isWFH,
    'date': date.toIso8601String(),
    'locationTracks': locationTracks.map((e) => e.toJson()).toList(),
  };

  AttendanceRecord copyWith({
    String? id,
    String? userId,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    double? checkInLat,
    double? checkInLng,
    double? checkOutLat,
    double? checkOutLng,
    String? status,
    String? notes,
    bool? isWFH,
    DateTime? date,
    List<LocationTrack>? locationTracks,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      checkInLat: checkInLat ?? this.checkInLat,
      checkInLng: checkInLng ?? this.checkInLng,
      checkOutLat: checkOutLat ?? this.checkOutLat,
      checkOutLng: checkOutLng ?? this.checkOutLng,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      isWFH: isWFH ?? this.isWFH,
      date: date ?? this.date,
      locationTracks: locationTracks ?? this.locationTracks,
    );
  }

  Duration? getDuration() {
    if (checkOutTime == null) return null;
    return checkOutTime!.difference(checkInTime);
  }

  String getFormattedDuration() {
    final duration = getDuration();
    if (duration == null) return 'Ongoing';
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '$hours:${minutes.toString().padLeft(2, '0')}';
  }
}

class LocationTrack {
  final String id;
  final String attendanceId;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final double accuracy;
  final bool isAnomalous;

  LocationTrack({
    required this.id,
    required this.attendanceId,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    this.isAnomalous = false,
  });

  factory LocationTrack.fromJson(Map<String, dynamic> json) {
    return LocationTrack(
      id: json['id'] as String,
      attendanceId: json['attendanceId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracy: (json['accuracy'] as num).toDouble(),
      isAnomalous: json['isAnomalous'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'attendanceId': attendanceId,
    'timestamp': timestamp.toIso8601String(),
    'latitude': latitude,
    'longitude': longitude,
    'accuracy': accuracy,
    'isAnomalous': isAnomalous,
  };
}
