import 'package:flutter/material.dart';
import 'package:synq/theme/app_theme.dart';
import 'package:synq/screens/dashboard_screen.dart';
import 'package:synq/screens/performance_screen.dart';
import 'package:synq/screens/logs_screen.dart';
import 'package:synq/screens/settings_screen.dart';
import 'package:synq/screens/login_screen.dart';
import 'package:synq/widgets/animated_background.dart';
import 'package:synq/widgets/navigation_sidebar.dart';
import 'package:synq/services/api_service.dart';
import 'package:synq/utils/responsive_utils.dart';

void main() {
  // Ensure real API calls by default
  ApiService.setMockDataMode(false);

  // Initialize API endpoints
  ApiService.updateEndpoints('localhost');

  runApp(const SynqBoxApp());
}

class SynqBoxApp extends StatelessWidget {
  const SynqBoxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SynqBox Portal',
      theme: AppTheme.darkTheme,
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentScreenIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const PerformanceScreen(),
    const LogsScreen(),
    const SettingsScreen(),
  ];

  final List<String> _screenTitles = [
    'Dashboard',
    'Performance',
    'Logs',
    'Settings',
  ];

  void _onNavigationChanged(int index) {
    setState(() {
      _currentScreenIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Stack(
          children: [
            // Animated background with floating elements
            const AnimatedBackground(),

            // Main content - responsive layout
            ResponsiveUtils.isMobile(context)
                ? _buildMobileLayout(context)
                : _buildDesktopLayout(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryDark.withOpacity(0.9),
        title: Text(
          _screenTitles[_currentScreenIndex],
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(
              Icons.menu,
              color: AppTheme.textPrimary,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Container(
        width: 280,
        child: NavigationSidebar(
          currentIndex: _currentScreenIndex,
          onNavigationChanged: (index) {
            _onNavigationChanged(index);
            Navigator.pop(context); // Close drawer
          },
        ),
      ),
      body: _screens[_currentScreenIndex],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        // Navigation sidebar
        NavigationSidebar(
          currentIndex: _currentScreenIndex,
          onNavigationChanged: _onNavigationChanged,
        ),

        // Main content area
        Expanded(
          child: _screens[_currentScreenIndex],
        ),
      ],
    );
  }
}
