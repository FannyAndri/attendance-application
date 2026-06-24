class Shift {
  final String id;
  final String name;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final double? gracePeriodMinutes;
  final bool isActive;

  Shift({
    required this.id,
    required this.name,
    required this.description,
    required this.startTime,
    required this.endTime,
    this.gracePeriodMinutes,
    required this.isActive,
  });

  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      gracePeriodMinutes: (json['gracePeriodMinutes'] as num?)?.toDouble(),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'gracePeriodMinutes': gracePeriodMinutes,
      'isActive': isActive,
    };
  }

  String getShiftTime() {
    return '${_formatTime(startTime)} - ${_formatTime(endTime)}';
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  bool isLate(DateTime checkInTime) {
    final checkInHour = checkInTime.hour;
    final checkInMinute = checkInTime.minute;
    final shiftStartMinutesTotal = startTime.hour * 60 + startTime.minute;
    final checkInMinutesTotal = checkInHour * 60 + checkInMinute;
    final gracePeriod = gracePeriodMinutes?.toInt() ?? 0;

    return checkInMinutesTotal > (shiftStartMinutesTotal + gracePeriod);
  }
}

class UserShift {
  final String id;
  final String userId;
  final String shiftId;
  final Shift shift;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;

  UserShift({
    required this.id,
    required this.userId,
    required this.shiftId,
    required this.shift,
    required this.startDate,
    this.endDate,
    required this.isActive,
  });

  factory UserShift.fromJson(Map<String, dynamic> json) {
    return UserShift(
      id: json['id'] as String,
      userId: json['userId'] as String,
      shiftId: json['shiftId'] as String,
      shift: Shift.fromJson(json['shift'] as Map<String, dynamic>),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'shiftId': shiftId,
      'shift': shift.toJson(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
    };
  }
}
