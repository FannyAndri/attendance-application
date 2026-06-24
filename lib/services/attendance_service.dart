import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../models/attendance.dart';
import '../models/wfh_request.dart';
import 'api_constants.dart';

class Position {
  final double latitude;
  final double longitude;
  final double accuracy;

  Position({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
  });
}

/// Device / permission snapshot for UI (does not show a permission dialog).
enum LocationAvailability {
  /// GPS / location master switch off on the device.
  servicesDisabled,
  /// User chose "deny" (can still request again).
  permissionDenied,
  /// User chose "don't ask again" — must open app settings.
  permissionDeniedForever,
  /// Location services on and permission granted (whileInUse / always).
  allowed,
}

/// GPS via Geolocator (permissions + hardware). Used for check-in/out and live tracking.
class LocationService {
  Future<bool> isLocationServiceEnabled() => geo.Geolocator.isLocationServiceEnabled();

  Future<geo.LocationPermission> checkPermission() => geo.Geolocator.checkPermission();

  Future<geo.LocationPermission> requestPermission() => geo.Geolocator.requestPermission();

  Future<void> openAppLocationSettings() => geo.Geolocator.openAppSettings();

  Future<LocationAvailability> checkAvailability() async {
    final servicesOn = await geo.Geolocator.isLocationServiceEnabled();
    if (!servicesOn) return LocationAvailability.servicesDisabled;

    final perm = await geo.Geolocator.checkPermission();
    switch (perm) {
      case geo.LocationPermission.deniedForever:
        return LocationAvailability.permissionDeniedForever;
      case geo.LocationPermission.denied:
      case geo.LocationPermission.unableToDetermine:
        return LocationAvailability.permissionDenied;
      case geo.LocationPermission.always:
      case geo.LocationPermission.whileInUse:
        return LocationAvailability.allowed;
    }
  }

  /// Ensures we can read a fix; throws with a clear message if blocked.
  Future<void> ensureReadyForFix() async {
    final serviceOn = await geo.Geolocator.isLocationServiceEnabled();
    if (!serviceOn) {
      throw Exception(
        'Location services are turned off. Enable GPS/location in device settings.',
      );
    }
    var permission = await geo.Geolocator.checkPermission();
    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
    }
    if (permission == geo.LocationPermission.denied) {
      throw Exception('Location permission denied. Allow location access for this app.');
    }
    if (permission == geo.LocationPermission.deniedForever) {
      throw Exception(
        'Location permission permanently denied. Enable it in system app settings.',
      );
    }
  }

  Future<Position?> getCurrentLocation() async {
    try {
      await ensureReadyForFix();
      final pos = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
        timeLimit: const Duration(seconds: 20),
      );
      return Position(
        latitude: pos.latitude,
        longitude: pos.longitude,
        accuracy: pos.accuracy,
      );
    } catch (e) {
      debugPrint('Error getting current location: $e');
      return null;
    }
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const earthRadiusKm = 6371;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan(sqrt(a / (1 - a)));
    return earthRadiusKm * c * 1000;
  }

  double _toRadians(double degrees) => degrees * pi / 180;

  void dispose() {}
}

class AttendanceService {
  final LocationService _locationService;
  String? _currentAttendanceId;
  Timer? _trackingTimer;

  /// Called when a track is stored successfully so UI can update without waiting for history refresh.
  void Function(LocationTrack track)? onLocationTracked;

  static const double officeLat = -6.200000;
  static const double officeLng = 106.816666;
  static const double maxRadiusMeters = 300.0;

  AttendanceService(this._locationService);

  /// After app restart while still checked in, resume sending tracks.
  void restoreSession(String attendanceId, {Duration interval = const Duration(seconds: 45)}) {
    _currentAttendanceId = attendanceId;
    startLocationTracking(updateInterval: interval);
  }

  void startLocationTracking({Duration updateInterval = const Duration(seconds: 45)}) {
    _trackingTimer?.cancel();
    _trackingTimer = Timer.periodic(updateInterval, (_) {
      unawaited(_trackingTick());
    });
    debugPrint('Location tracking started');
  }

  Future<void> _trackingTick() async {
    if (_currentAttendanceId == null) return;
    final position = await _locationService.getCurrentLocation();
    if (position == null) return;
    await addLocationTrack(position.latitude, position.longitude, position.accuracy);
  }

  Future<void> stopLocationTracking() async {
    _trackingTimer?.cancel();
    _trackingTimer = null;
    debugPrint('Location tracking stopped');
  }

  Future<AttendanceRecord?> checkIn(String userId, Geofence? geofence) async {
    Position? position;
    try {
      position = await _locationService.getCurrentLocation();
    } catch (e) {
      throw Exception('$e');
    }
    if (position == null) {
      throw Exception(
        'Could not read GPS. Enable location services and grant permission to this app.',
      );
    }

    final distance = _locationService.calculateDistance(
      officeLat,
      officeLng,
      position.latitude,
      position.longitude,
    );

    if (distance > maxRadiusMeters) {
      throw Exception(
        'Lokasi Anda berada ${distance.toStringAsFixed(1)} meter dari kantor. '
        'Batas maksimal absensi adalah $maxRadiusMeters meter dari area kantor.',
      );
    }

    final url = Uri.parse('${ApiConstants.baseUrl}/attendance/checkin');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'isWFH': false,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final record = AttendanceRecord.fromJson(_mapData(Map<String, dynamic>.from(data['record'] as Map)));
      _currentAttendanceId = record.id;
      startLocationTracking();
      return record;
    } else {
      throw Exception('Check-in gagal: ${response.body}');
    }
  }

  Future<AttendanceRecord?> checkOut(String userId) async {
    try {
      final position = await _locationService.getCurrentLocation();
      if (position == null) return null;

      final url = Uri.parse('${ApiConstants.baseUrl}/attendance/checkout');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'latitude': position.latitude,
          'longitude': position.longitude,
        }),
      );

      if (response.statusCode == 200) {
        await stopLocationTracking();
        _currentAttendanceId = null;

        final records = await getRecords(userId);
        return records.isNotEmpty ? records.first : null;
      }
      return null;
    } catch (e) {
      debugPrint('Check-out error: $e');
      return null;
    }
  }

  Future<void> addLocationTrack(double lat, double lng, double accuracy) async {
    if (_currentAttendanceId == null) return;

    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/attendance/track');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'attendanceId': _currentAttendanceId,
          'latitude': lat,
          'longitude': lng,
          'accuracy': accuracy,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final track = LocationTrack(
          id: const Uuid().v4(),
          attendanceId: _currentAttendanceId!,
          timestamp: DateTime.now(),
          latitude: lat,
          longitude: lng,
          accuracy: accuracy,
        );
        onLocationTracked?.call(track);
      }
    } catch (e) {
      debugPrint('Failed to send location track: $e');
    }
  }

  Future<List<AttendanceRecord>> getRecords(String userId) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/attendance/history/$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => AttendanceRecord.fromJson(_mapData(Map<String, dynamic>.from(e as Map)))).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Get records error: $e');
      return [];
    }
  }

  Future<bool> submitRequest(String userId, String type, String date) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/attendance/request');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'type': type,
          'date': date,
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      debugPrint('Failed to submit request: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getMyRequests(String userId) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/attendance/requests/$userId');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      debugPrint('Failed to get requests: $e');
      return [];
    }
  }

  Future<AttendanceRecord?> getTodayRecord(String userId) async {
    try {
      final records = await getRecords(userId);
      final today = DateTime.now();

      for (final r in records) {
        if (r.date.year == today.year && r.date.month == today.month && r.date.day == today.day) {
          return r;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Get today record error: $e');
      return null;
    }
  }

  Map<String, dynamic> _mapData(Map<String, dynamic> data) {
    if (data['isWFH'] is int) {
      data['isWFH'] = data['isWFH'] == 1;
    }
    return data;
  }
}
