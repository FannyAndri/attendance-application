import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_constants.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _emailKey = 'user_email';
  static const String _nameKey = 'user_name';
  static const String _departmentKey = 'user_department';
  static const String _roleKey = 'user_role';

  Future<bool> login(String email, String password) async {
    try {
      if (email.isEmpty || password.isEmpty) return false;

      final url = Uri.parse('${ApiConstants.baseUrl}/auth/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString(_tokenKey, data['token'] as String);
        await prefs.setString(_userIdKey, data['userId'] as String);
        await prefs.setString(_emailKey, data['email'] as String);
        await prefs.setString(_nameKey, data['name'] as String);

        final dept = data['department'] as String?;
        if (dept != null && dept.isNotEmpty) {
          await prefs.setString(_departmentKey, dept);
        }
        final role = data['role'] as String?;
        if (role != null && role.isNotEmpty) {
          await prefs.setString(_roleKey, role);
        }

        return true;
      } else {
        debugPrint('Login failed: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userIdKey);
      await prefs.remove(_emailKey);
      await prefs.remove(_nameKey);
      await prefs.remove(_departmentKey);
      await prefs.remove(_roleKey);
      return true;
    } catch (e) {
      debugPrint('Logout error: $e');
      return false;
    }
  }

  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      return null;
    }
  }

  Future<String?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userIdKey);
    } catch (e) {
      return null;
    }
  }

  Future<String?> getEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_emailKey);
    } catch (e) {
      return null;
    }
  }

  Future<String?> getName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_nameKey);
    } catch (e) {
      return null;
    }
  }

  Future<String?> getDepartment() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_departmentKey);
    } catch (e) {
      return null;
    }
  }

  Future<String?> getRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_roleKey);
    } catch (e) {
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> register(
    String email,
    String password,
    String name,
    String department,
  ) async {
    try {
      if (email.isEmpty || password.length < 6 || name.isEmpty) {
        throw Exception('Invalid input');
      }

      final url = Uri.parse('${ApiConstants.baseUrl}/auth/register');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
          'department': department,
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Registration failed: ${response.body}');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_departmentKey, department);
      await prefs.setString(_roleKey, prefs.getString(_roleKey) ?? 'employee');
    } catch (e) {
      debugPrint('Registration error: $e');
      rethrow;
    }
  }
}
