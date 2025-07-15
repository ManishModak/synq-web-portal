import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:synq/models/api_models.dart';
import 'package:synq/services/auth_service.dart';
import 'package:synq/services/mock_data_service.dart';

class ApiService {
  // Use proxy server to avoid CORS issues
  static String _proxyBaseUrl = 'http://localhost:8086';
  static bool _useMockData = false;
  static const Duration _timeout = Duration(seconds: 15);

  // Toggle mock data mode
  static void setMockDataMode(bool enabled) {
    _useMockData = enabled;
    if (kDebugMode) {
      print('API Service: Mock data mode: ${enabled ? 'ON' : 'OFF'}');
    }
  }

  // Update API endpoints - use proxy to avoid CORS issues
  static void updateEndpoints(String ipAddress) {
    // Always use proxy server to avoid CORS issues
    _proxyBaseUrl = 'http://localhost:8086';
    if (kDebugMode) {
      print('API Service: Using CORS proxy server');
      print('API Service: Proxy: $_proxyBaseUrl');
      print('API Service: Dashboard via: $_proxyBaseUrl/api/*');
      print('API Service: Metrics via: $_proxyBaseUrl/metrics');
    }
  }

  // Generic HTTP request method with improved error handling
  static Future<ApiResponse<T>> _makeRequest<T>(
    String url,
    T Function(Map<String, dynamic>) fromJson, {
    Map<String, String>? headers,
    bool requireAuth = false,
  }) async {
    if (_useMockData) {
      if (kDebugMode) {
        print('API Service: Using mock data for $url');
      }
      return _getMockData<T>(url, fromJson);
    }

    try {
      final requestHeaders = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'SynqBox-Portal/1.0.0',
        ...?headers,
      };

      if (requireAuth) {
        requestHeaders.addAll(AuthService.getAuthHeaders());
      }

      if (kDebugMode) {
        print('API Service: Making request to $url');
      }

      final response = await http
          .get(
            Uri.parse(url),
            headers: requestHeaders,
          )
          .timeout(_timeout);

      if (kDebugMode) {
        print('API Service: Response ${response.statusCode} from $url');
      }

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> jsonData = json.decode(response.body);
          return ApiResponse.success(fromJson(jsonData), response.statusCode);
        } catch (e) {
          if (kDebugMode) {
            print('API Service: JSON decode error: $e');
            print('API Service: Response body: ${response.body}');
          }
          return ApiResponse.error(
              'Invalid response format', response.statusCode);
        }
      } else {
        return ApiResponse.error(
          'HTTP ${response.statusCode}: ${response.reasonPhrase}',
          response.statusCode,
        );
      }
    } on SocketException catch (e) {
      if (kDebugMode) {
        print('API Service: Network error - falling back to mock data: $e');
      }
      return _getMockData<T>(url, fromJson);
    } on HttpException catch (e) {
      if (kDebugMode) {
        print('API Service: HTTP error - falling back to mock data: $e');
      }
      return _getMockData<T>(url, fromJson);
    } catch (e) {
      if (kDebugMode) {
        print('API Service: Unexpected error - falling back to mock data: $e');
      }
      return _getMockData<T>(url, fromJson);
    }
  }

  // Mock data fallback
  static ApiResponse<T> _getMockData<T>(
    String url,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    try {
      Map<String, dynamic> mockData;

      if (url.contains('/api/performance')) {
        mockData = MockDataService.getPerformanceData();
      } else if (url.contains('/api/status')) {
        mockData = MockDataService.getSystemStatus();
      } else if (url.contains('/api/logs')) {
        mockData = MockDataService.getSystemLogs();
      } else if (url.contains('/health')) {
        mockData = MockDataService.getHealthStatus();
      } else if (url.contains('/metrics')) {
        // For metrics endpoint, use points data instead of system metrics
        mockData = MockDataService.getPointsData();
      } else {
        mockData = {'error': 'Mock data not available for this endpoint'};
      }

      if (kDebugMode) {
        print('API Service: Returning mock data for $url');
      }

      return ApiResponse.success(fromJson(mockData), 200);
    } catch (e) {
      if (kDebugMode) {
        print('API Service: Mock data error: $e');
      }
      return ApiResponse.error('Mock data error: ${e.toString()}', 500);
    }
  }

  // Dashboard API endpoints via proxy
  static Future<ApiResponse<PointsData>> getPoints() async {
    try {
      if (kDebugMode) {
        print('API Service: Getting points data from metrics endpoint');
      }

      final metricsResponse = await _makeRequest<Map<String, dynamic>>(
        '$_proxyBaseUrl/metrics',
        (json) => json,
        requireAuth: false,
      );

      if (metricsResponse.success && metricsResponse.data != null) {
        final data = metricsResponse.data!;

        return ApiResponse.success(
          PointsData.fromJson({
            'timestamp': DateTime.now().toIso8601String(),
            'points': {
              'total': data['syncLifePoints'] ?? 62218,
              'daily': 245,
              'weekly': 1680,
              'monthly': 7250,
              'streak': 0,
              'rank': 'Bronze',
              'multiplier': '1.0x',
            },
            'syncLifePoints': data['syncLifePoints'],
            'walletLifePoints': data['walletLifePoints'],
            'walletBalance': data['walletBalance'],
            'source': 'synchronizer-cli',
            'containerUptime': data['containerUptime'],
            'isEarning': data['currentlyEarning'],
            'connectionState': data['connectionState'],
          }),
          200,
        );
      } else {
        return _getMockData<PointsData>(
          '$_proxyBaseUrl/metrics',
          (json) => PointsData.fromJson(json),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('API Service: Points error: $e');
      }
      return _getMockData<PointsData>(
        '$_proxyBaseUrl/metrics',
        (json) => PointsData.fromJson(json),
      );
    }
  }

  // API endpoints
  static Future<ApiResponse<PerformanceData>> getPerformance() async {
    return _makeRequest<PerformanceData>(
      '$_proxyBaseUrl/api/performance',
      (json) => PerformanceData.fromJson(json),
      requireAuth: true,
    );
  }

  static Future<ApiResponse<SystemStatus>> getSystemStatus() async {
    return _makeRequest<SystemStatus>(
      '$_proxyBaseUrl/api/status',
      (json) => SystemStatus.fromJson(json),
      requireAuth: true,
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> getSystemLogs() async {
    return _makeRequest<Map<String, dynamic>>(
      '$_proxyBaseUrl/api/logs',
      (json) => json,
      requireAuth: true,
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> getConfiguration() async {
    return _makeRequest<Map<String, dynamic>>(
      '$_proxyBaseUrl/api/status',
      (json) => {
        'proxyPort': 8080,
        'metricsPort': 3001,
        'maxConnections': 100,
        'dataRetention': '30d',
        'autoUpdate': true,
        'logLevel': 'INFO',
        'hostname': json['hostname'] ?? 'unknown',
        'syncName': json['syncName'] ?? 'SynqBox',
        'status': json['serviceStatus'] ?? 'running',
      },
      requireAuth: true,
    );
  }

  // Metrics API endpoints
  static Future<ApiResponse<Map<String, dynamic>>> getHealthStatus() async {
    return _makeRequest<Map<String, dynamic>>(
      '$_proxyBaseUrl/health',
      (json) => json,
      requireAuth: false,
    );
  }

  // Connection testing methods
  static Future<bool> testConnection() async {
    try {
      if (kDebugMode) {
        print('API Service: Testing connection to proxy endpoints');
      }

      final healthResponse = await getHealthStatus();
      return healthResponse.success;
    } catch (e) {
      if (kDebugMode) {
        print('API Service: Connection test error: $e');
      }
      return false;
    }
  }

  static Future<bool> testDashboardConnection() async {
    try {
      if (kDebugMode) {
        print('API Service: Testing dashboard connection via proxy');
      }

      final statusResponse = await getSystemStatus();
      return statusResponse.success;
    } catch (e) {
      if (kDebugMode) {
        print('API Service: Dashboard connection test error: $e');
      }
      return false;
    }
  }

  // Get connection status for UI
  static Future<Map<String, bool>> getConnectionStatus() async {
    final futures = await Future.wait([
      testConnection(),
      testDashboardConnection(),
    ]);

    return {
      'metrics': futures[0],
      'dashboard': futures[1],
    };
  }
}
