import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:synq/theme/app_theme.dart';
import 'package:synq/services/auth_service.dart';
import 'package:synq/main.dart';
import 'package:synq/utils/responsive_utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _ipController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Using localhost to avoid CORS issues
    _ipController.text = 'localhost';
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _ipController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your dashboard password';
      });
      return;
    }

    if (_ipController.text.isEmpty) {
      _ipController.text = 'localhost'; // Default to localhost
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Update the password in AuthService
      AuthService.updatePassword(_passwordController.text);

      // Update the API endpoints (always localhost to avoid CORS)
      await AuthService.updateApiEndpoints('localhost');

      // Test the connection
      final isConnected = await AuthService.testConnection();

      if (isConnected) {
        // Navigate to main screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        setState(() {
          _errorMessage =
              'Unable to connect to SynqBox. Please check your IP address and password.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Connection failed: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A0A0A),
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: ResponsiveUtils.getResponsivePadding(context),
              child: Card(
                elevation: 20,
                shadowColor: AppTheme.purplePrimary.withOpacity(0.3),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: ResponsiveUtils.isMobile(context) ? 350 : 400,
                  ),
                  padding: EdgeInsets.all(
                    ResponsiveUtils.isMobile(context) ? 24 : 40,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo
                      Container(
                        width: ResponsiveUtils.isMobile(context) ? 100 : 120,
                        height: ResponsiveUtils.isMobile(context) ? 100 : 120,
                        padding: EdgeInsets.all(
                          ResponsiveUtils.isMobile(context) ? 16 : 20,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceDark,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.purplePrimary.withOpacity(0.2),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.purplePrimary.withOpacity(0.1),
                              blurRadius: 20,
                              spreadRadius: 0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: SvgPicture.asset(
                          'logo-full.svg',
                          colorFilter: const ColorFilter.mode(
                            AppTheme.textPrimary,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      SizedBox(
                          height: ResponsiveUtils.isMobile(context) ? 24 : 32),

                      // Title
                      Text(
                        'SynqBox Portal',
                        style: AppTheme.darkTheme.textTheme.headlineLarge
                            ?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context, 24),
                        ),
                      ),
                      SizedBox(
                          height: ResponsiveUtils.isMobile(context) ? 6 : 8),
                      Text(
                        'Connect to your SynqBox dashboard',
                        style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                          color: AppTheme.textSecondary,
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context, 14),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                          height: ResponsiveUtils.isMobile(context) ? 32 : 40),

                      // Connection Field
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.purplePrimary.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: _ipController,
                          decoration: InputDecoration(
                            labelText: 'SynqBox Connection',
                            prefixIcon: Icon(
                              Icons.computer,
                              color: AppTheme.purplePrimary.withOpacity(0.7),
                            ),
                            errorText: _errorMessage?.contains('IP') == true
                                ? _errorMessage
                                : null,
                            floatingLabelBehavior: FloatingLabelBehavior.auto,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          keyboardType: TextInputType.text,
                          onSubmitted: (_) => _login(),
                          readOnly: true,
                        ),
                      ),
                      SizedBox(
                          height: ResponsiveUtils.isMobile(context) ? 16 : 20),

                      // Password Field
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.purplePrimary.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Dashboard Password',
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: AppTheme.purplePrimary.withOpacity(0.7),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppTheme.textSecondary,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            errorText:
                                _errorMessage?.contains('password') == true
                                    ? _errorMessage
                                    : null,
                            floatingLabelBehavior: FloatingLabelBehavior.auto,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal:
                                  ResponsiveUtils.isMobile(context) ? 12 : 16,
                              vertical:
                                  ResponsiveUtils.isMobile(context) ? 14 : 16,
                            ),
                          ),
                          obscureText: _obscurePassword,
                          onSubmitted: (_) => _login(),
                        ),
                      ),
                      SizedBox(
                          height: ResponsiveUtils.isMobile(context) ? 10 : 12),

                      // Help Text
                      Container(
                        padding: EdgeInsets.all(
                          ResponsiveUtils.isMobile(context) ? 10 : 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.cyanAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.cyanAccent.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppTheme.cyanAccent,
                              size: ResponsiveUtils.isMobile(context) ? 14 : 16,
                            ),
                            SizedBox(
                                width:
                                    ResponsiveUtils.isMobile(context) ? 6 : 8),
                            Expanded(
                              child: Text(
                                'Find your password in ~/.synchronizer-cli/config.json',
                                style: AppTheme.darkTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: AppTheme.cyanAccent,
                                  fontSize:
                                      ResponsiveUtils.getResponsiveFontSize(
                                          context, 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                          height: ResponsiveUtils.isMobile(context) ? 24 : 32),

                      // Error Message
                      if (_errorMessage != null &&
                          !_errorMessage!.contains('IP') &&
                          !_errorMessage!.contains('password'))
                        Container(
                          padding: EdgeInsets.all(
                            ResponsiveUtils.isMobile(context) ? 12 : 16,
                          ),
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
                                Icons.error_outline,
                                color: AppTheme.errorRed,
                                size:
                                    ResponsiveUtils.isMobile(context) ? 18 : 20,
                              ),
                              SizedBox(
                                  width: ResponsiveUtils.isMobile(context)
                                      ? 6
                                      : 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: AppTheme.darkTheme.textTheme.bodyMedium
                                      ?.copyWith(
                                    color: AppTheme.errorRed,
                                    fontSize:
                                        ResponsiveUtils.getResponsiveFontSize(
                                            context, 14),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (_errorMessage != null)
                        SizedBox(
                            height:
                                ResponsiveUtils.isMobile(context) ? 16 : 20),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        child: Container(
                          height: ResponsiveUtils.isMobile(context) ? 46 : 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                AppTheme.purplePrimary,
                                AppTheme.purplePrimary.withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.purplePrimary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    width: ResponsiveUtils.isMobile(context)
                                        ? 18
                                        : 20,
                                    height: ResponsiveUtils.isMobile(context)
                                        ? 18
                                        : 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : Text(
                                    'Connect to SynqBox',
                                    style: AppTheme
                                        .darkTheme.textTheme.bodyLarge
                                        ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize:
                                          ResponsiveUtils.getResponsiveFontSize(
                                              context, 16),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
