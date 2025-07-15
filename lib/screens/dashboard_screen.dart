import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:synq/theme/app_theme.dart';
import 'package:synq/widgets/points_display_widget.dart';
import 'package:synq/widgets/chart_widgets.dart';
import 'package:synq/widgets/system_info_widget.dart';
import 'package:synq/models/api_models.dart';
import 'package:synq/services/api_service.dart';
import 'package:synq/utils/responsive_utils.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  SystemStatus? _systemStatus;
  PointsData? _pointsData;
  bool _isLoading = true;
  bool _isPointsLoading = true;
  VoidCallback? _pointsRefreshCallback;

  @override
  void initState() {
    super.initState();
    _loadSystemData();
    _loadPointsData();
  }

  Future<void> _loadSystemData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final statusResponse = await ApiService.getSystemStatus();

      setState(() {
        if (statusResponse.success && statusResponse.data != null) {
          _systemStatus = statusResponse.data;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPointsData() async {
    setState(() {
      _isPointsLoading = true;
    });

    try {
      final pointsResponse = await ApiService.getPoints();

      setState(() {
        if (pointsResponse.success && pointsResponse.data != null) {
          _pointsData = pointsResponse.data;
        }
        _isPointsLoading = false;
      });
    } catch (e) {
      setState(() {
        _isPointsLoading = false;
      });
    }
  }

  Future<void> _refreshAllData() async {
    // Set system overview to loading immediately
    setState(() {
      _isLoading = true;
      _isPointsLoading = true;
    });

    // Trigger points refresh (which will set its loading state)
    _pointsRefreshCallback?.call();

    try {
      // Wait for both API calls to complete
      await Future.wait([
        _loadSystemStatusOnly(),
        _loadPointsData(),
        Future.delayed(
            const Duration(milliseconds: 1000)), // Minimum loading time for UX
      ]);

      // Exit loading state
      setState(() {
        _isLoading = false;
        _isPointsLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isPointsLoading = false;
      });
    }
  }

  Future<void> _loadSystemStatusOnly() async {
    try {
      final statusResponse = await ApiService.getSystemStatus();
      if (mounted) {
        setState(() {
          if (statusResponse.success && statusResponse.data != null) {
            _systemStatus = statusResponse.data;
          }
        });
      }
    } catch (e) {
      // Handle error silently during coordinated refresh
    }
  }

  void _setPointsRefreshCallback(VoidCallback callback) {
    _pointsRefreshCallback = callback;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: ResponsiveUtils.getResponsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),

          SizedBox(height: ResponsiveUtils.isMobile(context) ? 16 : 32),

          // Main dashboard content
          Expanded(
            child: _buildDashboardContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SynqBox Portal',
                style: AppTheme.darkTheme.textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Control your SynqBox and monitor real-time performance',
                style: AppTheme.darkTheme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: _refreshAllData,
          icon: const Icon(Icons.refresh),
          label: const Text('Refresh Data'),
        ),
      ],
    );
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Points Display - Full Width
          PointsDisplayWidget(refreshCallback: _setPointsRefreshCallback),

          SizedBox(height: ResponsiveUtils.isMobile(context) ? 16 : 24),

          // Charts Section
          _buildChartsSection(),

          SizedBox(height: ResponsiveUtils.isMobile(context) ? 16 : 24),

          // System Overview - Full Width
          _buildSystemOverview(),

          SizedBox(height: ResponsiveUtils.isMobile(context) ? 16 : 24),

          // System Information Widget
          const SystemInfoWidget(),

          // Add bottom padding to prevent content from being cut off
          SizedBox(height: ResponsiveUtils.isMobile(context) ? 16 : 24),
        ],
      ),
    );
  }

  Widget _buildChartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.isMobile(context) ? 16 : 24,
          ),
          child: Text(
            'Analytics Overview',
            style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        SizedBox(height: ResponsiveUtils.isMobile(context) ? 12 : 16),

        // Points Progression Chart only
        PointsProgressionChart(
          pointsData: _pointsData,
          isLoading: _isPointsLoading,
        ),
      ],
    );
  }

  Widget _buildSystemOverview() {
    return Card(
      child: Container(
        padding: ResponsiveUtils.getResponsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with overall health indicator
            _buildSystemOverviewHeader(),

            SizedBox(height: ResponsiveUtils.isMobile(context) ? 16 : 24),

            if (_isLoading)
              _buildSystemOverviewShimmer()
            else if (_systemStatus != null)
              _buildSystemStatusContent()
            else
              _buildSystemStatusError(),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemOverviewHeader() {
    final overallHealthy = _systemStatus?.serviceStatus == 'running' &&
        _systemStatus?.dockerAvailable == true &&
        _systemStatus?.containerRunning == true;

    return Row(
      children: [
        // System icon with glow effect
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: overallHealthy ? AppTheme.glowGradient : null,
          ),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: overallHealthy
                    ? AppTheme.successGreen
                    : AppTheme.purplePrimary,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.computer,
              color: overallHealthy
                  ? AppTheme.successGreen
                  : AppTheme.purplePrimary,
              size: ResponsiveUtils.isMobile(context) ? 28 : 32,
            ),
          ),
        ),
        SizedBox(width: ResponsiveUtils.isMobile(context) ? 12 : 16),

        // Title and status
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'System Overview',
                style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              if (_systemStatus != null)
                _buildOverallHealthStatus(overallHealthy),
            ],
          ),
        ),

        // Refresh button
        if (!_isLoading)
          IconButton(
            onPressed: _refreshAllData,
            icon: const Icon(Icons.refresh),
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.purplePrimary.withOpacity(0.1),
              foregroundColor: AppTheme.purplePrimary,
            ),
          ),
      ],
    );
  }

  Widget _buildOverallHealthStatus(bool healthy) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: healthy
            ? AppTheme.successGreen.withOpacity(0.1)
            : AppTheme.errorRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: healthy ? AppTheme.successGreen : AppTheme.errorRed,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            healthy ? Icons.check_circle : Icons.warning,
            size: 16,
            color: healthy ? AppTheme.successGreen : AppTheme.errorRed,
          ),
          const SizedBox(width: 6),
          Text(
            healthy ? 'System Healthy' : 'System Issues',
            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              color: healthy ? AppTheme.successGreen : AppTheme.errorRed,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemOverviewShimmer() {
    return Shimmer.fromColors(
      baseColor: AppTheme.surfaceDark,
      highlightColor: AppTheme.cardDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Core Services Section Shimmer
          _buildShimmerSection('Core Services', 3),

          SizedBox(height: ResponsiveUtils.isMobile(context) ? 20 : 24),

          // System Resources Section Shimmer
          _buildShimmerSection('System Resources', 3),

          SizedBox(height: ResponsiveUtils.isMobile(context) ? 20 : 24),

          // System Metrics Section Shimmer
          _buildShimmerSection('System Metrics', 3),
        ],
      ),
    );
  }

  Widget _buildShimmerSection(String title, int cardCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title shimmer
        Container(
          width: 140,
          height: 20,
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 12),

        // Cards shimmer
        if (ResponsiveUtils.isMobile(context))
          Column(
            children: List.generate(
                cardCount,
                (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildShimmerCard(),
                    )),
          )
        else
          // Desktop layout - use same flexible grid as real cards
          LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth;
              final cardSpacing = 20.0;
              final minCardWidth = 320.0;
              final maxCardWidth = 420.0;

              // Calculate optimal card width based on available space
              int cardsPerRow =
                  (availableWidth / (minCardWidth + cardSpacing)).floor();
              if (cardsPerRow == 0) cardsPerRow = 1;
              if (cardsPerRow > cardCount) cardsPerRow = cardCount;

              final totalSpacing = (cardsPerRow - 1) * cardSpacing;
              final cardWidth = ((availableWidth - totalSpacing) / cardsPerRow)
                  .clamp(minCardWidth, maxCardWidth);

              return Wrap(
                spacing: cardSpacing,
                runSpacing: 16,
                children: List.generate(
                    cardCount,
                    (index) => SizedBox(
                          width: cardWidth,
                          child: _buildShimmerCard(),
                        )),
              );
            },
          ),
      ],
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20), // Match real card padding
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius:
            BorderRadius.circular(16), // Match real card border radius
        border: Border.all(
          color: AppTheme.purplePrimary.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.purplePrimary.withOpacity(0.05),
            blurRadius: 12, // Match real card shadow
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icon shimmer - match real card icon size
              Container(
                width: 48, // 24px icon + 12px padding on each side
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(
                      12), // Match real card icon border radius
                ),
              ),
              const SizedBox(width: 16), // Match real card spacing

              // Text content shimmer
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 90,
                      height: 14, // Match real card title font size
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceDark,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 140,
                      height: 18, // Match real card value font size
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceDark,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16), // Match real card spacing

          // Progress bar shimmer (for resource usage cards)
          Container(
            width: double.infinity,
            height: 6, // Match real progress bar height
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          const SizedBox(height: 12), // Match real card spacing

          // Subtitle shimmer
          Container(
            width: 180,
            height: 12, // Match real card subtitle font size
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemStatusContent() {
    final status = _systemStatus!;

    return Column(
      children: [
        // Core Services Section
        _buildStatusSection('Core Services', [
          _buildEnhancedStatusCard(
            'Service Status',
            status.serviceStatus.toUpperCase(),
            status.serviceStatus == 'running'
                ? AppTheme.successGreen
                : AppTheme.errorRed,
            status.serviceStatus == 'running'
                ? Icons.play_circle_filled
                : Icons.stop_circle,
            subtitle: status.serviceStatus == 'running'
                ? 'Active and monitoring'
                : 'Service not running',
          ),
          _buildEnhancedStatusCard(
            'Docker Engine',
            status.dockerAvailable ? 'Available' : 'Unavailable',
            status.dockerAvailable ? AppTheme.successGreen : AppTheme.errorRed,
            status.dockerAvailable ? Icons.check_circle : Icons.error,
            subtitle: status.dockerAvailable
                ? 'Ready for containers'
                : 'Docker not installed',
          ),
          _buildEnhancedStatusCard(
            'Container',
            status.containerRunning ? 'Running' : 'Stopped',
            status.containerRunning ? AppTheme.successGreen : AppTheme.errorRed,
            status.containerRunning ? Icons.play_circle : Icons.stop_circle,
            subtitle: status.containerRunning
                ? 'Processing synchronization'
                : 'Container not active',
          ),
        ]),

        SizedBox(height: ResponsiveUtils.isMobile(context) ? 20 : 24),

        // System Resources Section (if available)
        if (status.systemResources != null) ...[
          _buildStatusSection('System Resources', [
            _buildResourceUsageCard(
              'CPU Usage',
              status.systemResources!.cpuUsage,
              Icons.speed,
              AppTheme.cyanAccent,
            ),
            _buildResourceUsageCard(
              'Memory Usage',
              status.systemResources!.memoryUsage,
              Icons.memory,
              AppTheme.purplePrimary,
              subtitle:
                  '${status.systemResources!.usedMemory} / ${status.systemResources!.totalMemory}',
            ),
            _buildResourceUsageCard(
              'Disk Usage',
              status.systemResources!.diskUsage,
              Icons.storage,
              AppTheme.warningYellow,
              subtitle:
                  '${status.systemResources!.usedDisk} / ${status.systemResources!.totalDisk}',
            ),
          ]),
          SizedBox(height: ResponsiveUtils.isMobile(context) ? 20 : 24),
        ],

        // System Metrics Section
        _buildStatusSection('System Metrics', [
          _buildEnhancedStatusCard(
            'Uptime',
            status.uptime,
            AppTheme.cyanAccent,
            Icons.timer,
            subtitle: 'System operational time',
          ),
          _buildEnhancedStatusCard(
            'Auto-start',
            status.autoStart ? 'Enabled' : 'Disabled',
            status.autoStart ? AppTheme.successGreen : AppTheme.warningYellow,
            status.autoStart ? Icons.auto_awesome : Icons.warning,
            subtitle: status.autoStart
                ? 'Starts automatically'
                : 'Manual start required',
          ),
          _buildEnhancedStatusCard(
            'Image Updates',
            status.imageUpdates.available > 0
                ? '${status.imageUpdates.available} Available'
                : 'Up to date',
            status.imageUpdates.available > 0
                ? AppTheme.warningYellow
                : AppTheme.successGreen,
            status.imageUpdates.available > 0
                ? Icons.system_update
                : Icons.check_circle,
            subtitle: status.imageUpdates.available > 0
                ? 'Updates pending'
                : 'Latest version',
          ),
        ]),
      ],
    );
  }

  Widget _buildStatusSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        if (ResponsiveUtils.isMobile(context))
          Column(
              children: children
                  .map((child) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: child,
                      ))
                  .toList())
        else
          // Desktop layout - use flexible grid
          LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth;
              final cardSpacing = 20.0;
              final minCardWidth = 320.0;
              final maxCardWidth = 420.0;

              // Calculate optimal card width based on available space
              int cardsPerRow =
                  (availableWidth / (minCardWidth + cardSpacing)).floor();
              if (cardsPerRow == 0) cardsPerRow = 1;
              if (cardsPerRow > children.length) cardsPerRow = children.length;

              final totalSpacing = (cardsPerRow - 1) * cardSpacing;
              final cardWidth = ((availableWidth - totalSpacing) / cardsPerRow)
                  .clamp(minCardWidth, maxCardWidth);

              return Wrap(
                spacing: cardSpacing,
                runSpacing: 16,
                children: children.map((child) {
                  if (child is Widget) {
                    return SizedBox(
                      width: cardWidth,
                      child: child,
                    );
                  }
                  return child;
                }).toList(),
              );
            },
          ),
      ],
    );
  }

  Widget _buildEnhancedStatusCard(
    String title,
    String value,
    Color color,
    IconData icon, {
    String? subtitle,
  }) {
    return Container(
      width: double.infinity, // Use full width of parent
      padding: const EdgeInsets.all(20), // Increased padding
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16), // Increased border radius
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 12, // Enhanced shadow
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12), // Increased icon padding
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(12), // Increased border radius
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24, // Increased icon size
                ),
              ),
              const SizedBox(width: 16), // Increased spacing
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                        fontSize: 18, // Increased font size
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 12), // Increased spacing
            Text(
              subtitle,
              style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textMuted,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResourceUsageCard(
    String title,
    int usagePercent,
    IconData icon,
    Color color, {
    String? subtitle,
  }) {
    // Determine color based on usage level
    Color getUsageColor(int percent) {
      if (percent < 60) return AppTheme.successGreen;
      if (percent < 80) return AppTheme.warningYellow;
      return AppTheme.errorRed;
    }

    final usageColor = getUsageColor(usagePercent);

    return Container(
      width: double.infinity, // Use full width of parent
      padding: const EdgeInsets.all(20), // Increased padding
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16), // Increased border radius
        border: Border.all(
          color: usageColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: usageColor.withOpacity(0.1),
            blurRadius: 12, // Enhanced shadow
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12), // Increased icon padding
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(12), // Increased border radius
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24, // Increased icon size
                ),
              ),
              const SizedBox(width: 16), // Increased spacing
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${usagePercent}%',
                      style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                        color: usageColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 18, // Increased font size
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16), // Increased spacing

          // Usage progress bar
          Container(
            height: 6, // Increased height
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              widthFactor: usagePercent / 100,
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  color: usageColor,
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                      color: usageColor.withOpacity(0.5),
                      blurRadius: 6, // Enhanced glow
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (subtitle != null) ...[
            const SizedBox(height: 12), // Increased spacing
            Text(
              subtitle,
              style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textMuted,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSystemStatusError() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.errorRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.errorRed.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error,
            color: AppTheme.errorRed,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Failed to load system status. Please try again later.',
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.errorRed,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: _refreshAllData,
            icon: const Icon(Icons.refresh),
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.errorRed.withOpacity(0.1),
              foregroundColor: AppTheme.errorRed,
            ),
          ),
        ],
      ),
    );
  }
}
