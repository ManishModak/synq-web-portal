import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:synq/theme/app_theme.dart';
import 'package:synq/services/api_service.dart';
import 'package:synq/utils/responsive_utils.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  List<String> _logs = [];
  List<String> _filteredLogs = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  String _selectedLogLevel = 'ALL';
  bool _autoRefresh = false;

  final List<String> _logLevels = ['ALL', 'INFO', 'WARN', 'ERROR'];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLogs() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.getSystemLogs();

      if (response.success && response.data != null) {
        final logsData = response.data!['logs'] as List<dynamic>?;
        setState(() {
          _logs = logsData?.map((log) => log.toString()).toList() ?? [];
          _filterLogs();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.error ?? 'Failed to load logs';
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

  void _filterLogs() {
    setState(() {
      _filteredLogs = _logs.where((log) {
        // Filter by log level
        bool matchesLevel =
            _selectedLogLevel == 'ALL' || log.contains(_selectedLogLevel);

        // Filter by search query
        bool matchesSearch = _searchQuery.isEmpty ||
            log.toLowerCase().contains(_searchQuery.toLowerCase());

        return matchesLevel && matchesSearch;
      }).toList();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _filterLogs();
  }

  void _onLogLevelChanged(String? level) {
    if (level != null) {
      setState(() {
        _selectedLogLevel = level;
      });
      _filterLogs();
    }
  }

  Color _getLogLevelColor(String log) {
    if (log.contains('ERROR')) {
      return AppTheme.errorRed;
    } else if (log.contains('WARN')) {
      return AppTheme.warningYellow;
    } else if (log.contains('INFO')) {
      return AppTheme.successGreen;
    } else {
      return AppTheme.textSecondary;
    }
  }

  IconData _getLogLevelIcon(String log) {
    if (log.contains('ERROR')) {
      return Icons.error;
    } else if (log.contains('WARN')) {
      return Icons.warning;
    } else if (log.contains('INFO')) {
      return Icons.info;
    } else {
      return Icons.notes;
    }
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

          SizedBox(height: ResponsiveUtils.isMobile(context) ? 16 : 24),

          // Filters and Controls
          _buildFiltersAndControls(),

          SizedBox(height: ResponsiveUtils.isMobile(context) ? 16 : 24),

          // Content
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _error != null
                    ? _buildErrorState()
                    : _buildLogsContent(),
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
              Icons.list_alt,
              color: AppTheme.blueAccent,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'System Logs',
                style: AppTheme.darkTheme.textTheme.headlineLarge?.copyWith(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 24),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Real-time system activity and diagnostic information',
          style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            // Auto-refresh toggle
            Row(
              children: [
                Switch(
                  value: _autoRefresh,
                  onChanged: (value) {
                    setState(() {
                      _autoRefresh = value;
                    });
                    // TODO: Implement auto-refresh timer
                  },
                  activeColor: AppTheme.successGreen,
                ),
                const SizedBox(width: 8),
                Text(
                  'Auto-refresh',
                  style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                    fontSize:
                        ResponsiveUtils.getResponsiveFontSize(context, 12),
                  ),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _loadLogs,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(
                'Refresh',
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
          Icons.list_alt,
          color: AppTheme.blueAccent,
          size: 40,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'System Logs',
                style: AppTheme.darkTheme.textTheme.headlineLarge?.copyWith(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 28),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Real-time system activity and diagnostic information',
                style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            // Auto-refresh toggle
            Row(
              children: [
                Switch(
                  value: _autoRefresh,
                  onChanged: (value) {
                    setState(() {
                      _autoRefresh = value;
                    });
                    // TODO: Implement auto-refresh timer
                  },
                  activeColor: AppTheme.successGreen,
                ),
                const SizedBox(width: 8),
                Text(
                  'Auto-refresh',
                  style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                    fontSize:
                        ResponsiveUtils.getResponsiveFontSize(context, 14),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: _loadLogs,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFiltersAndControls() {
    return ResponsiveUtils.isMobile(context)
        ? _buildMobileFiltersAndControls()
        : _buildDesktopFiltersAndControls();
  }

  Widget _buildMobileFiltersAndControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search box
        TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Search logs...',
            prefixIcon: Icon(
              Icons.search,
              color: AppTheme.textSecondary,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: AppTheme.textSecondary),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                  )
                : null,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            // Log level filter
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.purplePrimary.withOpacity(0.3),
                  ),
                ),
                child: DropdownButton<String>(
                  value: _selectedLogLevel,
                  onChanged: _onLogLevelChanged,
                  dropdownColor: AppTheme.surfaceDark,
                  underline: Container(),
                  isExpanded: true,
                  items: _logLevels.map((level) {
                    return DropdownMenuItem<String>(
                      value: level,
                      child: Text(
                        level,
                        style:
                            AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context, 14),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Stats
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.purplePrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.purplePrimary.withOpacity(0.3),
                ),
              ),
              child: Text(
                '${_filteredLogs.length} / ${_logs.length}',
                style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.purplePrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopFiltersAndControls() {
    return Row(
      children: [
        // Search box
        Expanded(
          flex: 2,
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search logs...',
              prefixIcon: Icon(
                Icons.search,
                color: AppTheme.textSecondary,
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: AppTheme.textSecondary),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Log level filter
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.purplePrimary.withOpacity(0.3),
            ),
          ),
          child: DropdownButton<String>(
            value: _selectedLogLevel,
            onChanged: _onLogLevelChanged,
            dropdownColor: AppTheme.surfaceDark,
            underline: Container(),
            items: _logLevels.map((level) {
              return DropdownMenuItem<String>(
                value: level,
                child: Text(
                  level,
                  style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                    fontSize:
                        ResponsiveUtils.getResponsiveFontSize(context, 14),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(width: 16),

        // Stats
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.purplePrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.purplePrimary.withOpacity(0.3),
            ),
          ),
          child: Text(
            '${_filteredLogs.length} / ${_logs.length} logs',
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.purplePrimary,
              fontWeight: FontWeight.w600,
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Shimmer.fromColors(
      baseColor: AppTheme.surfaceDark,
      highlightColor: AppTheme.cardDark,
      child: Card(
        child: Container(
          padding: ResponsiveUtils.getResponsivePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Log header shimmer with depth
              _buildLogHeaderShimmer(context),

              // Log entries shimmer with depth
              Expanded(
                child: _buildLogEntriesShimmer(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogHeaderShimmer(BuildContext context) {
    return ResponsiveUtils.isMobile(context)
        ? Column(
            children: [
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          )
        : Container(
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(8),
            ),
          );
  }

  Widget _buildLogEntriesShimmer(BuildContext context) {
    return Column(
      children: List.generate(5, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }),
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
            size: ResponsiveUtils.isMobile(context) ? 48 : 64,
          ),
          SizedBox(height: ResponsiveUtils.isMobile(context) ? 12 : 16),
          Text(
            _error!,
            style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.errorRed,
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveUtils.isMobile(context) ? 16 : 24),
          ElevatedButton(
            onPressed: _loadLogs,
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

  Widget _buildLogsContent() {
    if (_filteredLogs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              color: AppTheme.textMuted,
              size: ResponsiveUtils.isMobile(context) ? 48 : 64,
            ),
            SizedBox(height: ResponsiveUtils.isMobile(context) ? 12 : 16),
            Text(
              _logs.isEmpty
                  ? 'No logs available'
                  : 'No logs match the current filter',
              style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.textMuted,
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
              ),
            ),
            if (_logs.isNotEmpty) ...[
              SizedBox(height: ResponsiveUtils.isMobile(context) ? 6 : 8),
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                    _selectedLogLevel = 'ALL';
                  });
                  _filterLogs();
                },
                child: Text(
                  'Clear filters',
                  style: TextStyle(
                    fontSize:
                        ResponsiveUtils.getResponsiveFontSize(context, 14),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Card(
      child: Container(
        padding: ResponsiveUtils.getResponsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Log header
            Container(
              padding:
                  EdgeInsets.all(ResponsiveUtils.isMobile(context) ? 12 : 16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: ResponsiveUtils.isMobile(context)
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recent Activity',
                          style: AppTheme.darkTheme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context, 16),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Last updated: ${DateTime.now().toString().substring(11, 19)}',
                          style:
                              AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textMuted,
                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context, 12),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Text(
                          'Recent Activity',
                          style: AppTheme.darkTheme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context, 18),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Last updated: ${DateTime.now().toString().substring(11, 19)}',
                          style:
                              AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textMuted,
                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context, 12),
                          ),
                        ),
                      ],
                    ),
            ),

            // Logs list
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.primaryDark,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: ListView.builder(
                  itemCount: _filteredLogs.length,
                  itemBuilder: (context, index) {
                    final log = _filteredLogs[
                        _filteredLogs.length - 1 - index]; // Reverse order
                    return _buildLogEntry(log, index);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogEntry(String log, int index) {
    final color = _getLogLevelColor(log);
    final icon = _getLogLevelIcon(log);

    // Parse log components
    final parts = log.split(' ');
    final timestamp = parts.length >= 2 ? '${parts[0]} ${parts[1]}' : '';
    final level = parts.length >= 3 ? parts[2] : '';
    final message = parts.length > 3 ? parts.sublist(3).join(' ') : log;

    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: Show detailed log information
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.isMobile(context) ? 12 : 16,
              vertical: ResponsiveUtils.isMobile(context) ? 10 : 12,
            ),
            decoration: BoxDecoration(
              color: index % 2 == 0
                  ? AppTheme.surfaceDark.withOpacity(0.3)
                  : Colors.transparent,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Level indicator
                Container(
                  width: 4,
                  height: ResponsiveUtils.isMobile(context) ? 35 : 40,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                SizedBox(width: ResponsiveUtils.isMobile(context) ? 8 : 12),

                // Icon
                Icon(
                  icon,
                  color: color,
                  size: ResponsiveUtils.isMobile(context) ? 16 : 20,
                ),

                SizedBox(width: ResponsiveUtils.isMobile(context) ? 8 : 12),

                // Log content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Timestamp and level
                      Row(
                        children: [
                          if (timestamp.isNotEmpty) ...[
                            Text(
                              timestamp,
                              style: AppTheme.darkTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme.textMuted,
                                fontFamily: 'monospace',
                                fontSize: ResponsiveUtils.getResponsiveFontSize(
                                    context, 11),
                              ),
                            ),
                            SizedBox(
                                width:
                                    ResponsiveUtils.isMobile(context) ? 8 : 12),
                          ],
                          if (level.isNotEmpty)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                    ResponsiveUtils.isMobile(context) ? 6 : 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                level,
                                style: AppTheme.darkTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      ResponsiveUtils.getResponsiveFontSize(
                                          context, 9),
                                ),
                              ),
                            ),
                        ],
                      ),

                      SizedBox(
                          height: ResponsiveUtils.isMobile(context) ? 2 : 4),

                      // Message
                      Text(
                        message,
                        style:
                            AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textPrimary,
                          fontFamily: 'monospace',
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context, 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
