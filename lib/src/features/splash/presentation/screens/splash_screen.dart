// ignore_for_file: use_decorated_box, depend_on_referenced_packages, prefer_const_constructors, prefer_int_literals

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 2500), () {
      FlutterNativeSplash.remove();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0A0A0A),
                Color(0xFF1A1A1A),
                Color(0xFF0D0D0D),
              ],
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  return Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF00FF88).withOpacity(0.15 * _glowAnimation.value),
                          const Color(0xFF00FF88).withOpacity(0.05 * _glowAnimation.value),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  );
                },
              ),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _FLogo(glowIntensity: _glowAnimation.value),
                          const SizedBox(height: 40),
                          Opacity(
                            opacity: _fadeAnimation.value,
                            child: const Text(
                              'Fit Track',
                              style: TextStyle(
                                fontFamily: 'SF Pro Display',
                                fontSize: 24,
                                fontWeight: FontWeight.w300,
                                color: Colors.white70,
                                letterSpacing: 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FLogo extends StatelessWidget {
  final double glowIntensity;

  const _FLogo({required this.glowIntensity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF00FF88).withOpacity(0.4 * glowIntensity),
            blurRadius: 60,
            spreadRadius: 20,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.15),
              Colors.white.withOpacity(0.05),
              Colors.white.withOpacity(0.1),
            ],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: CustomPaint(
            painter: _FLogoPainter(glowIntensity: glowIntensity),
          ),
        ),
      ),
    );
  }
}

class _FLogoPainter extends CustomPainter {
  final double glowIntensity;

  _FLogoPainter({required this.glowIntensity});

  @override
  void paint(Canvas canvas, Size size) {
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.12
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * 0.05)
      ..color = Color(0xFF00FF88).withOpacity(0.6 * glowIntensity);

    final mainPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = Colors.white.withOpacity(0.9);

    final centerY = size.height / 2;
    final letterHeight = size.height * 0.6;
    final letterWidth = size.width * 0.5;
    final startX = size.width * 0.22;
    final strokeY = centerY - letterHeight / 2;

    final path = Path()
      ..moveTo(startX, strokeY)
      ..lineTo(startX, strokeY + letterHeight)
      ..moveTo(startX, strokeY)
      ..lineTo(startX + letterWidth, strokeY)
      ..moveTo(startX + letterWidth * 0.15, strokeY + letterHeight * 0.4)
      ..lineTo(startX + letterWidth, strokeY + letterHeight * 0.4)
      ..moveTo(startX + letterWidth * 0.15, strokeY + letterHeight * 0.75)
      ..lineTo(startX + letterWidth * 0.6, strokeY + letterHeight * 0.75);

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, mainPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}