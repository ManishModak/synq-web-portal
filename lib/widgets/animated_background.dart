import 'package:flutter/material.dart';
import 'package:synq/theme/app_theme.dart';
import 'dart:math' as math;

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  final int _particleCount = 6;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controllers = List.generate(_particleCount, (index) {
      return AnimationController(
        duration: Duration(seconds: 8 + (index * 2)),
        vsync: this,
      );
    });

    _animations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0,
        end: 2 * math.pi,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.linear));
    }).toList();

    // Start animations with different delays
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 800), () {
        _controllers[i].repeat();
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: [
          // Background gradient overlay
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topRight,
                radius: 1.5,
                colors: [
                  Color(0x10A78BFA),
                  Color(0x05A78BFA),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Animated floating particles
          ...List.generate(_particleCount, (index) {
            return AnimatedBuilder(
              animation: _animations[index],
              builder: (context, child) {
                return _buildFloatingParticle(index, _animations[index].value);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFloatingParticle(int index, double animationValue) {
    final colors = [
      AppTheme.purplePrimary,
      AppTheme.cyanAccent,
      AppTheme.blueAccent,
      AppTheme.purpleLight,
      AppTheme.cyanLight,
      AppTheme.successGreen,
    ];

    final icons = [
      Icons.code,
      Icons.wifi,
      Icons.speed,
      Icons.computer,
      Icons.storage,
      Icons.security,
    ];

    final baseRadius = 100.0 + (index * 50.0);
    final centerX = 0.2 + (index * 0.15);
    final centerY = 0.3 + (index * 0.1);

    final x = centerX + (math.cos(animationValue) * baseRadius / 1000);
    final y = centerY + (math.sin(animationValue) * baseRadius / 1000);

    return Positioned(
      left: MediaQuery.of(context).size.width * x,
      top: MediaQuery.of(context).size.height * y,
      child: Container(
        width: 60 + (index * 10),
        height: 60 + (index * 10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              colors[index % colors.length].withOpacity(0.3),
              colors[index % colors.length].withOpacity(0.1),
              colors[index % colors.length].withOpacity(0.05),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: colors[index % colors.length].withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Icon(
          icons[index % icons.length],
          color: colors[index % colors.length].withOpacity(0.8),
          size: 24 + (index * 2),
        ),
      ),
    );
  }
}
