import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:synq/theme/app_theme.dart';
import 'package:synq/models/api_models.dart';
import 'package:synq/services/api_service.dart';
import 'package:synq/utils/responsive_utils.dart';

class PerformanceScreen extends StatefulWidget {
  const PerformanceScreen({super.key});

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen>
    with AutomaticKeepAliveClientMixin {
  PerformanceData? _performanceData;
  bool _isLoading = true;
  String? _error;

  @override
  bool get wantKeepAlive => true; // Prevent unnecessary rebuilds

  @override
  void initState() {
    super.initState();
    _loadPerformanceData();
  }

  Future<void> _loadPerformanceData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final performanceResponse = await ApiService.getPerformance();

      if (mounted) {
        setState(() {
          if (performanceResponse.success && performanceResponse.data != null) {
            _performanceData = performanceResponse.data;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load performance data: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Container(
      padding: ResponsiveUtils.getResponsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(context),

          SizedBox(height: ResponsiveUtils.isMobile(context) ? 16 : 32),

          // Content
          Expanded(
            child: _isLoading
                ? _buildLoadingState(context)
                : _error != null
                    ? _buildErrorState(context)
                    : _buildPerformanceContent(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.analytics,
          color: AppTheme.cyanAccent,
          size: ResponsiveUtils.isMobile(context) ? 32 : 40,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Performance Analytics',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize:
                          ResponsiveUtils.getResponsiveFontSize(context, 28),
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Real-time system metrics and quality of service monitoring',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize:
                          ResponsiveUtils.getResponsiveFontSize(context, 14),
                    ),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: _loadPerformanceData,
          icon: const Icon(Icons.refresh, size: 16),
          label: ResponsiveUtils.isMobile(context)
              ? const SizedBox.shrink()
              : const Text('Refresh'),
        ),
      ],
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.surfaceDark,
      highlightColor: AppTheme.cardDark,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // QoS Overview shimmer with depth
            _buildQoSShimmer(context),
            SizedBox(height: ResponsiveUtils.isMobile(context) ? 16 : 24),

            // Traffic metrics shimmer with depth
            _buildTrafficShimmer(context),
            SizedBox(height: ResponsiveUtils.isMobile(context) ? 16 : 24),

            // Connection status shimmer with depth
            _buildConnectionShimmer(context),
          ],
        ),
      ),
    );
  }

  Widget _buildQoSShimmer(BuildContext context) {
    return Container(
      height: ResponsiveUtils.isMobile(context) ? 120 : 150,
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildQoSMetricShimmer(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.isMobile(context) ? 16 : 20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.purplePrimary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Metric title
          Container(
            width: ResponsiveUtils.isMobile(context) ? 80 : 100,
            height: ResponsiveUtils.isMobile(context) ? 16 : 18,
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          SizedBox(height: ResponsiveUtils.isMobile(context) ? 8 : 12),

          // Circular progress indicator placeholder
          Container(
            width: ResponsiveUtils.isMobile(context) ? 60 : 80,
            height: ResponsiveUtils.isMobile(context) ? 60 : 80,
            decoration: BoxDecoration(
              color: AppTheme.cardDark.withOpacity(0.8),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: AppTheme.cyanAccent.withOpacity(0.2),
                width: 6,
              ),
            ),
            child: Center(
              child: Container(
                width: ResponsiveUtils.isMobile(context) ? 24 : 30,
                height: ResponsiveUtils.isMobile(context) ? 16 : 20,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          SizedBox(height: ResponsiveUtils.isMobile(context) ? 8 : 12),

          // Description
          Container(
            width: ResponsiveUtils.isMobile(context) ? 90 : 120,
            height: ResponsiveUtils.isMobile(context) ? 12 : 14,
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrafficShimmer(BuildContext context) {
    return Container(
      height: ResponsiveUtils.isMobile(context) ? 200 : 250,
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildConnectionShimmer(BuildContext context) {
    return Container(
      height: ResponsiveUtils.isMobile(context) ? 100 : 120,
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: AppTheme.errorRed,
            size: ResponsiveUtils.isMobile(context) ? 48 : 64,
          ),
          const SizedBox(height: 16),
          Text(
            _error!,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.errorRed,
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadPerformanceData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceContent(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // QoS Overview
          if (_performanceData != null) _buildQoSOverview(context),

          const SizedBox(height: 24),

          // Traffic Metrics
          if (_performanceData != null) _buildTrafficMetrics(context),

          const SizedBox(height: 24),

          // Connection Status
          _buildConnectionStatus(context),
        ],
      ),
    );
  }

  Widget _buildQoSOverview(BuildContext context) {
    final qos = _performanceData!.qos;

    return Card(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.speed,
                  color: AppTheme.cyanAccent,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  'Quality of Service',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Overall Score: ${qos.score}%',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildQoSMetric(
                    'Reliability',
                    qos.reliability,
                    qos.ratingsBlurbs['reliability'] ?? '',
                    AppTheme.successGreen,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildQoSMetric(
                    'Availability',
                    qos.availability,
                    qos.ratingsBlurbs['availability'] ?? '',
                    AppTheme.blueAccent,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildQoSMetric(
                    'Efficiency',
                    qos.efficiency,
                    qos.ratingsBlurbs['efficiency'] ?? '',
                    AppTheme.purplePrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQoSMetric(
      String label, int score, String description, Color color) {
    // Add fallback descriptions if none provided
    String getDescription() {
      if (description.isNotEmpty) {
        return description;
      }

      // Provide fallback descriptions based on score
      if (score >= 90) {
        return "Excellent performance.";
      } else if (score >= 70) {
        return "Good performance.";
      } else if (score >= 50) {
        return "Average performance.";
      } else {
        return "Poor performance.";
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 12),

          // Circular progress indicator
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: score / 100.0,
                  strokeWidth: 6,
                  backgroundColor: color.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Text(
                '$score%',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Text(
            getDescription(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTrafficMetrics(BuildContext context) {
    final performance = _performanceData?.performance;

    return Card(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.traffic,
                  color: AppTheme.purplePrimary,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  'Traffic Metrics',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (performance != null) ...[
              _buildTrafficStat('Total Traffic',
                  '${(performance.totalTraffic / 1024 / 1024).toStringAsFixed(1)} MB'),
              const SizedBox(height: 16),
              _buildTrafficStat(
                  'Active Sessions', performance.sessions.toString()),
              const SizedBox(height: 16),
              _buildTrafficStat(
                  'Connected Users', performance.users.toString()),
              const SizedBox(height: 16),
              _buildTrafficStat(
                  'Demo Sessions', performance.demoSessions.toString()),
              const SizedBox(height: 16),
              _buildTrafficStat('Bytes In',
                  '${(performance.bytesIn / 1024).toStringAsFixed(1)} KB'),
              const SizedBox(height: 16),
              _buildTrafficStat('Bytes Out',
                  '${(performance.bytesOut / 1024).toStringAsFixed(1)} KB'),
            ] else
              const Text('No traffic data available'),
          ],
        ),
      ),
    );
  }

  Widget _buildTrafficStat(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  Widget _buildConnectionStatus(BuildContext context) {
    final performance = _performanceData?.performance;

    return Card(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.link,
                  color: AppTheme.cyanAccent,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  'Connection Status',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (performance != null) ...[
              _buildConnectionStat(
                'Proxy Connection',
                performance.proxyConnectionState,
                performance.proxyConnectionState == 'CONNECTED'
                    ? AppTheme.successGreen
                    : AppTheme.errorRed,
              ),
              const SizedBox(height: 16),
              _buildConnectionStat(
                'Data Source',
                'Real-time API',
                AppTheme.cyanAccent,
              ),
            ] else
              const Text('No connection data available'),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStat(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}
