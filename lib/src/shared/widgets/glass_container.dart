import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';

class GlassContainer extends StatelessWidget {
  final Widget? child;
  final double opacity;
  final Color? tint;
  final List<Color>? gradient;
  final List<Color>? borderGradient;
  final double blur;
  final double radius;
  final BorderSide? border;
  final List<BoxShadow>? shadow;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const GlassContainer({
    super.key,
    this.child,
    this.opacity = 0.06,
    this.tint,
    this.gradient,
    this.borderGradient,
    this.blur = 10,
    this.radius = 16,
    this.border,
    this.shadow,
    this.padding = EdgeInsets.zero,
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveTint = tint ?? (isDark ? const Color(0xFF1E293B) : Colors.white);
    final effectiveBorder = border != null
        ? Border.fromBorderSide(border!)
        : Border.all(color: (tint ?? Colors.white).withValues(alpha: 0.12), width: 0.5);

    Widget container;
    if (borderGradient != null) {
      container = _buildGradientBorderContainer(context, isDark, effectiveTint, effectiveBorder);
    } else {
      container = _buildContainer(context, isDark, effectiveTint, effectiveBorder);
    }

    if (onTap != null) {
      return Container(
        margin: margin,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(radius),
            onTap: onTap,
            child: container,
          ),
        ),
      );
    }

    return Container(margin: margin, child: container);
  }

  Widget _buildContainer(BuildContext context, bool isDark, Color effectiveTint, Border effectiveBorder) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: effectiveTint.withValues(alpha: opacity),
            gradient: gradient != null
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradient!,
                  )
                : null,
            borderRadius: BorderRadius.circular(radius),
            border: effectiveBorder,
            boxShadow: shadow,
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildGradientBorderContainer(BuildContext context, bool isDark, Color effectiveTint, Border effectiveBorder) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: borderGradient!,
        ),
      ),
      padding: const EdgeInsets.all(1),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius - 1),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: effectiveTint.withValues(alpha: opacity),
              gradient: gradient != null
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradient!,
                    )
                  : null,
              boxShadow: shadow,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class AnimatedGlassContainer extends StatefulWidget {
  final Widget? child;
  final double opacity;
  final Color? tint;
  final List<Color>? gradient;
  final List<Color>? borderGradient;
  final double blur;
  final double radius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Duration animationDuration;

  const AnimatedGlassContainer({
    super.key,
    this.child,
    this.opacity = 0.06,
    this.tint,
    this.gradient,
    this.borderGradient,
    this.blur = 10,
    this.radius = 16,
    this.padding = EdgeInsets.zero,
    this.margin,
    this.onTap,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<AnimatedGlassContainer> createState() => _AnimatedGlassContainerState();
}

class _AnimatedGlassContainerState extends State<AnimatedGlassContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.6, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (context, _) {
        final shadow = [
          BoxShadow(
            color: FitColors.neonGreen.withValues(alpha: 0.08 * _glowAnim.value),
            blurRadius: 12 * _glowAnim.value,
            spreadRadius: 1 * _glowAnim.value,
          ),
        ];

        return GlassContainer(
          opacity: widget.opacity,
          tint: widget.tint,
          gradient: widget.gradient,
          borderGradient: widget.borderGradient,
          blur: widget.blur,
          radius: widget.radius,
          padding: widget.padding,
          margin: widget.margin,
          onTap: widget.onTap,
          shadow: shadow,
          child: widget.child,
        );
      },
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget? child;
  final double opacity;
  final Color? tint;
  final List<Color>? gradient;
  final double blur;
  final double radius;
  final BorderSide? border;
  final List<BoxShadow>? shadow;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double? height;
  final double? width;

  const GlassCard({
    super.key,
    this.child,
    this.opacity = 0.06,
    this.tint,
    this.gradient,
    this.blur = 10,
    this.radius = 16,
    this.border,
    this.shadow,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveOpacity = opacity;
    final effectiveTint = tint ?? (isDark ? const Color(0xFF1E293B) : Colors.white);
    final effectiveBorder = border != null
        ? Border.fromBorderSide(border!)
        : Border.all(color: (tint ?? Colors.white).withValues(alpha: 0.12), width: 0.5);

    return Container(
      height: height,
      width: width,
      margin: margin,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: Container(
                padding: padding,
                decoration: BoxDecoration(
                  color: effectiveTint.withValues(alpha: effectiveOpacity),
                  gradient: gradient != null
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: gradient!,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(radius),
                  border: effectiveBorder,
                  boxShadow: shadow,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
