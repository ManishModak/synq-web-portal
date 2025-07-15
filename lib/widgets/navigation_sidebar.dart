import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:synq/theme/app_theme.dart';
import 'package:synq/services/api_service.dart';
import 'package:synq/utils/responsive_utils.dart';
import 'package:url_launcher/url_launcher.dart';
// Conditional import for web
import 'dart:html' as html show window;

class NavigationSidebar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onNavigationChanged;

  const NavigationSidebar({
    super.key,
    required this.currentIndex,
    required this.onNavigationChanged,
  });

  @override
  State<NavigationSidebar> createState() => _NavigationSidebarState();
}

class _NavigationSidebarState extends State<NavigationSidebar>
    with AutomaticKeepAliveClientMixin {
  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      label: 'Dashboard',
    ),
    NavigationItem(
      icon: Icons.analytics_outlined,
      selectedIcon: Icons.analytics,
      label: 'Performance',
    ),
    NavigationItem(
      icon: Icons.list_alt_outlined,
      selectedIcon: Icons.list_alt,
      label: 'Logs',
    ),
    NavigationItem(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      label: 'Settings',
    ),
  ];

  final List<SocialLinkItem> _socialLinks = [
    SocialLinkItem(
      icon: Icons.discord,
      label: 'Discord',
      url: 'https://discord.gg/CAgBGjFvTG',
      color: Color(0xFF5865F2),
    ),
    SocialLinkItem(
      icon: Icons.alternate_email,
      label: 'X (Twitter)',
      url: 'https://x.com/multisynq',
      color: Color(0xFF1DA1F2),
    ),
    SocialLinkItem(
      icon: Icons.language,
      label: 'Website',
      url: 'https://multisynq.io/',
      color: AppTheme.cyanAccent,
    ),
    SocialLinkItem(
      icon: Icons.shopping_cart,
      label: 'Shop',
      url: 'https://preorder.startsynqing.com/',
      color: AppTheme.purplePrimary,
    ),
  ];

  Map<String, bool> _connectionStatus = {
    'metrics': false,
    'dashboard': false,
  };
  bool _isCheckingConnection = false;

  @override
  bool get wantKeepAlive => true; // Prevent unnecessary rebuilds

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkConnectionStatus();
        _startConnectionStatusTimer();
      }
    });
  }

  Future<void> _checkConnectionStatus() async {
    if (_isCheckingConnection || !mounted) return;

    setState(() {
      _isCheckingConnection = true;
    });

    try {
      final status = await ApiService.getConnectionStatus();
      if (mounted) {
        setState(() {
          _connectionStatus = status;
          _isCheckingConnection = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _connectionStatus = {
            'metrics': false,
            'dashboard': false,
          };
          _isCheckingConnection = false;
        });
      }
    }
  }

  void _startConnectionStatusTimer() {
    // Check connection status periodically (every 30 seconds)
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        _checkConnectionStatus();
        _startConnectionStatusTimer();
      }
    });
  }

  Future<void> _launchUrl(String url) async {
    if (kIsWeb) {
      // For web, use window.open directly
      html.window.open(url, '_blank');
    } else {
      // For mobile/desktop, use url_launcher
      try {
        final Uri uri = Uri.parse(url);
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } catch (e) {
        debugPrint('Could not launch $url: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    final sidebarWidth = ResponsiveUtils.isMobile(context) ? 250.0 : 280.0;

    return Container(
      width: sidebarWidth,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.surfaceDark.withOpacity(0.95),
            AppTheme.cardDark.withOpacity(0.95),
          ],
        ),
        border: Border(
          right: BorderSide(
            color: AppTheme.purplePrimary.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Logo section
          _buildLogo(context),

          SizedBox(height: ResponsiveUtils.isMobile(context) ? 16 : 32),

          // Navigation items
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.isMobile(context) ? 12 : 16,
              ),
              itemCount: _navigationItems.length,
              itemBuilder: (context, index) {
                return _NavigationItemWidget(
                  item: _navigationItems[index],
                  isSelected: widget.currentIndex == index,
                  onTap: () => widget.onNavigationChanged(index),
                  isMobile: ResponsiveUtils.isMobile(context),
                );
              },
            ),
          ),

          // Social links and Shop section
          _buildSocialLinksSection(context),

          // Divider
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.isMobile(context) ? 12 : 16,
              vertical: ResponsiveUtils.isMobile(context) ? 8 : 12,
            ),
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppTheme.purplePrimary.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Bottom section
          _buildBottomSection(context),
        ],
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        ResponsiveUtils.isMobile(context) ? 12 : 16,
        ResponsiveUtils.isMobile(context) ? 24 : 32,
        ResponsiveUtils.isMobile(context) ? 12 : 16,
        ResponsiveUtils.isMobile(context) ? 12 : 16,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.isMobile(context) ? 12 : 16,
          vertical: ResponsiveUtils.isMobile(context) ? 16 : 20,
        ),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.purplePrimary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: SvgPicture.asset(
            'logo-full.svg',
            height: ResponsiveUtils.isMobile(context) ? 24 : 32,
            colorFilter: const ColorFilter.mode(
              AppTheme.textPrimary,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialLinksSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.isMobile(context) ? 12 : 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Grid layout for social links
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.5,
            children: _socialLinks
                .map((link) => _SocialLinkWidget(
                      item: link,
                      onTap: () => _launchUrl(link.url),
                      isMobile: ResponsiveUtils.isMobile(context),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    final isConnected = _connectionStatus['metrics'] == true ||
        _connectionStatus['dashboard'] == true;

    final connectionText = _getConnectionText();
    final connectionColor = _getConnectionColor();

    return Container(
      padding: ResponsiveUtils.getResponsivePadding(context),
      child: Column(
        children: [
          // Connection status
          Container(
            padding:
                EdgeInsets.all(ResponsiveUtils.isMobile(context) ? 12 : 16),
            decoration: BoxDecoration(
              color: connectionColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: connectionColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                if (_isCheckingConnection)
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(connectionColor),
                    ),
                  )
                else
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: connectionColor,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: connectionColor.withOpacity(0.5),
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
                        connectionText,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: connectionColor,
                              fontWeight: FontWeight.w600,
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                  context, 12),
                            ),
                      ),
                      Text(
                        isConnected ? 'Real-time data' : 'Demo mode',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                  context, 10),
                            ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed:
                      _isCheckingConnection ? null : _checkConnectionStatus,
                  icon: Icon(
                    Icons.refresh,
                    color: connectionColor,
                    size: ResponsiveUtils.isMobile(context) ? 14 : 16,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getConnectionText() {
    if (_isCheckingConnection) return 'Checking...';
    if (_connectionStatus['dashboard'] == true &&
        _connectionStatus['metrics'] == true) {
      return 'Fully Connected';
    } else if (_connectionStatus['dashboard'] == true) {
      return 'Dashboard Connected';
    } else if (_connectionStatus['metrics'] == true) {
      return 'Metrics Connected';
    } else {
      return 'Using Mock Data';
    }
  }

  Color _getConnectionColor() {
    if (_isCheckingConnection) return AppTheme.warningYellow;
    if (_connectionStatus['dashboard'] == true &&
        _connectionStatus['metrics'] == true) {
      return AppTheme.successGreen;
    } else if (_connectionStatus['dashboard'] == true ||
        _connectionStatus['metrics'] == true) {
      return AppTheme.cyanAccent;
    } else {
      return AppTheme.warningYellow;
    }
  }
}

// Social link widget with glowing effects
class _SocialLinkWidget extends StatefulWidget {
  final SocialLinkItem item;
  final VoidCallback onTap;
  final bool isMobile;

  const _SocialLinkWidget({
    required this.item,
    required this.onTap,
    required this.isMobile,
  });

  @override
  State<_SocialLinkWidget> createState() => _SocialLinkWidgetState();
}

class _SocialLinkWidgetState extends State<_SocialLinkWidget>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _animationController.repeat(reverse: true);
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _animationController.stop();
        _animationController.reset();
      },
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: EdgeInsets.symmetric(
                horizontal: widget.isMobile ? 8 : 12,
                vertical: widget.isMobile ? 8 : 10,
              ),
              decoration: BoxDecoration(
                color: _isHovered
                    ? widget.item.color.withOpacity(0.1)
                    : AppTheme.surfaceDark.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _isHovered
                      ? widget.item.color.withOpacity(_glowAnimation.value)
                      : widget.item.color.withOpacity(0.3),
                  width: _isHovered ? 1.5 : 1,
                ),
                boxShadow: _isHovered
                    ? [
                        BoxShadow(
                          color: widget.item.color
                              .withOpacity(_glowAnimation.value * 0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.item.icon,
                    color: _isHovered
                        ? widget.item.color
                        : widget.item.color.withOpacity(0.7),
                    size: widget.isMobile ? 16 : 18,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      widget.item.label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _isHovered
                                ? widget.item.color
                                : widget.item.color.withOpacity(0.7),
                            fontWeight:
                                _isHovered ? FontWeight.w600 : FontWeight.w500,
                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context,
                              widget.isMobile ? 11 : 12,
                            ),
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// Optimized navigation item widget
class _NavigationItemWidget extends StatefulWidget {
  final NavigationItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isMobile;

  const _NavigationItemWidget({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.isMobile,
  });

  @override
  State<_NavigationItemWidget> createState() => _NavigationItemWidgetState();
}

class _NavigationItemWidgetState extends State<_NavigationItemWidget>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Start glowing animation for selected items
    if (widget.isSelected) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_NavigationItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
        _animationController.reset();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: EdgeInsets.symmetric(
                  horizontal: widget.isMobile ? 12 : 16,
                  vertical: widget.isMobile ? 10 : 12,
                ),
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? AppTheme.purplePrimary.withOpacity(0.1)
                      : _isHovered
                          ? AppTheme.purplePrimary.withOpacity(0.05)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: widget.isSelected
                      ? Border.all(
                          color: AppTheme.purplePrimary
                              .withOpacity(_glowAnimation.value),
                          width: 1.5,
                        )
                      : _isHovered
                          ? Border.all(
                              color: AppTheme.purplePrimary,
                              width: 2,
                            )
                          : Border.all(
                              color: Colors.transparent,
                              width: 2,
                            ),
                  boxShadow: widget.isSelected
                      ? [
                          BoxShadow(
                            color: AppTheme.purplePrimary
                                .withOpacity(_glowAnimation.value * 0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.isSelected
                          ? widget.item.selectedIcon
                          : widget.item.icon,
                      color: widget.isSelected
                          ? AppTheme.purplePrimary
                          : _isHovered
                              ? AppTheme.purplePrimary
                              : AppTheme.textSecondary,
                      size: widget.isMobile ? 20 : 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.item.label,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: widget.isSelected
                                ? AppTheme.purplePrimary
                                : _isHovered
                                    ? AppTheme.purplePrimary
                                    : AppTheme.textSecondary,
                            fontWeight: widget.isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context,
                              widget.isMobile ? 14 : 16,
                            ),
                          ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

class SocialLinkItem {
  final IconData icon;
  final String label;
  final String url;
  final Color color;

  SocialLinkItem({
    required this.icon,
    required this.label,
    required this.url,
    required this.color,
  });
}
