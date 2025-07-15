import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:synq/theme/app_theme.dart';
import 'package:synq/utils/responsive_utils.dart';

class SystemInfoWidget extends StatefulWidget {
  const SystemInfoWidget({super.key});

  @override
  State<SystemInfoWidget> createState() => _SystemInfoWidgetState();
}

class _SystemInfoWidgetState extends State<SystemInfoWidget> {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  Map<String, dynamic> systemInfo = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSystemInfo();
  }

  Future<void> _loadSystemInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic> info = {
        'platform': _getPlatformName(),
        'isWeb': kIsWeb,
        'debugMode': kDebugMode,
        'dartVersion': _getDartVersion(),
        'flutterVersion': _getFlutterVersion(),
      };

      // Add system-specific information
      info.addAll({
        'hostname': await _getHostname(),
        'platform': await _getPlatformDetails(),
        'architecture': await _getArchitectureDetails(),
        'uptime': await _getSystemUptime(),
        'memoryUsage': await _getMemoryUsage(),
        'systemLoad': await _getSystemLoad(),
      });

      setState(() {
        systemInfo = info;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        systemInfo = {
          'error': 'Failed to load system information',
          'platform': _getPlatformName(),
          'isWeb': kIsWeb,
        };
        _isLoading = false;
      });
    }
  }

  String _getPlatformName() {
    if (kIsWeb) return 'Web';
    return defaultTargetPlatform.toString().split('.').last;
  }

  String _getDartVersion() {
    return '3.5.4'; // This would typically come from build info
  }

  String _getFlutterVersion() {
    return '3.24.0'; // This would typically come from build info
  }

  Future<String> _getHostname() async {
    // For web, we can't get actual hostname, so return a placeholder
    if (kIsWeb) {
      return 'desktop-synq-web';
    }
    // For native apps, this would typically come from platform-specific code
    return 'synq-desktop-pc';
  }

  Future<String> _getPlatformDetails() async {
    if (kIsWeb) {
      return 'web';
    }
    return defaultTargetPlatform.toString().split('.').last.toLowerCase();
  }

  Future<String> _getArchitectureDetails() async {
    if (kIsWeb) {
      return 'x86_64';
    }
    return 'x86_64'; // This would typically be detected from the platform
  }

  Future<String> _getSystemUptime() async {
    // For demonstration, return a mock uptime
    // In a real app, this would come from platform-specific code
    return '2d 12h 38m';
  }

  Future<Map<String, dynamic>> _getMemoryUsage() async {
    // For demonstration, return mock memory data
    // In a real app, this would come from platform-specific code
    return {
      'percentage': 72.8,
      'used': '11.7 GB',
      'total': '16.0 GB',
    };
  }

  Future<Map<String, dynamic>> _getSystemLoad() async {
    // For demonstration, return mock system load data
    // In a real app, this would come from platform-specific code
    return {
      'current': 0.85,
      'load1': 0.92,
      'load5': 0.78,
      'load15': 0.65,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: ResponsiveUtils.getResponsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            if (_isLoading) _buildLoadingState() else _buildSystemInfoContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.cyanAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.info_outline,
            color: AppTheme.cyanAccent,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'System Information',
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Device and runtime details',
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: _loadSystemInfo,
          icon: const Icon(Icons.refresh),
          style: IconButton.styleFrom(
            backgroundColor: AppTheme.cyanAccent.withOpacity(0.1),
            foregroundColor: AppTheme.cyanAccent,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.cyanAccent),
        ),
      ),
    );
  }

  Widget _buildSystemInfoContent() {
    return Column(
      children: [
        if (ResponsiveUtils.isMobile(context))
          _buildMobileLayout()
        else
          _buildDesktopLayout(),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildSystemInfoSection(),
        const SizedBox(height: 16),
        _buildResourceUsageSection(),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Column(
      children: [
        _buildSystemInfoSection(),
        const SizedBox(height: 16),
        _buildResourceUsageSection(),
      ],
    );
  }

  Widget _buildSystemInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.cyanAccent.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSystemInfoItem(
              'Hostname', systemInfo['hostname']?.toString() ?? 'Unknown'),
          _buildSystemInfoItem(
              'Platform', systemInfo['platform']?.toString() ?? 'Unknown'),
          _buildSystemInfoItem('Architecture',
              systemInfo['architecture']?.toString() ?? 'Unknown'),
          _buildSystemInfoItem(
              'Uptime', systemInfo['uptime']?.toString() ?? 'Unknown',
              isLast: true),
        ],
      ),
    );
  }

  Widget _buildSystemInfoItem(String label, String value,
      {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceUsageSection() {
    final memoryData = systemInfo['memoryUsage'] as Map<String, dynamic>? ?? {};
    final loadData = systemInfo['systemLoad'] as Map<String, dynamic>? ?? {};

    return Row(
      children: [
        Expanded(
          child: _buildResourceCard(
            'Memory Usage',
            '${memoryData['percentage']?.toString() ?? '0'}%',
            '${memoryData['used']?.toString() ?? '0'} / ${memoryData['total']?.toString() ?? '0'}',
            AppTheme.warningYellow,
            Icons.memory,
            memoryData['percentage']?.toDouble() ?? 0.0,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildResourceCard(
            'System Load',
            loadData['current']?.toString() ?? '0',
            'avg: ${loadData['load1']?.toString() ?? '0'} ${loadData['load5']?.toString() ?? '0'} ${loadData['load15']?.toString() ?? '0'}',
            AppTheme.errorRed,
            Icons.speed,
            null,
          ),
        ),
      ],
    );
  }

  Widget _buildResourceCard(String title, String value, String subtitle,
      Color color, IconData icon, double? percentage) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
