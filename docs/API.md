# 🔌 API Integration Documentation

This document outlines the API integration capabilities of my SynqBox Portal, including the expected API structure, authentication methods, and data models that the portal is designed to work with.

## 🌐 **API Architecture Overview**

### **Base Configuration**
```dart
class ApiConfig {
  static const String baseUrl = 'https://api.synqbox.com/v1';
  static const Duration timeout = Duration(seconds: 30);
  static const String contentType = 'application/json';
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'SynqBox-Portal/1.0',
  };
}
```

### **Authentication**
```dart
class AuthService {
  static Future<String> authenticate(String apiKey) async {
    // Token-based authentication
    final response = await ApiClient.post('/auth/token', {
      'api_key': apiKey,
    });
    
    return response.data['access_token'];
  }
  
  static Future<void> refreshToken() async {
    // Automatic token refresh
    // Implementation for token renewal
  }
}
```

---

## 📊 **Data Models**

### **Points Data Model**
```dart
class PointsData {
  final int points;
  final int dailyEarnings;
  final int weeklyEarnings;
  final int monthlyEarnings;
  final String connectionStatus;
  final DateTime lastUpdate;
  final Map<String, dynamic> metadata;

  PointsData({
    required this.points,
    required this.dailyEarnings,
    required this.weeklyEarnings,
    required this.monthlyEarnings,
    required this.connectionStatus,
    required this.lastUpdate,
    required this.metadata,
  });

  factory PointsData.fromJson(Map<String, dynamic> json) {
    return PointsData(
      points: json['points'] ?? 0,
      dailyEarnings: json['daily_earnings'] ?? 0,
      weeklyEarnings: json['weekly_earnings'] ?? 0,
      monthlyEarnings: json['monthly_earnings'] ?? 0,
      connectionStatus: json['connection_status'] ?? 'unknown',
      lastUpdate: DateTime.parse(json['last_update']),
      metadata: json['metadata'] ?? {},
    );
  }
}
```

### **Performance Data Model**
```dart
class PerformanceData {
  final QoSMetrics qos;
  final TrafficMetrics traffic;
  final ConnectionMetrics connection;
  final DateTime timestamp;

  PerformanceData({
    required this.qos,
    required this.traffic,
    required this.connection,
    required this.timestamp,
  });

  factory PerformanceData.fromJson(Map<String, dynamic> json) {
    return PerformanceData(
      qos: QoSMetrics.fromJson(json['qos']),
      traffic: TrafficMetrics.fromJson(json['traffic']),
      connection: ConnectionMetrics.fromJson(json['connection']),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class QoSMetrics {
  final int score;
  final int reliability;
  final int availability;
  final int efficiency;
  final Map<String, String> ratingsBlurbs;

  QoSMetrics({
    required this.score,
    required this.reliability,
    required this.availability,
    required this.efficiency,
    required this.ratingsBlurbs,
  });

  factory QoSMetrics.fromJson(Map<String, dynamic> json) {
    return QoSMetrics(
      score: json['score'] ?? 0,
      reliability: json['reliability'] ?? 0,
      availability: json['availability'] ?? 0,
      efficiency: json['efficiency'] ?? 0,
      ratingsBlurbs: Map<String, String>.from(json['ratings_blurbs'] ?? {}),
    );
  }
}
```

---

## 🔄 **API Endpoints**

### **Points API**
```dart
class PointsAPI {
  // Get current points data
  static Future<ApiResponse<PointsData>> getPoints() async {
    final response = await ApiClient.get('/points');
    return ApiResponse.success(PointsData.fromJson(response.data));
  }

  // Get points history
  static Future<ApiResponse<List<PointsData>>> getPointsHistory({
    DateTime? startDate,
    DateTime? endDate,
    String? granularity = 'day',
  }) async {
    final queryParams = {
      if (startDate != null) 'start_date': startDate.toIso8601String(),
      if (endDate != null) 'end_date': endDate.toIso8601String(),
      'granularity': granularity,
    };
    
    final response = await ApiClient.get('/points/history', queryParameters: queryParams);
    final List<dynamic> data = response.data['data'];
    return ApiResponse.success(data.map((json) => PointsData.fromJson(json)).toList());
  }

  // Refresh points data
  static Future<ApiResponse<PointsData>> refreshPoints() async {
    final response = await ApiClient.post('/points/refresh');
    return ApiResponse.success(PointsData.fromJson(response.data));
  }
}
```

### **Performance API**
```dart
class PerformanceAPI {
  // Get current performance metrics
  static Future<ApiResponse<PerformanceData>> getPerformance() async {
    final response = await ApiClient.get('/performance');
    return ApiResponse.success(PerformanceData.fromJson(response.data));
  }

  // Get performance history
  static Future<ApiResponse<List<PerformanceData>>> getPerformanceHistory({
    DateTime? startDate,
    DateTime? endDate,
    String? metric,
  }) async {
    final queryParams = {
      if (startDate != null) 'start_date': startDate.toIso8601String(),
      if (endDate != null) 'end_date': endDate.toIso8601String(),
      if (metric != null) 'metric': metric,
    };
    
    final response = await ApiClient.get('/performance/history', queryParameters: queryParams);
    final List<dynamic> data = response.data['data'];
    return ApiResponse.success(data.map((json) => PerformanceData.fromJson(json)).toList());
  }
}
```

---

## 🧪 **Mock Data System**

### **Mock Data Provider**
```dart
class MockDataProvider {
  static const bool _enableMockData = true;
  
  static Future<PointsData> getMockPoints() async {
    // Simulate API delay
    await Future.delayed(Duration(milliseconds: 500));
    
    return PointsData(
      points: 12847,
      dailyEarnings: 156,
      weeklyEarnings: 1092,
      monthlyEarnings: 4672,
      connectionStatus: 'connected',
      lastUpdate: DateTime.now(),
      metadata: {
        'device_id': 'synqbox_001',
        'firmware_version': '1.2.3',
        'uptime': '7d 14h 23m',
      },
    );
  }
  
  static Future<PerformanceData> getMockPerformance() async {
    await Future.delayed(Duration(milliseconds: 750));
    
    return PerformanceData(
      qos: QoSMetrics(
        score: 87,
        reliability: 92,
        availability: 89,
        efficiency: 81,
        ratingsBlurbs: {
          'reliability': 'Excellent connection stability',
          'availability': 'High uptime with minimal interruptions',
          'efficiency': 'Good performance with room for optimization',
        },
      ),
      traffic: TrafficMetrics.mock(),
      connection: ConnectionMetrics.mock(),
      timestamp: DateTime.now(),
    );
  }
}
```

---

## 🔄 **Real-Time Updates**

### **Polling Strategy (Current)**
```dart
class PollingService {
  static Timer? _pointsTimer;
  static Timer? _performanceTimer;
  
  static void startPolling() {
    // Poll points every 30 seconds
    _pointsTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      _refreshPoints();
    });
    
    // Poll performance every 60 seconds
    _performanceTimer = Timer.periodic(Duration(seconds: 60), (timer) {
      _refreshPerformance();
    });
  }
  
  static void stopPolling() {
    _pointsTimer?.cancel();
    _performanceTimer?.cancel();
  }
}
```

### **WebSocket Integration (Future)**
```dart
class WebSocketService {
  static const String wsUrl = 'wss://api.synqbox.com/ws';
  static IOWebSocketChannel? _channel;
  
  static Future<void> connect() async {
    _channel = IOWebSocketChannel.connect(wsUrl);
    
    _channel!.stream.listen(
      (message) {
        final data = jsonDecode(message);
        _handleWebSocketMessage(data);
      },
      onError: (error) {
        print('WebSocket error: $error');
      },
      onDone: () {
        print('WebSocket connection closed');
      },
    );
  }
  
  static void _handleWebSocketMessage(Map<String, dynamic> data) {
    switch (data['type']) {
      case 'points_update':
        // Handle real-time points update
        break;
      case 'performance_update':
        // Handle real-time performance update
        break;
      case 'log_entry':
        // Handle real-time log entry
        break;
    }
  }
}
```

---

## 📈 **Response Handling**

### **API Response Model**
```dart
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final int? statusCode;
  final Map<String, dynamic>? metadata;

  ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.statusCode,
    this.metadata,
  });

  factory ApiResponse.success(T data) {
    return ApiResponse(
      success: true,
      data: data,
    );
  }

  factory ApiResponse.error(String error, [int? statusCode]) {
    return ApiResponse(
      success: false,
      error: error,
      statusCode: statusCode,
    );
  }
}
```

---

## 🚀 **Integration Roadmap**

### **Phase 1: Basic Integration**
- ✅ HTTP client setup with proper configuration
- ✅ Authentication system with API key support
- ✅ Data models for all API responses
- ✅ Error handling with user-friendly messages
- ✅ Mock data system for development

### **Phase 2: Advanced Features**
- [ ] WebSocket integration for real-time updates
- [ ] Automatic token refresh mechanism
- [ ] Request caching for improved performance
- [ ] Offline support with data persistence
- [ ] Background sync capabilities

### **Phase 3: Enterprise Features**
- [ ] Multi-device API support
- [ ] Advanced authentication (OAuth, SSO)
- [ ] API rate limiting and throttling
- [ ] Comprehensive logging and monitoring
- [ ] API versioning support

---

## 🔧 **Configuration**

### **Environment Variables**
```env
# API Configuration
API_BASE_URL=https://api.synqbox.com/v1
API_KEY=your_api_key_here
API_TIMEOUT=30000

# Feature Flags
ENABLE_MOCK_DATA=true
ENABLE_WEBSOCKET=false
ENABLE_CACHING=true

# Polling Intervals
POINTS_REFRESH_INTERVAL=30000
PERFORMANCE_REFRESH_INTERVAL=60000
LOGS_REFRESH_INTERVAL=10000
```

---

*This API documentation demonstrates the portal's readiness for real SynqBox integration while providing a robust mock data system for development and demonstration purposes.* 