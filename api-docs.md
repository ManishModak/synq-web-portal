# SynqBox Portal API Documentation

## 🌐 API Overview

The SynqBox Portal uses two separate APIs:
- **Dashboard API** (Port 3000) - Requires Basic Authentication
- **Metrics API** (Port 3001) - No Authentication Required

---

## 🔐 Authentication

### Dashboard API Authentication
```
Authorization: Basic <base64_encoded_credentials>
```
**Credentials Format**: `:<password>`
**Example**: `Authorization: Basic OjEyMzQ1Njc4OTk=`

---

## 📊 Dashboard API (Port 3000)

### Base URL
```
http://localhost:3000
```

---

### 1. Get Points Data

**Request:**
```http
GET /api/points
Authorization: Basic <credentials>
Content-Type: application/json
```

**Response:**
```json
{
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
}
```

---

### 2. Get Performance Data

**Request:**
```http
GET /api/performance
Authorization: Basic <credentials>
Content-Type: application/json
```

**Response:**
```json
{
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
}
```

---

### 3. Get System Status

**Request:**
```http
GET /api/status
Authorization: Basic <credentials>
Content-Type: application/json
```

**Response:**
```json
{
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
      {
        "name": "synqbox/proxy",
        "updateAvailable": true
      },
      {
        "name": "synqbox/monitor",
        "updateAvailable": true
      }
    ]
  }
}
```

---

### 4. Get System Logs

**Request:**
```http
GET /api/logs
Authorization: Basic <credentials>
Content-Type: application/json
```

**Response:**
```json
{
  "logs": [
    "2024-01-15 12:30:45 INFO: Proxy service started successfully",
    "2024-01-15 12:30:40 INFO: Docker container health check passed",
    "2024-01-15 12:30:35 WARN: High memory usage detected: 85%",
    "2024-01-15 12:30:30 INFO: New peer connection established",
    "2024-01-15 12:30:25 ERROR: Failed to connect to peer 192.168.1.100",
    "2024-01-15 12:30:20 INFO: Bandwidth test completed: 250 Mbps"
  ]
}
```

---

### 5. Get Configuration

**Request:**
```http
GET /api/config
Authorization: Basic <credentials>
Content-Type: application/json
```

**Response:**
```json
{
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
}
```

---

### 6. Install System Update

**Request:**
```http
POST /api/install-update
Authorization: Basic <credentials>
Content-Type: application/json
```

**Response:**
```json
{
  "success": true,
  "message": "Update installation started",
  "updateId": "upd_1642248645",
  "estimatedTime": "5-10 minutes"
}
```

---

### 7. Install Web Service

**Request:**
```http
POST /api/install-web-service
Authorization: Basic <credentials>
Content-Type: application/json
```

**Response:**
```json
{
  "success": true,
  "message": "Web service installation completed",
  "serviceFile": "/etc/systemd/system/synqbox-web.service",
  "status": "enabled"
}
```

---

## 📈 Metrics API (Port 3001)

### Base URL
```
http://localhost:3001
```

---

### 1. Get Health Status

**Request:**
```http
GET /health
Content-Type: application/json
```

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2024-01-15T12:30:45Z",
  "checks": {
    "docker": {
      "status": "healthy"
    },
    "service": {
      "status": "running"
    },
    "configuration": {
      "status": "valid"
    }
  }
}
```

---

### 2. Get Metrics Data

**Request:**
```http
GET /metrics
Content-Type: application/json
```

**Response:**
```json
{
  "timestamp": "2024-01-15T12:30:45Z",
  "system": {
    "cpu": 45.2,
    "memory": 68.5,
    "disk": 72.1,
    "network": {
      "rx_bytes": 1024000,
      "tx_bytes": 768000
    }
  },
  "application": {
    "uptime": 259200,
    "connections": 45,
    "requests_per_second": 12.5,
    "error_rate": 0.02
  }
}
```

---

## ⚠️ Error Responses

### Authentication Error (401)
```json
{
  "error": "Unauthorized",
  "message": "Invalid or missing authentication credentials",
  "code": 401
}
```

### Not Found Error (404)
```json
{
  "error": "Not Found",
  "message": "The requested endpoint does not exist",
  "code": 404
}
```

### Server Error (500)
```json
{
  "error": "Internal Server Error",
  "message": "An unexpected error occurred",
  "code": 500
}
```

### Service Unavailable (503)
```json
{
  "error": "Service Unavailable",
  "message": "The service is temporarily unavailable",
  "code": 503
}
```

---

## 🔧 Environment Variables

```env
# API Configuration
VITE_DASHBOARD_API_URL=http://localhost:3000
VITE_METRICS_API_URL=http://localhost:3001
VITE_DASHBOARD_PASSWORD=your-dashboard-password

# Development Mode
VITE_USE_MOCK_DATA=true
VITE_FORCE_MOCK_DATA=false

# Performance
VITE_API_TIMEOUT=10000
```

---

## 📋 Request Headers

### Required Headers
```http
Content-Type: application/json
```

### Authentication Headers (Dashboard API only)
```http
Authorization: Basic <base64_encoded_credentials>
```

### Optional Headers
```http
Accept: application/json
User-Agent: SynqBox-Portal/1.0.0
```

---

## 🚀 Quick Test Commands

### Test Dashboard API
```bash
# Test Points Endpoint
curl -H "Authorization: Basic OjEyMzQ1Njc4OTk=" \
     -H "Content-Type: application/json" \
     http://localhost:3000/api/points

# Test Performance Endpoint
curl -H "Authorization: Basic OjEyMzQ1Njc4OTk=" \
     -H "Content-Type: application/json" \
     http://localhost:3000/api/performance
```

### Test Metrics API
```bash
# Test Health Endpoint
curl -H "Content-Type: application/json" \
     http://localhost:3001/health

# Test Metrics Endpoint
curl -H "Content-Type: application/json" \
     http://localhost:3001/metrics
```

---

## 📊 Response Status Codes

| Code | Status | Description |
|------|--------|-------------|
| 200 | OK | Request successful |
| 401 | Unauthorized | Authentication required or invalid |
| 404 | Not Found | Endpoint does not exist |
| 500 | Internal Server Error | Server error occurred |
| 503 | Service Unavailable | Service temporarily unavailable |

---

**📝 Note**: The portal automatically falls back to mock data when APIs are unavailable, ensuring continuous operation during development and API downtime. 