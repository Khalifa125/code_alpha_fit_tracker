// ignore_for_file: deprecated_member_use

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';

class AnimatedProgressRing extends StatefulWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final List<Color>? gradientColors;
  final Color? backgroundColor;
  final Widget? child;
  final Duration duration;
  final String? label;
  final String? value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  const AnimatedProgressRing({
    super.key,
    required this.progress,
    this.size = 100,
    this.strokeWidth = 8,
    this.gradientColors,
    this.backgroundColor,
    this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.label,
    this.value,
    this.labelStyle,
    this.valueStyle,
  });

  @override
  State<AnimatedProgressRing> createState() => _AnimatedProgressRingState();
}

class _AnimatedProgressRingState extends State<AnimatedProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousProgress = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = Tween<double>(begin: 0, end: widget.progress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _previousProgress = _animation.value;
      _animation = Tween<double>(
        begin: _previousProgress,
        end: widget.progress,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _ProgressRingPainter(
                  progress: _animation.value.clamp(0.0, 1.0),
                  strokeWidth: widget.strokeWidth,
                  backgroundColor: widget.backgroundColor ?? (isDark ? FitColors.borderDark : FitColors.borderLight),
                  gradientColors: widget.gradientColors ?? [FitColors.neonGreen, FitColors.neonGreen],
                ),
              ),
              if (widget.child != null) widget.child!,
              if (widget.label != null || widget.value != null)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.value != null)
                      Text(
                        widget.value!,
                        style: widget.valueStyle ??
                            TextStyle(
                              color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight,
                              fontSize: widget.size * 0.18,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    if (widget.label != null)
                      Text(
                        widget.label!,
                        style: widget.labelStyle ??
                            TextStyle(
                              color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight,
                              fontSize: widget.size * 0.1,
                            ),
                      ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color backgroundColor;
  final List<Color> gradientColors;

  _ProgressRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.gradientColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    if (progress > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      final gradient = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: math.pi * 1.5,
        colors: gradientColors,
        transform: const GradientRotation(-math.pi / 2),
      );

      final progressPaint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * math.pi * progress;
      canvas.drawArc(
        rect,
        -math.pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );

      // Glow effect at the end
      if (progress > 0.01) {
        final glowPaint = Paint()
          ..color = gradientColors.last.withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth + 4
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

        final endAngle = -math.pi / 2 + sweepAngle;
        final endPoint = Offset(
          center.dx + radius * math.cos(endAngle),
          center.dy + radius * math.sin(endAngle),
        );

        canvas.drawCircle(endPoint, strokeWidth / 2, glowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class MiniProgressRing extends StatelessWidget {
  final double progress;
  final double size;
  final Color color;
  final double strokeWidth;

  const MiniProgressRing({
    super.key,
    required this.progress,
    this.size = 40,
    this.color = FitColors.neonGreen,
    this.strokeWidth = 3,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedProgressRing(
      progress: progress,
      size: size,
      strokeWidth: strokeWidth,
      gradientColors: [color, color],
      backgroundColor: color.withValues(alpha: 0.2),
      child: Text(
        '${(progress * 100).toInt()}%',
        style: TextStyle(
          color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight,
          fontSize: size * 0.22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class DashboardProgressCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final double progress;
  final Color color;
  final List<Color>? gradientColors;
  final IconData icon;
  final VoidCallback? onTap;

  const DashboardProgressCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.progress,
    required this.color,
    this.gradientColors,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? FitColors.cardDark : FitColors.cardLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                AnimatedProgressRing(
                  progress: progress.clamp(0.0, 1.0),
                  size: 44,
                  strokeWidth: 4,
                  gradientColors: gradientColors ?? [color, color],
                  backgroundColor: color.withValues(alpha: 0.2),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight,
                fontSize: 14,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: TextStyle(
                  color: isDark ? FitColors.textSecondaryDark.withValues(alpha: 0.6) : FitColors.textSecondaryLight.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
    );
  }
}
