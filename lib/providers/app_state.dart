import 'package:flutter/material.dart';
import '../models/attendance.dart';
import '../models/anomaly.dart';
import '../models/user.dart';
import '../models/wfh_request.dart';
import '../services/auth_service.dart';
import '../services/attendance_service.dart';
import '../services/anomaly_detection_service.dart';

class AppState extends ChangeNotifier {
  final AuthService _authService;
  final AttendanceService _attendanceService;
  final AnomalyDetectionService _anomalyService;

  User? _currentUser;
  List<AttendanceRecord> _attendanceRecords = [];
  List<AnomalyReport> _anomalyReports = [];
  AttendanceRecord? _todayRecord;

  AppState({
    required AuthService authService,
    required AttendanceService attendanceService,
    required AnomalyDetectionService anomalyService,
  })  : _authService = authService,
        _attendanceService = attendanceService,
        _anomalyService = anomalyService {
    _attendanceService.onLocationTracked = _onLocationTracked;
  }

  void _onLocationTracked(LocationTrack track) {
    final today = _todayRecord;
    if (today != null && track.attendanceId == today.id) {
      _todayRecord = today.copyWith(
        locationTracks: [...today.locationTracks, track],
      );
      notifyListeners();
    }
  }

  // Getters
  User? get currentUser => _currentUser;
  List<AttendanceRecord> get attendanceRecords => _attendanceRecords;
  List<AnomalyReport> get anomalyReports => _anomalyReports;
  AttendanceRecord? get todayRecord => _todayRecord;
  AttendanceService get attendanceService => _attendanceService;

  // Check if user is checked in
  bool get isCheckedIn => _todayRecord != null && _todayRecord!.checkOutTime == null;

  // Get today's duration
  String get todayDuration {
    if (_todayRecord == null) return 'Not started';
    return _todayRecord!.getFormattedDuration();
  }

  // Initialize user data
  Future<void> initializeUser() async {
    final email = await _authService.getEmail();
    final name = await _authService.getName();
    final userId = await _authService.getUserId();
    final department = await _authService.getDepartment();
    final role = await _authService.getRole();

    if (email != null && name != null && userId != null) {
      final dept = department?.trim();
      final roleStr = role?.trim();
      _currentUser = User(
        id: userId,
        email: email,
        name: name,
        department: (dept != null && dept.isNotEmpty) ? dept : '',
        role: (roleStr != null && roleStr.isNotEmpty) ? roleStr : 'employee',
        isActive: true,
      );
      await _loadUserData();
      await _resumeTrackingIfNeeded();
    }
  }

  Future<void> _resumeTrackingIfNeeded() async {
    final record = _todayRecord;
    if (record != null && record.checkOutTime == null) {
      _attendanceService.restoreSession(record.id);
    }
  }

  // Load user attendance and anomaly data
  Future<void> _loadUserData() async {
    if (_currentUser == null) return;
    _attendanceRecords = await _attendanceService.getRecords(_currentUser!.id);
    _todayRecord = await _attendanceService.getTodayRecord(_currentUser!.id);
    _refreshAnomalies();
    notifyListeners();
  }

  // Perform check-in
  Future<bool> performCheckIn(Geofence? geofence) async {
    if (_currentUser == null) return false;

    try {
      final record = await _attendanceService.checkIn(_currentUser!.id, geofence);
      if (record != null) {
        _todayRecord = record;
        _attendanceRecords.add(record);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      // Re-throw so UI can handle the error message (e.g. 3m radius limit)
      rethrow;
    }
  }

  // Perform check-out
  Future<bool> performCheckOut() async {
    if (_currentUser == null || _todayRecord == null) return false;

    final record = await _attendanceService.checkOut(_currentUser!.id);
    if (record != null) {
      _todayRecord = record;
      final index = _attendanceRecords.indexWhere((r) => r.id == record.id);
      if (index != -1) {
        _attendanceRecords[index] = record;
      }
      _refreshAnomalies();
      notifyListeners();
      return true;
    }
    return false;
  }

  // Add location track
  void addLocationTrack(double lat, double lng, double accuracy) {
    _attendanceService.addLocationTrack(lat, lng, accuracy);
  }

  // Refresh anomalies
  void _refreshAnomalies() {
    if (_currentUser == null) return;
    _anomalyReports = _anomalyService.detectAttendanceAnomalies(
      _currentUser!.id,
      _attendanceRecords,
    );
  }

  // Logout
  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    _attendanceRecords = [];
    _anomalyReports = [];
    _todayRecord = null;
    notifyListeners();
  }
}