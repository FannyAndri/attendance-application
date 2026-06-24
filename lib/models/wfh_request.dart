import 'dart:math' as math;

class WFHRequest {
  final String id;
  final String userId;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final String status; // 'pending', 'approved', 'rejected'
  final String? approverComments;
  final DateTime createdAt;
  final DateTime? approvedAt;
  final String? approvedBy;

  WFHRequest({
    required this.id,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    this.approverComments,
    required this.createdAt,
    this.approvedAt,
    this.approvedBy,
  });

  factory WFHRequest.fromJson(Map<String, dynamic> json) {
    return WFHRequest(
      id: json['id'] as String,
      userId: json['userId'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      reason: json['reason'] as String,
      status: json['status'] as String,
      approverComments: json['approverComments'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'] as String)
          : null,
      approvedBy: json['approvedBy'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'reason': reason,
    'status': status,
    'approverComments': approverComments,
    'createdAt': createdAt.toIso8601String(),
    'approvedAt': approvedAt?.toIso8601String(),
    'approvedBy': approvedBy,
  };

  int getDurationDays() {
    return endDate.difference(startDate).inDays + 1;
  }

  bool isApproved() => status == 'approved';
  bool isPending() => status == 'pending';
  bool isRejected() => status == 'rejected';
}

class Geofence {
  final String id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final double radiusInMeters;
  final String? address;
  final bool isActive;

  Geofence({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.radiusInMeters,
    this.address,
    required this.isActive,
  });

  factory Geofence.fromJson(Map<String, dynamic> json) {
    return Geofence(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      radiusInMeters: (json['radiusInMeters'] as num).toDouble(),
      address: json['address'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'latitude': latitude,
    'longitude': longitude,
    'radiusInMeters': radiusInMeters,
    'address': address,
    'isActive': isActive,
  };

  bool isLocationInside(double lat, double lng) {
    final distance = _calculateDistance(latitude, longitude, lat, lng);
    return distance <= radiusInMeters;
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const earthRadiusM = 6371000;
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = (math.sin(dLat / 2) * math.sin(dLat / 2)) +
        (math.cos(_toRad(lat1)) * math.cos(_toRad(lat2)) * math.sin(dLon / 2) * math.sin(dLon / 2));
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusM * c;
  }

  double _toRad(double degree) => degree * (math.pi / 180);
}
