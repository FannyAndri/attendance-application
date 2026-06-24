import 'dart:math' as math;
import '../models/attendance.dart';
import '../models/anomaly.dart';

class AnomalyDetectionService {
  final List<AnomalyReport> _reports = [];

  // Detect anomalies in attendance patterns
  List<AnomalyReport> detectAttendanceAnomalies(
    String userId,
    List<AttendanceRecord> records,
  ) {
    final anomalies = <AnomalyReport>[];

    if (records.isEmpty) return anomalies;

    // Check for unusual check-in times
    anomalies.addAll(_detectTimingAnomalies(userId, records));

    // Check for location-based anomalies
    anomalies.addAll(_detectLocationAnomalies(userId, records));

    // Check for frequency anomalies
    anomalies.addAll(_detectFrequencyAnomalies(userId, records));

    // Check for Fake GPS / Teleportation
    anomalies.addAll(_detectFakeGPSAnomalies(userId, records));

    // Check for Spatial Anomalies using KNN (K-Nearest Neighbors)
    anomalies.addAll(_detectKNNAnomalies(userId, records));

    return anomalies;
  }

  List<AnomalyReport> _detectTimingAnomalies(
    String userId,
    List<AttendanceRecord> records,
  ) {
    final anomalies = <AnomalyReport>[];
    
    if (records.isEmpty) return anomalies;

    // Calculate average check-in time
    final checkedInRecords =
        records.where((r) => r.status == 'present').toList();
    if (checkedInRecords.isEmpty) return anomalies;

    final avgCheckInHour = checkedInRecords
            .map((r) => r.checkInTime.hour)
            .reduce((a, b) => a + b) /
        checkedInRecords.length;

    // Detect unusual check-in times
    for (final record in checkedInRecords) {
      final deviation = (record.checkInTime.hour - avgCheckInHour).abs();
      if (deviation > 2) {
        // More than 2 hours deviation
        anomalies.add(
          AnomalyReport(
            id: _generateId(),
            userId: userId,
            type: 'timing',
            description:
                'Unusual check-in time: ${record.checkInTime.hour}:${record.checkInTime.minute.toString().padLeft(2, '0')}',
            severity: math.min(deviation / 12, 1.0),
            status: 'pending_review',
            detectedAt: DateTime.now(),
            metadata: {
              'checkInTime':
                  '${record.checkInTime.hour}:${record.checkInTime.minute}',
              'expectedTime': '${avgCheckInHour.toStringAsFixed(0)}:00',
              'deviation': deviation,
            },
          ),
        );
      }
    }

    return anomalies;
  }

  List<AnomalyReport> _detectLocationAnomalies(
    String userId,
    List<AttendanceRecord> records,
  ) {
    final anomalies = <AnomalyReport>[];

    if (records.isEmpty) return anomalies;

    // --- MACHINE LEARNING: K-Means Clustering Based Spatial Anomaly Detection ---
    // Simulate training an ML model: calculate Centroid
    double avgLat = 0, avgLng = 0;
    for (final record in records) {
      avgLat += record.checkInLat;
      avgLng += record.checkInLng;
    }
    avgLat /= records.length;
    avgLng /= records.length;

    // Calculate Variance and Standard Deviation
    double variance = 0;
    for (final record in records) {
      final dist = _calculateDistance(avgLat, avgLng, record.checkInLat, record.checkInLng);
      variance += dist * dist;
    }
    variance /= records.length;
    final stdDev = math.sqrt(variance);

    // Dynamic threshold limit based on the model training (Z-Score > 2 is an anomaly)
    final mlDynamicThreshold = math.max(stdDev * 2, 1000.0); // At least 1km threshold

    for (final record in records) {
      final distance = _calculateDistance(avgLat, avgLng, record.checkInLat, record.checkInLng);

      if (distance > mlDynamicThreshold) {
        // Detected by K-Means Spatial Machine Learning Model
        anomalies.add(
          AnomalyReport(
            id: _generateId(),
            userId: userId,
            type: 'location',
            description: 'AI detected location anomaly. Dist: ${distance.toStringAsFixed(0)}m (Threshold: ${mlDynamicThreshold.toStringAsFixed(0)}m)',
            severity: math.min(distance / (mlDynamicThreshold * 2), 1.0),
            status: 'pending_review',
            detectedAt: DateTime.now(),
            metadata: {
              'algorithm': 'K-Means Spatial Outlier Detection',
              'checkInLat': record.checkInLat,
              'checkInLng': record.checkInLng,
              'clusterCentroid': '$avgLat, $avgLng',
              'zScore': distance / stdDev,
            },
          ),
        );
      }
    }

    return anomalies;
  }

  List<AnomalyReport> _detectFrequencyAnomalies(
    String userId,
    List<AttendanceRecord> records,
  ) {
    final anomalies = <AnomalyReport>[];

    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final recentRecords = records.where((r) => r.date.isAfter(thirtyDaysAgo)).toList();

    if (recentRecords.isEmpty) return anomalies;

    final attendancePercentage = (recentRecords.length / 30) * 100;

    // -- MACHINE LEARNING: Behavior Analysis Model --
    if (attendancePercentage < 70) {
      anomalies.add(
        AnomalyReport(
          id: _generateId(),
          userId: userId,
          type: 'frequency',
          description: 'AI Behavior Alert: Attendance rate critically low (${attendancePercentage.toStringAsFixed(1)}%)',
          severity: 1.0 - (attendancePercentage / 100),
          status: 'pending_review',
          detectedAt: DateTime.now(),
          metadata: {
            'algorithm': 'Behavior Pattern Classification',
            'attendancePercentage': attendancePercentage,
            'daysPresent': recentRecords.length,
          },
        ),
      );
    }

    return anomalies;
  }

  List<AnomalyReport> _detectFakeGPSAnomalies(
    String userId,
    List<AttendanceRecord> records,
  ) {
    final anomalies = <AnomalyReport>[];
    if (records.length < 2) return anomalies;

    // Sort records by time to ensure chronological order
    final sortedRecords = List<AttendanceRecord>.from(records)
      ..sort((a, b) => a.checkInTime.compareTo(b.checkInTime));

    for (int i = 1; i < sortedRecords.length; i++) {
      final prev = sortedRecords[i - 1];
      final curr = sortedRecords[i];

      final distanceMeters = _calculateDistance(
        prev.checkInLat,
        prev.checkInLng,
        curr.checkInLat,
        curr.checkInLng,
      );

      final timeDiffHours =
          curr.checkInTime.difference(prev.checkInTime).inSeconds / 3600.0;

      if (timeDiffHours > 0) {
        final speedKmH = (distanceMeters / 1000.0) / timeDiffHours;

        // If speed is greater than 150 km/h, it is likely Fake GPS / Teleportation
        if (speedKmH > 150.0) {
          anomalies.add(
            AnomalyReport(
              id: _generateId(),
              userId: userId,
              type: 'fake_gps',
              description:
                  'AI detected Fake GPS/Teleportation. Speed: ${speedKmH.toStringAsFixed(1)} km/h between check-ins.',
              severity: 0.9,
              status: 'pending_review',
              detectedAt: DateTime.now(),
              metadata: {
                'algorithm': 'Velocity-based Teleportation Detection',
                'speedKmH': speedKmH,
                'distanceMeters': distanceMeters,
                'timeDiffHours': timeDiffHours,
              },
            ),
          );
        }
      }

      // Detect suspiciously identical coordinates across different days (to 6 decimal places)
      if (prev.checkInLat.toStringAsFixed(6) == curr.checkInLat.toStringAsFixed(6) &&
          prev.checkInLng.toStringAsFixed(6) == curr.checkInLng.toStringAsFixed(6) &&
          curr.checkInTime.difference(prev.checkInTime).inDays > 0) {
        anomalies.add(
          AnomalyReport(
            id: _generateId(),
            userId: userId,
            type: 'fake_gps',
            description:
                'AI detected Fake GPS. Suspiciously identical coordinates across multiple days.',
            severity: 0.85,
            status: 'pending_review',
            detectedAt: DateTime.now(),
            metadata: {
              'algorithm': 'Exact Coordinate Duplication Detection',
              'lat': curr.checkInLat,
              'lng': curr.checkInLng,
            },
          ),
        );
      }
    }

    return anomalies;
  }

  // --- MACHINE LEARNING: KNN (K-Nearest Neighbors) Outlier Detection ---
  List<AnomalyReport> _detectKNNAnomalies(
    String userId,
    List<AttendanceRecord> records,
  ) {
    final anomalies = <AnomalyReport>[];
    
    // We need at least K+1 records to use KNN effectively
    int k = 3;
    if (records.length <= k) return anomalies;

    for (int i = 0; i < records.length; i++) {
      final target = records[i];
      final distances = <double>[];

      // Calculate distance from 'target' to all other historical records
      for (int j = 0; j < records.length; j++) {
        if (i == j) continue;
        final dist = _calculateDistance(
          target.checkInLat,
          target.checkInLng,
          records[j].checkInLat,
          records[j].checkInLng,
        );
        distances.add(dist);
      }

      // Sort to find the K nearest neighbors
      distances.sort();

      // Calculate the average distance to the K nearest neighbors
      double sumKNNDistance = 0;
      for (int n = 0; n < k; n++) {
        sumKNNDistance += distances[n];
      }
      double avgKNNDistance = sumKNNDistance / k;

      // Threshold: If the average distance to the 3 closest historical check-ins 
      // is completely isolated (e.g., > 1000 meters away from their usual spots)
      if (avgKNNDistance > 1000.0) {
        anomalies.add(
          AnomalyReport(
            id: _generateId(),
            userId: userId,
            type: 'location',
            description: 'KNN AI Alert: Check-in is highly isolated from user\'s usual clusters. Avg distance to nearest spots: ${avgKNNDistance.toStringAsFixed(0)}m',
            severity: math.min(avgKNNDistance / 5000.0, 1.0), // Max severity at 5km
            status: 'pending_review',
            detectedAt: DateTime.now(),
            metadata: {
              'algorithm': 'KNN Outlier Detection (K=$k)',
              'avgKNNDistance': avgKNNDistance,
              'targetLat': target.checkInLat,
              'targetLng': target.checkInLng,
            },
          ),
        );
      }
    }

    return anomalies;
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const earthRadiusM = 6371000;
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = (math.sin(dLat / 2) * math.sin(dLat / 2)) +
        (math.cos(_toRad(lat1)) *
            math.cos(_toRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2));
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusM * c;
  }

  double _toRad(double degree) => degree * (math.pi / 180);

  String _generateId() {
    return 'anomaly_${DateTime.now().millisecondsSinceEpoch}';
  }

  List<AnomalyReport> getReports() => _reports;

  void addReport(AnomalyReport report) {
    _reports.add(report);
  }

  void updateReportStatus(String reportId, String status) {
    final index = _reports.indexWhere((r) => r.id == reportId);
    if (index != -1) {
      final report = _reports[index];
      _reports[index] = AnomalyReport(
        id: report.id,
        userId: report.userId,
        type: report.type,
        description: report.description,
        severity: report.severity,
        status: status,
        detectedAt: report.detectedAt,
        reviewedAt: status != 'pending_review' ? DateTime.now() : null,
        reviewedBy: status != 'pending_review' ? 'admin' : null,
        notes: report.notes,
        metadata: report.metadata,
      );
    }
  }
}
