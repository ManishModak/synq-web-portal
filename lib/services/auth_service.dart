import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:synq/services/api_service.dart';

class AuthService {
  static String _dashboardPassword = '1234567899';
  static String _ipAddress = '192.168.31.107';
  static String? _cachedCredentials;

  // Generate Basic Auth credentials
  static String _generateBasicAuthCredentials(String password) {
    final credentials = ':$password';
    return base64Encode(utf8.encode(credentials));
  }

  // Get cached credentials or generate new ones
  static String getBasicAuthCredentials() {
    _cachedCredentials ??= _generateBasicAuthCredentials(_dashboardPassword);
    return _cachedCredentials!;
  }

  // Get authorization header
  static Map<String, String> getAuthHeaders() {
    return {
      'Authorization': 'Basic ${getBasicAuthCredentials()}',
      'Content-Type': 'application/json',
    };
  }

  // Validate credentials (for future use)
  static bool validateCredentials(String password) {
    return password == _dashboardPassword;
  }

  // Update password (for future use)
  static void updatePassword(String newPassword) {
    _dashboardPassword = newPassword;
    _cachedCredentials = _generateBasicAuthCredentials(newPassword);
  }

  // Update API endpoints
  static Future<void> updateApiEndpoints(String ipAddress) async {
    _ipAddress = ipAddress;
    // Update ApiService endpoints
    ApiService.updateEndpoints(ipAddress);
  }

  // Test connection to the APIs
  static Future<bool> testConnection() async {
    try {
      // Test connection using ApiService
      final result = await ApiService.testConnection();
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('Connection test failed: $e');
      }
      return false;
    }
  }

  // Get current IP address
  static String getIpAddress() => _ipAddress;
}
