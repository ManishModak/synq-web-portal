import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:synq/theme/app_theme.dart';
import 'package:synq/models/api_models.dart';
import 'package:synq/services/api_service.dart';
import 'package:synq/utils/responsive_utils.dart';

class PointsDisplayWidget extends StatefulWidget {
  final VoidCallback? onRefresh;
  final Function(VoidCallback)? refreshCallback;

  const PointsDisplayWidget({
    super.key,
    this.onRefresh,
    this.refreshCallback,
  });

  @override
  State<PointsDisplayWidget> createState() => _PointsDisplayWidgetState();
}

class _PointsDisplayWidgetState extends State<PointsDisplayWidget>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _animationController;
  late Animation<double> _glowAnimation;
  PointsData? _pointsData;
  bool _isLoading = true;
  String? _error;

  @override
  bool get wantKeepAlive => true; // Prevent unnecessary rebuilds

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadPointsData();

    // Register refresh callback with parent
    widget.refreshCallback?.call(_loadPointsData);
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.repeat(reverse: true);
  }

  Future<void> _loadPointsData() async {
    if (!mounted) return;

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await ApiService.getPoints();

      if (mounted) {
        setState(() {
          if (response.success && response.data != null) {
            _pointsData = response.data;
          } else {
            _error = response.error ?? 'Failed to load points data';
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Network error: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  // Public method to refresh data from parent
  void refreshData() {
    _loadPointsData();
  }

  void _handleRefresh() {
    _loadPointsData();
    widget.onRefresh?.call();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Card(
      child: Container(
        padding: ResponsiveUtils.getResponsivePadding(context),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2A1F3D), // More muted purple
              Color(0xFF1E1B2E), // Darker, more subtle
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            SizedBox(height: ResponsiveUtils.isMobile(context) ? 16 : 24),
            if (_isLoading)
              _buildShimmerLoadingState(context)
            else if (_error != null)
              _buildErrorState(context)
            else if (_pointsData != null)
              _buildPointsContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Container(
              width: ResponsiveUtils.isMobile(context) ? 40 : 48,
              height: ResponsiveUtils.isMobile(context) ? 40 : 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.surfaceDark,
                border: Border.all(
                  color: AppTheme.purplePrimary.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.purplePrimary.withOpacity(
                        _glowAnimation.value * 0.15), // Subtle animation
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                Icons.stars,
                color: AppTheme.textPrimary,
                size: ResponsiveUtils.isMobile(context) ? 20 : 24,
              ),
            );
          },
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SynQ Points',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize:
                          ResponsiveUtils.getResponsiveFontSize(context, 20),
                    ),
              ),
              Text(
                'Real-time earnings tracker',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize:
                          ResponsiveUtils.getResponsiveFontSize(context, 14),
                    ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: _handleRefresh,
          icon: const Icon(Icons.refresh),
          color: AppTheme.cyanAccent,
          iconSize: ResponsiveUtils.isMobile(context) ? 20 : 24,
        ),
      ],
    );
  }

  Widget _buildShimmerLoadingState(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.surfaceDark,
      highlightColor: AppTheme.cardDark,
      child: Column(
        children: [
          // Main points display shimmer
          Container(
            height: ResponsiveUtils.getShimmerHeight(context, 'points'),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          SizedBox(height: ResponsiveUtils.isMobile(context) ? 16 : 20),

          // Points breakdown shimmer - responsive layout
          ResponsiveUtils.isMobile(context)
              ? Column(
                  children: [
                    Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceDark,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    SizedBox(
                        height: ResponsiveUtils.isMobile(context) ? 10 : 12),
                    Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceDark,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    SizedBox(
                        height: ResponsiveUtils.isMobile(context) ? 10 : 12),
                    Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceDark,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceDark,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceDark,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceDark,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
          SizedBox(height: ResponsiveUtils.isMobile(context) ? 12 : 16),

          // Connection status shimmer
          Container(
            height: ResponsiveUtils.isMobile(context) ? 50 : 60,
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: AppTheme.errorRed,
            size: ResponsiveUtils.isMobile(context) ? 40 : 48,
          ),
          SizedBox(height: ResponsiveUtils.isMobile(context) ? 6 : 8),
          Text(
            _error!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.errorRed,
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveUtils.isMobile(context) ? 12 : 16),
          ElevatedButton(
            onPressed: _handleRefresh,
            child: Text(
              'Retry',
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsContent(BuildContext context) {
    final points = _pointsData!.points;

    return Column(
      children: [
        // Main points display
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2A1F3D), // Much more muted purple
                Color(0xFF1E1B2E), // Darker, more subtle
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.purplePrimary.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    AppTheme.purplePrimary.withOpacity(0.1), // Much more subtle
                blurRadius: 8, // Reduced from 16
                spreadRadius: 0, // Reduced from 4
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'Total Points',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                      fontSize:
                          ResponsiveUtils.getResponsiveFontSize(context, 16),
                    ),
              ),
              SizedBox(height: ResponsiveUtils.isMobile(context) ? 6 : 8),
              Text(
                '${points.total.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize:
                          ResponsiveUtils.getResponsiveFontSize(context, 28),
                    ),
              ),
              SizedBox(height: ResponsiveUtils.isMobile(context) ? 3 : 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.trending_up,
                    color: AppTheme.successGreen.withOpacity(0.8), // More muted
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Rank: ${points.rank}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.successGreen
                              .withOpacity(0.8), // More muted
                        ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Multiplier: ${points.multiplier}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.cyanAccent
                              .withOpacity(0.8), // More muted
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),

        SizedBox(height: ResponsiveUtils.isMobile(context) ? 16 : 20),

        // Points breakdown
        Row(
          children: [
            Expanded(
              child: _buildPointsBreakdown(
                'Daily',
                points.daily,
                AppTheme.cyanAccent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPointsBreakdown(
                'Weekly',
                points.weekly,
                AppTheme.blueAccent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPointsBreakdown(
                'Monthly',
                points.monthly,
                AppTheme.purpleLight,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Connection status
        _buildConnectionStatus(),
      ],
    );
  }

  Widget _buildPointsBreakdown(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
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
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus() {
    // Improved connection state detection
    final connectionState = _pointsData!.connectionState.toUpperCase();
    final isConnected = connectionState == 'CONNECTED' ||
        connectionState == 'ACTIVE' ||
        connectionState == 'RUNNING';
    final isEarning = _pointsData!.isEarning;

    // Determine status text and color
    String statusText;
    Color statusColor;

    if (isConnected && isEarning) {
      statusText = 'Connected & Earning';
      statusColor = AppTheme.successGreen;
    } else if (isConnected && !isEarning) {
      statusText = 'Connected';
      statusColor = AppTheme.warningYellow;
    } else {
      statusText = 'Disconnected';
      statusColor = AppTheme.errorRed;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: statusColor.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  isEarning
                      ? 'Earning points actively'
                      : 'Not currently earning',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Uptime',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              Text(
                _pointsData!.containerUptime,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
