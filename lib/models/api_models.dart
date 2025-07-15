import 'dart:convert';

// Safe helper methods for JSON parsing
double _safeDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

int _safeInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

bool _safeBool(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is String) return value.toLowerCase() == 'true';
  if (value is int) return value != 0;
  return false;
}

class PointsData {
  final String timestamp;
  final Points points;
  final int syncLifePoints;
  final int walletLifePoints;
  final double walletBalance;
  final String source;
  final String containerUptime;
  final bool isEarning;
  final String connectionState;

  PointsData({
    required this.timestamp,
    required this.points,
    required this.syncLifePoints,
    required this.walletLifePoints,
    required this.walletBalance,
    required this.source,
    required this.containerUptime,
    required this.isEarning,
    required this.connectionState,
  });

  factory PointsData.fromJson(Map<String, dynamic> json) {
    return PointsData(
      timestamp: json['timestamp']?.toString() ?? '',
      points: Points.fromJson(json['points'] ?? {}),
      syncLifePoints: _safeInt(json['syncLifePoints']),
      walletLifePoints: _safeInt(json['walletLifePoints']),
      walletBalance: _safeDouble(json['walletBalance']),
      source: json['source']?.toString() ?? '',
      containerUptime: json['containerUptime']?.toString() ?? '',
      isEarning: _safeBool(json['isEarning']),
      connectionState: json['connectionState']?.toString() ?? '',
    );
  }
}

class Points {
  final int total;
  final int daily;
  final int weekly;
  final int monthly;
  final int streak;
  final String rank;
  final String multiplier;

  Points({
    required this.total,
    required this.daily,
    required this.weekly,
    required this.monthly,
    required this.streak,
    required this.rank,
    required this.multiplier,
  });

  factory Points.fromJson(Map<String, dynamic> json) {
    return Points(
      total: _safeInt(json['total']),
      daily: _safeInt(json['daily']),
      weekly: _safeInt(json['weekly']),
      monthly: _safeInt(json['monthly']),
      streak: _safeInt(json['streak']),
      rank: json['rank']?.toString() ?? '',
      multiplier: json['multiplier']?.toString() ?? '',
    );
  }
}

class PerformanceData {
  final String timestamp;
  final Performance performance;
  final QualityOfService qos;

  PerformanceData({
    required this.timestamp,
    required this.performance,
    required this.qos,
  });

  factory PerformanceData.fromJson(Map<String, dynamic> json) {
    return PerformanceData(
      timestamp: json['timestamp'] ?? '',
      performance: Performance.fromJson(json['performance'] ?? {}),
      qos: QualityOfService.fromJson(json['qos'] ?? {}),
    );
  }
}

class Performance {
  final int totalTraffic;
  final int sessions;
  final int users;
  final int demoSessions;
  final int bytesIn;
  final int bytesOut;
  final String proxyConnectionState;

  Performance({
    required this.totalTraffic,
    required this.sessions,
    required this.users,
    required this.demoSessions,
    required this.bytesIn,
    required this.bytesOut,
    required this.proxyConnectionState,
  });

  factory Performance.fromJson(Map<String, dynamic> json) {
    return Performance(
      totalTraffic: _safeInt(json['totalTraffic']),
      sessions: _safeInt(json['sessions']),
      users: _safeInt(json['users']),
      demoSessions: _safeInt(json['demoSessions']),
      bytesIn: _safeInt(json['bytesIn']),
      bytesOut: _safeInt(json['bytesOut']),
      proxyConnectionState: json['proxyConnectionState']?.toString() ?? '',
    );
  }
}

class QualityOfService {
  final int score;
  final int reliability;
  final int availability;
  final int efficiency;
  final Map<String, String> ratingsBlurbs;

  QualityOfService({
    required this.score,
    required this.reliability,
    required this.availability,
    required this.efficiency,
    required this.ratingsBlurbs,
  });

  factory QualityOfService.fromJson(Map<String, dynamic> json) {
    // Convert 0/1/2 rating values to percentage values for display
    // 0 = 100%, 1 = 67%, 2 = 33%
    int convertRatingToPercentage(dynamic rating) {
      if (rating == null) return 33; // default to poor if null
      int ratingValue =
          rating is int ? rating : int.tryParse(rating.toString()) ?? 2;

      if (ratingValue == 0) return 100;
      if (ratingValue == 1) return 67;
      if (ratingValue == 2) return 33;

      // If already a percentage (>10), return as is
      if (ratingValue > 10) return ratingValue;

      return 33; // fallback for undefined/null
    }

    // Get the raw rating values from the API
    final rawAvailability = json['availability'];
    final rawReliability = json['reliability'];
    final rawEfficiency = json['efficiency'];

    // Convert to percentages for display
    final availability = convertRatingToPercentage(rawAvailability);
    final reliability = convertRatingToPercentage(rawReliability);
    final efficiency = convertRatingToPercentage(rawEfficiency);

    // Calculate overall health score using CLI's formula if we have rating values
    int calculateOverallScore() {
      // If we have a direct score, use it
      if (json['score'] != null && json['score'] is int && json['score'] > 10) {
        return json['score'];
      }

      // Otherwise calculate using CLI formula: 40 + 10 * ((2 - availabilityRating) + (2 - reliabilityRating) + (2 - efficiencyRating))
      int availabilityRating = rawAvailability is int
          ? rawAvailability
          : (rawAvailability != null
              ? int.tryParse(rawAvailability.toString()) ?? 2
              : 2);
      int reliabilityRating = rawReliability is int
          ? rawReliability
          : (rawReliability != null
              ? int.tryParse(rawReliability.toString()) ?? 2
              : 2);
      int efficiencyRating = rawEfficiency is int
          ? rawEfficiency
          : (rawEfficiency != null
              ? int.tryParse(rawEfficiency.toString()) ?? 2
              : 2);

      // If values are already percentages, convert back to ratings
      if (availabilityRating > 10) {
        availabilityRating =
            availabilityRating == 100 ? 0 : (availabilityRating == 67 ? 1 : 2);
      }
      if (reliabilityRating > 10) {
        reliabilityRating =
            reliabilityRating == 100 ? 0 : (reliabilityRating == 67 ? 1 : 2);
      }
      if (efficiencyRating > 10) {
        efficiencyRating =
            efficiencyRating == 100 ? 0 : (efficiencyRating == 67 ? 1 : 2);
      }

      return 40 +
          10 *
              ((2 - availabilityRating) +
                  (2 - reliabilityRating) +
                  (2 - efficiencyRating));
    }

    final score = calculateOverallScore();

    // Parse ratingsBlurbs safely
    Map<String, String> parseRatingsBlurbs() {
      final ratingsBlurbsData = json['ratingsBlurbs'];
      if (ratingsBlurbsData == null) return {};

      if (ratingsBlurbsData is Map<String, dynamic>) {
        return ratingsBlurbsData
            .map((key, value) => MapEntry(key, value.toString()));
      }

      if (ratingsBlurbsData is String) {
        try {
          final parsed = jsonDecode(ratingsBlurbsData);
          if (parsed is Map<String, dynamic>) {
            return parsed.map((key, value) => MapEntry(key, value.toString()));
          }
        } catch (e) {
          // If parsing fails, return empty map
          return {};
        }
      }

      return {};
    }

    return QualityOfService(
      score: score,
      reliability: reliability,
      availability: availability,
      efficiency: efficiency,
      ratingsBlurbs: parseRatingsBlurbs(),
    );
  }
}

class SystemStatus {
  final String timestamp;
  final String serviceStatus;
  final bool dockerAvailable;
  final bool autoStart;
  final String uptime;
  final bool containerRunning;
  final ImageUpdates imageUpdates;
  final SystemResources? systemResources;

  SystemStatus({
    required this.timestamp,
    required this.serviceStatus,
    required this.dockerAvailable,
    required this.autoStart,
    required this.uptime,
    required this.containerRunning,
    required this.imageUpdates,
    this.systemResources,
  });

  factory SystemStatus.fromJson(Map<String, dynamic> json) {
    return SystemStatus(
      timestamp: json['timestamp'] ?? '',
      serviceStatus: json['serviceStatus'] ?? '',
      dockerAvailable: _safeBool(json['dockerAvailable']),
      autoStart: _safeBool(json['autoStart']),
      uptime: json['uptime'] ?? '',
      containerRunning: _safeBool(json['containerRunning']),
      imageUpdates: ImageUpdates.fromJson(json['imageUpdates'] ?? {}),
      systemResources: json['systemResources'] != null
          ? SystemResources.fromJson(json['systemResources'])
          : null,
    );
  }
}

class SystemResources {
  final int cpuUsage; // CPU usage percentage (0-100)
  final int memoryUsage; // Memory usage percentage (0-100)
  final int diskUsage; // Disk usage percentage (0-100)
  final String totalMemory; // Total memory (e.g., "8.0 GB")
  final String usedMemory; // Used memory (e.g., "4.2 GB")
  final String totalDisk; // Total disk space (e.g., "500 GB")
  final String usedDisk; // Used disk space (e.g., "250 GB")

  SystemResources({
    required this.cpuUsage,
    required this.memoryUsage,
    required this.diskUsage,
    required this.totalMemory,
    required this.usedMemory,
    required this.totalDisk,
    required this.usedDisk,
  });

  factory SystemResources.fromJson(Map<String, dynamic> json) {
    return SystemResources(
      cpuUsage: _safeInt(json['cpuUsage']),
      memoryUsage: _safeInt(json['memoryUsage']),
      diskUsage: _safeInt(json['diskUsage']),
      totalMemory: json['totalMemory'] ?? '',
      usedMemory: json['usedMemory'] ?? '',
      totalDisk: json['totalDisk'] ?? '',
      usedDisk: json['usedDisk'] ?? '',
    );
  }
}

class ImageUpdates {
  final int available;
  final String lastChecked;
  final List<ImageUpdate> images;

  ImageUpdates({
    required this.available,
    required this.lastChecked,
    required this.images,
  });

  factory ImageUpdates.fromJson(Map<String, dynamic> json) {
    return ImageUpdates(
      available: _safeInt(json['available']),
      lastChecked: json['lastChecked'] ?? '',
      images: (json['images'] as List<dynamic>?)
              ?.map((item) => ImageUpdate.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class ImageUpdate {
  final String name;
  final bool updateAvailable;

  ImageUpdate({required this.name, required this.updateAvailable});

  factory ImageUpdate.fromJson(Map<String, dynamic> json) {
    return ImageUpdate(
      name: json['name'] ?? '',
      updateAvailable: _safeBool(json['updateAvailable']),
    );
  }
}

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final int statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.error,
    required this.statusCode,
  });

  factory ApiResponse.success(T data, int statusCode) {
    return ApiResponse(success: true, data: data, statusCode: statusCode);
  }

  factory ApiResponse.error(String error, int statusCode) {
    return ApiResponse(success: false, error: error, statusCode: statusCode);
  }
}
