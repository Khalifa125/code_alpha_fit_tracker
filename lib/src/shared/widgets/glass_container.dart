import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
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

  const GlassContainer({
    super.key,
    this.child,
    this.opacity = 0.06,
    this.tint,
    this.gradient,
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
    final effectiveOpacity = opacity;
    final effectiveTint = tint ?? (isDark ? const Color(0xFF1E293B) : Colors.white);
    final effectiveBorder = border != null
        ? Border.fromBorderSide(border!)
        : Border.all(color: (tint ?? Colors.white).withValues(alpha: 0.12), width: 0.5);

    final container = ClipRRect(
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
    );

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
