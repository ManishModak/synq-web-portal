class MockDataService {
  static Map<String, dynamic> getPointsData() {
    return {
      "timestamp": "2024-01-15T12:30:45Z",
      "points": {
        "total": 15420,
        "daily": 245,
        "weekly": 1680,
        "monthly": 7250,
        "streak": 7,
        "rank": "Gold",
        "multiplier": "1.5x"
      },
      "syncLifePoints": 12500,
      "walletLifePoints": 8900,
      "walletBalance": 125.75,
      "source": "proxy",
      "containerUptime": "72h 15m",
      "isEarning": true,
      "connectionState": "connected"
    };
  }

  static Map<String, dynamic> getPerformanceData() {
    return {
      "timestamp": "2024-01-15T12:30:45Z",
      "performance": {
        "totalTraffic": 2457600,
        "sessions": 156,
        "users": 89,
        "demoSessions": 12,
        "bytesIn": 1024000,
        "bytesOut": 1433600,
        "proxyConnectionState": "active"
      },
      "qos": {
        "score": 85,
        "reliability": 92,
        "availability": 88,
        "efficiency": 90,
        "ratingsBlurbs": {
          "availability": "Excellent uptime performance",
          "reliability": "Stable connection maintained",
          "efficiency": "Optimal data throughput"
        }
      }
    };
  }

  static Map<String, dynamic> getSystemStatus() {
    return {
      "timestamp": "2024-01-15T12:30:45Z",
      "serviceStatus": "running",
      "dockerAvailable": true,
      "autoStart": true,
      "uptime": "72h 15m 30s",
      "containerRunning": true,
      "imageUpdates": {
        "available": 2,
        "lastChecked": "2024-01-15T10:00:00Z",
        "images": [
          {"name": "synqbox/proxy", "updateAvailable": true},
          {"name": "synqbox/monitor", "updateAvailable": true}
        ]
      }
      // Note: systemResources intentionally omitted - will only show when real API data is available
    };
  }

  static Map<String, dynamic> getSystemLogs() {
    return {
      "logs": [
        "2024-01-15 12:30:45 INFO: Proxy service started successfully",
        "2024-01-15 12:30:40 INFO: Docker container health check passed",
        "2024-01-15 12:30:35 WARN: High memory usage detected: 85%",
        "2024-01-15 12:30:30 INFO: New peer connection established",
        "2024-01-15 12:30:25 ERROR: Failed to connect to peer 192.168.1.100",
        "2024-01-15 12:30:20 INFO: Bandwidth test completed: 250 Mbps",
        "2024-01-15 12:30:15 INFO: System update check completed",
        "2024-01-15 12:30:10 INFO: Connection established with remote server",
        "2024-01-15 12:30:05 INFO: Authentication successful",
        "2024-01-15 12:30:00 INFO: SynqBox service initialized"
      ]
    };
  }

  static Map<String, dynamic> getHealthStatus() {
    return {
      "status": "healthy",
      "timestamp": "2024-01-15T12:30:45Z",
      "checks": {
        "docker": {"status": "healthy"},
        "service": {"status": "running"},
        "configuration": {"status": "valid"}
      }
    };
  }

  static Map<String, dynamic> getInstallUpdateResponse() {
    return {
      "success": true,
      "message": "Update installation started",
      "updateId": "upd_1642248645",
      "estimatedTime": "5-10 minutes"
    };
  }

  static Map<String, dynamic> getInstallWebServiceResponse() {
    return {
      "success": true,
      "message": "Web service installation completed",
      "serviceFile": "/etc/systemd/system/synqbox-web.service",
      "status": "enabled"
    };
  }

  static Map<String, dynamic> getConfiguration() {
    return {
      "dashboardPassword": "••••••••••",
      "proxyPort": 8080,
      "metricsPort": 3001,
      "autoUpdate": true,
      "logLevel": "INFO",
      "maxConnections": 100,
      "dataRetention": "30d",
      "apiKeys": {
        "monitoring": "••••••••••••••••",
        "analytics": "••••••••••••••••"
      }
    };
  }
}
