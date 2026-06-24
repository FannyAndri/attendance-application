import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_constants.dart';

class AdminService {
  final String baseUrl = '${ApiConstants.baseUrl}/admin';

  Future<List<dynamic>> getAllUsers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching users: $e');
      return [];
    }
  }

  Future<List<dynamic>> getAllAttendance() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/attendance'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching attendance: $e');
      return [];
    }
  }

  Future<List<dynamic>> getAllRequests() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/requests'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching requests: $e');
      return [];
    }
  }

  Future<bool> updateRequestStatus(String id, String status) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/requests/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': status}),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error updating request: $e');
      return false;
    }
  }

  Future<Map<String, double>> getOfficeLocation() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/settings/office'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'lat': data['office_lat'] ?? -6.200000,
          'lng': data['office_lng'] ?? 106.816666,
        };
      }
    } catch (e) {
      debugPrint('Error fetching office location: $e');
    }
    return {'lat': -6.200000, 'lng': 106.816666};
  }

  Future<bool> updateOfficeLocation(double lat, double lng) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/settings/office'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'lat': lat, 'lng': lng}),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error updating office location: $e');
      return false;
    }
  }
}
