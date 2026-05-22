import 'package:flutter/material.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';

class ExerciseAnimation extends StatefulWidget {
  final String exerciseType;
  final String emoji;
  final double size;

  const ExerciseAnimation({
    super.key,
    required this.exerciseType,
    this.emoji = '🏋️',
    this.size = 72,
  });

  @override
  State<ExerciseAnimation> createState() => _ExerciseAnimationState();
}

class _ExerciseAnimationState extends State<ExerciseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnim;
  late Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _floatAnim = Tween<double>(begin: -4, end: 4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _glowColor() {
    final type = widget.exerciseType.toLowerCase();
    if (type.contains('chest')) return FitColors.blue;
    if (type.contains('back')) return FitColors.purple;
    if (type.contains('leg') || type.contains('glute')) return FitColors.orange;
    if (type.contains('arm') || type.contains('bicep') || type.contains('tricep')) return FitColors.pink;
    if (type.contains('shoulder')) return FitColors.amber;
    if (type.contains('core') || type.contains('abs')) return FitColors.teal;
    return FitColors.neonGreen;
  }

  @override
  Widget build(BuildContext context) {
    final color = _glowColor();
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, _floatAnim.value),
        child: Transform.scale(
          scale: _pulseAnim.value,
          child: child,
        ),
      ),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 20,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 800),
              builder: (_, value, __) => CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _RingsPainter(progress: value, color: color),
              ),
            ),
            Text(widget.emoji, style: TextStyle(fontSize: widget.size * 0.55)),
          ],
        ),
      ),
    );
  }
}

class _RingsPainter extends CustomPainter {
  final double progress;
  final Color color;

  _RingsPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 2; i++) {
      final radius = size.width * (0.45 + i * 0.12);
      paint.color = color.withValues(alpha: (0.15 - i * 0.05) * progress);
      paint.strokeWidth = 1.5 + i;
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_RingsPainter old) => old.progress != progress;
}
