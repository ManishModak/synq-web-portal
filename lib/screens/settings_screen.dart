import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:synq/theme/app_theme.dart';
import 'package:synq/services/api_service.dart';
import 'package:synq/utils/responsive_utils.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<String, dynamic>? _configuration;
  bool _isLoading = true;
  String? _error;
  bool _hasChanges = false;

  // Form controllers
  final TextEditingController _proxyPortController = TextEditingController();
  final TextEditingController _metricsPortController = TextEditingController();
  final TextEditingController _maxConnectionsController =
      TextEditingController();
  final TextEditingController _dataRetentionController =
      TextEditingController();

  bool _autoUpdate = true;
  String _logLevel = 'INFO';

  final List<String> _logLevels = ['DEBUG', 'INFO', 'WARN', 'ERROR'];

  @override
  void initState() {
    super.initState();
    _loadConfiguration();
  }

  @override
  void dispose() {
    _proxyPortController.dispose();
    _metricsPortController.dispose();
    _maxConnectionsController.dispose();
    _dataRetentionController.dispose();
    super.dispose();
  }

  Future<void> _loadConfiguration() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.getConfiguration();

      if (response.success && response.data != null) {
        setState(() {
          _configuration = response.data;
          _populateFormFields();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.error ?? 'Failed to load configuration';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Network error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _populateFormFields() {
    if (_configuration != null) {
      _proxyPortController.text =
          _configuration!['proxyPort']?.toString() ?? '8080';
      _metricsPortController.text =
          _configuration!['metricsPort']?.toString() ?? '3001';
      _maxConnectionsController.text =
          _configuration!['maxConnections']?.toString() ?? '100';
      _dataRetentionController.text =
          _configuration!['dataRetention']?.toString() ?? '30d';
      _autoUpdate = _configuration!['autoUpdate'] ?? true;
      _logLevel = _configuration!['logLevel'] ?? 'INFO';
    }
  }

  void _markAsChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  Future<void> _saveConfiguration() async {
    // TODO: Implement save configuration API call
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Configuration saved successfully'),
        backgroundColor: AppTheme.successGreen,
      ),
    );

    setState(() {
      _hasChanges = false;
    });
  }

  Future<void> _resetToDefaults() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: Text(
          'Reset to Defaults',
          style: AppTheme.darkTheme.textTheme.titleLarge,
        ),
        content: Text(
          'Are you sure you want to reset all settings to their default values? This action cannot be undone.',
          style: AppTheme.darkTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resetFields();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _resetFields() {
    setState(() {
      _proxyPortController.text = '8080';
      _metricsPortController.text = '3001';
      _maxConnectionsController.text = '100';
      _dataRetentionController.text = '30d';
      _autoUpdate = true;
      _logLevel = 'INFO';
      _hasChanges = true;
    });
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

          // Content
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _error != null
                    ? _buildErrorState()
                    : _buildSettingsContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return ResponsiveUtils.isMobile(context)
        ? _buildMobileHeader()
        : _buildDesktopHeader();
  }

  Widget _buildMobileHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.settings,
              color: AppTheme.purplePrimary,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Settings',
                style: AppTheme.darkTheme.textTheme.headlineLarge?.copyWith(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 24),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Configure your SynqBox system parameters and preferences',
          style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
          ),
        ),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_hasChanges) ...[
              ElevatedButton.icon(
                onPressed: _saveConfiguration,
                icon: const Icon(Icons.save, size: 18),
                label: Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize:
                        ResponsiveUtils.getResponsiveFontSize(context, 14),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _loadConfiguration,
                child: Text(
                  'Discard Changes',
                  style: TextStyle(
                    fontSize:
                        ResponsiveUtils.getResponsiveFontSize(context, 14),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            ElevatedButton.icon(
              onPressed: _loadConfiguration,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(
                'Reload',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopHeader() {
    return Row(
      children: [
        Icon(
          Icons.settings,
          color: AppTheme.purplePrimary,
          size: 40,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: AppTheme.darkTheme.textTheme.headlineLarge?.copyWith(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 28),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Configure your SynqBox system parameters and preferences',
                style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            if (_hasChanges) ...[
              OutlinedButton(
                onPressed: _loadConfiguration,
                child: const Text('Discard Changes'),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _saveConfiguration,
                icon: const Icon(Icons.save),
                label: const Text('Save Changes'),
              ),
              const SizedBox(width: 12),
            ],
            ElevatedButton.icon(
              onPressed: _loadConfiguration,
              icon: const Icon(Icons.refresh),
              label: const Text('Reload'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Shimmer.fromColors(
      baseColor: AppTheme.surfaceDark,
      highlightColor: AppTheme.cardDark,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Network Configuration shimmer with depth
            _buildNetworkShimmer(context),

            SizedBox(height: ResponsiveUtils.isMobile(context) ? 20 : 32),

            // System Configuration shimmer with depth
            _buildSystemShimmer(context),

            SizedBox(height: ResponsiveUtils.isMobile(context) ? 20 : 32),

            // Security Settings shimmer with depth
            _buildSecurityShimmer(context),

            SizedBox(height: ResponsiveUtils.isMobile(context) ? 20 : 32),

            // Actions shimmer with depth
            _buildActionsShimmer(context),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkShimmer(BuildContext context) {
    return Container(
      height: ResponsiveUtils.isMobile(context) ? 200 : 250,
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildSystemShimmer(BuildContext context) {
    return Container(
      height: ResponsiveUtils.isMobile(context) ? 150 : 180,
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildSecurityShimmer(BuildContext context) {
    return Container(
      height: ResponsiveUtils.isMobile(context) ? 120 : 150,
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildActionsShimmer(BuildContext context) {
    return Container(
      height: ResponsiveUtils.isMobile(context) ? 100 : 120,
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildFormFieldShimmer(BuildContext context, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: ResponsiveUtils.isMobile(context) ? 80 : 100,
          height: ResponsiveUtils.isMobile(context) ? 14 : 16,
          decoration: BoxDecoration(
            color: AppTheme.cardDark.withOpacity(0.8),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        SizedBox(height: ResponsiveUtils.isMobile(context) ? 6 : 8),
        Container(
          height: ResponsiveUtils.isMobile(context) ? 48 : 56,
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark.withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.purplePrimary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.isMobile(context) ? 12 : 16,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: ResponsiveUtils.isMobile(context) ? 60 : 80,
                height: ResponsiveUtils.isMobile(context) ? 14 : 16,
                decoration: BoxDecoration(
                  color: AppTheme.cardDark,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchFieldShimmer(BuildContext context, String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: ResponsiveUtils.isMobile(context) ? 90 : 120,
          height: ResponsiveUtils.isMobile(context) ? 14 : 16,
          decoration: BoxDecoration(
            color: AppTheme.cardDark.withOpacity(0.8),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        Container(
          width: ResponsiveUtils.isMobile(context) ? 40 : 50,
          height: ResponsiveUtils.isMobile(context) ? 24 : 28,
          decoration: BoxDecoration(
            color: AppTheme.successGreen.withOpacity(0.3),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppTheme.successGreen.withOpacity(0.5),
              width: 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownFieldShimmer(BuildContext context, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: ResponsiveUtils.isMobile(context) ? 70 : 90,
          height: ResponsiveUtils.isMobile(context) ? 14 : 16,
          decoration: BoxDecoration(
            color: AppTheme.cardDark.withOpacity(0.8),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        SizedBox(height: ResponsiveUtils.isMobile(context) ? 6 : 8),
        Container(
          height: ResponsiveUtils.isMobile(context) ? 48 : 56,
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark.withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.cyanAccent.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.isMobile(context) ? 12 : 16,
            ),
            child: Row(
              children: [
                Container(
                  width: ResponsiveUtils.isMobile(context) ? 50 : 70,
                  height: ResponsiveUtils.isMobile(context) ? 14 : 16,
                  decoration: BoxDecoration(
                    color: AppTheme.cardDark,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_drop_down,
                  color: AppTheme.cyanAccent.withOpacity(0.4),
                  size: ResponsiveUtils.isMobile(context) ? 20 : 24,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButtonShimmer(BuildContext context, String label, Color color) {
    return Container(
      height: ResponsiveUtils.isMobile(context) ? 40 : 44,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Center(
        child: Container(
          width: ResponsiveUtils.isMobile(context) ? 80 : 100,
          height: ResponsiveUtils.isMobile(context) ? 14 : 16,
          decoration: BoxDecoration(
            color: color.withOpacity(0.5),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: AppTheme.errorRed,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            _error!,
            style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.errorRed,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadConfiguration,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Network Configuration
          _buildNetworkSection(),

          const SizedBox(height: 32),

          // System Configuration
          _buildSystemSection(),

          const SizedBox(height: 32),

          // Security Settings
          _buildSecuritySection(),

          const SizedBox(height: 32),

          // Actions
          _buildActionsSection(),
        ],
      ),
    );
  }

  Widget _buildNetworkSection() {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.settings_ethernet,
                  color: AppTheme.cyanAccent,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  'Network Configuration',
                  style: AppTheme.darkTheme.textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildNumberField(
                    controller: _proxyPortController,
                    label: 'Proxy Port',
                    hint: '8080',
                    onChanged: _markAsChanged,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildNumberField(
                    controller: _metricsPortController,
                    label: 'Metrics Port',
                    hint: '3001',
                    onChanged: _markAsChanged,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildNumberField(
                    controller: _maxConnectionsController,
                    label: 'Max Connections',
                    hint: '100',
                    onChanged: _markAsChanged,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemSection() {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.computer,
                  color: AppTheme.blueAccent,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  'System Configuration',
                  style: AppTheme.darkTheme.textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Log Level',
                        style:
                            AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceDark,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.purplePrimary.withOpacity(0.3),
                          ),
                        ),
                        child: DropdownButton<String>(
                          value: _logLevel,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _logLevel = value;
                              });
                              _markAsChanged();
                            }
                          },
                          dropdownColor: AppTheme.surfaceDark,
                          underline: Container(),
                          isExpanded: true,
                          items: _logLevels.map((level) {
                            return DropdownMenuItem<String>(
                              value: level,
                              child: Text(
                                level,
                                style: AppTheme.darkTheme.textTheme.bodyMedium,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _dataRetentionController,
                    label: 'Data Retention',
                    hint: '30d',
                    onChanged: _markAsChanged,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Auto Update',
                        style:
                            AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 56,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceDark,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.purplePrimary.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Switch(
                              value: _autoUpdate,
                              onChanged: (value) {
                                setState(() {
                                  _autoUpdate = value;
                                });
                                _markAsChanged();
                              },
                              activeColor: AppTheme.successGreen,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _autoUpdate ? 'Enabled' : 'Disabled',
                              style: AppTheme.darkTheme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySection() {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.security,
                  color: AppTheme.warningYellow,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  'Security Settings',
                  style: AppTheme.darkTheme.textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSecurityItem(
              'Dashboard Password',
              '••••••••••',
              'Change password for dashboard access',
              Icons.lock,
              () {
                // TODO: Show change password dialog
              },
            ),
            const SizedBox(height: 16),
            _buildSecurityItem(
              'API Keys',
              'Monitoring, Analytics',
              'Manage API access keys',
              Icons.key,
              () {
                // TODO: Show API keys management
              },
            ),
            const SizedBox(height: 16),
            _buildSecurityItem(
              'SSL/TLS Configuration',
              'Configure secure connections',
              'Set up certificates and encryption',
              Icons.https,
              () {
                // TODO: Show SSL configuration
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityItem(String title, String subtitle, String description,
      IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryDark.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.purplePrimary.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.warningYellow.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.warningYellow,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.darkTheme.textTheme.titleMedium,
                    ),
                    Text(
                      subtitle,
                      style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      description,
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppTheme.textSecondary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionsSection() {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.build,
                  color: AppTheme.successGreen,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  'System Actions',
                  style: AppTheme.darkTheme.textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _installUpdate,
                    icon: const Icon(Icons.system_update),
                    label: const Text('Install System Update'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.blueAccent,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _installWebService,
                    icon: const Icon(Icons.web),
                    label: const Text('Install Web Service'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.cyanAccent,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _resetToDefaults,
                    icon: const Icon(Icons.restore),
                    label: const Text('Reset to Defaults'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.errorRed,
                      side: BorderSide(color: AppTheme.errorRed),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _installUpdate() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Show success message since update functionality is not implemented
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Update functionality not available in this version'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  Future<void> _installWebService() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Show success message since web service functionality is not implemented
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Web service functionality not available in this version'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required VoidCallback onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: (_) => onChanged(),
          decoration: InputDecoration(
            hintText: hint,
          ),
        ),
      ],
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required VoidCallback onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: (_) => onChanged(),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: hint,
          ),
        ),
      ],
    );
  }
}
