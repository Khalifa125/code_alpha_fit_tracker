import 'package:flutter/material.dart';

class FitColors {
  FitColors._();

  // =====================================================
  // DARK THEME (Primary - Professional fitness app style)
  // =====================================================
  static const backgroundDark    = Color(0xFF0D1117);
  static const surfaceDark      = Color(0xFF161B22);
  static const cardDark         = Color(0xFF1C2333);
  static const cardHoverDark    = Color(0xFF21293A);
  static const borderDark       = Color(0xFF30363D);
  static const textPrimaryDark  = Color(0xFFF0F6FC);
  static const textSecondaryDark= Color(0xFF8B949E);
  static const textMutedDark    = Color(0xFF484F58);

  // =====================================================
  // LIGHT THEME
  // =====================================================
  static const backgroundLight  = Color(0xFFF8FAFC);
  static const surfaceLight    = Color(0xFFFFFFFF);
  static const cardLight       = Color(0xFFFFFFFF);
  static const cardHoverLight  = Color(0xFFF1F5F9);
  static const borderLight     = Color(0xFFE2E8F0);
  static const textPrimaryLight= Color(0xFF1E293B);
  static const textSecondaryLight= Color(0xFF64748B);
  static const textMutedLight  = Color(0xFF94A3B8);

  // =====================================================
  // BACKWARD COMPATIBILITY (Dark theme default)
  // =====================================================
  static const background    = backgroundDark;
  static const surface       = surfaceDark;
  static const card         = cardDark;
  static const cardHover    = cardHoverDark;
  static const border       = borderDark;
  static const textPrimary  = textPrimaryDark;
  static const textSecondary= textSecondaryDark;
  static const textMuted    = textMutedDark;

  // =====================================================
  // PRIMARY BRAND COLORS (Neon Green - Vibrant fitness accent)
  // =====================================================
  static const primary       = Color(0xFF22C55E);
  static const primaryLight  = Color(0xFF4ADE80);
  static const primaryDark   = Color(0xFF16A34A);
  static const neonGreen     = Color(0xFF22C55E);
  static const neonGreenDim  = Color(0xFF16A34A);
  static const cyan          = Color(0xFF22C55E);
  static const green         = Color(0xFF22C55E);

  // =====================================================
  // SEMANTIC COLORS (Clear meaning)
  // =====================================================
  static const success       = Color(0xFF22C55E);
  static const warning       = Color(0xFFF59E0B);
  static const error         = Color(0xFFEF4444);
  static const info          = Color(0xFF3B82F6);

  // =====================================================
  // FEATURE COLORS (For charts and metrics)
  // =====================================================
  static const calories      = Color(0xFFFF6B35);    // Orange - Energy
  static const protein       = Color(0xFF3B82F6);    // Blue - Protein
  static const carbs        = Color(0xFFF59E0B);     // Amber - Carbs
  static const fat           = Color(0xFF8B5CF6);    // Purple - Fat
  static const water         = Color(0xFF06B6D4);    // Cyan - Hydration
  static const sleep         = Color(0xFF8B5CF6);    // Purple - Sleep
  static const heart         = Color(0xFFEF4444);    // Red - Heart rate
  static const steps         = Color(0xFF22C55E);     // Green - Steps
  static const workout       = Color(0xFFFF6B35);    // Orange - Workout
  static const streak       = Color(0xFFF59E0B);    // Amber - Streak
  static const restingHR     = Color(0xFFEC4899);    // Pink - RHR

  // =====================================================
  // GLASS / PREMIUM
  // =====================================================
  static const darkGlassTint   = Color(0xFF1E293B);
  static const lightGlassTint  = Color(0xFFFFFFFF);
  static const darkGlow        = Color(0xFF22C55E);
  static const darkAccent      = Color(0xFF4ADE80);
  static const darkWarmAccent  = Color(0xFFFF6B35);

  // =====================================================
  // SECONDARY COLORS
  // =====================================================
  static const orange        = Color(0xFFFF6B35);
  static const blue          = Color(0xFF3B82F6);
  static const purple        = Color(0xFF8B5CF6);
  static const amber         = Color(0xFFF59E0B);
  static const pink          = Color(0xFFEC4899);
  static const red           = Color(0xFFEF4444);
  static const teal          = Color(0xFF14B8A6);
  static const indigo       = Color(0xFF6366F1);

  // =====================================================
  // GRADIENTS (For progress rings and backgrounds)
  // =====================================================
  static const caloriesGradient = [
    Color(0xFFFF6B35),
    Color(0xFFFF8F5A),
  ];

  static const stepsGradient = [
    Color(0xFF22C55E),
    Color(0xFF4ADE80),
  ];

  static const waterGradient = [
    Color(0xFF06B6D4),
    Color(0xFF22D3EE),
  ];

  static const sleepGradient = [
    Color(0xFF8B5CF6),
    Color(0xFFA78BFA),
  ];

  static const workoutGradient = [
    Color(0xFFFF6B35),
    Color(0xFFFB923C),
  ];

  static const heartGradient = [
    Color(0xFFEF4444),
    Color(0xFFF87171),
  ];

  static const streakGradient = [
    Color(0xFFF59E0B),
    Color(0xFFFBBF24),
  ];
}

class FitThemeColors {
  final Color background;
  final Color surface;
  final Color card;
  final Color cardHover;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color glassTint;
  final Color glow;
  final Color accent;
  final Color warmAccent;

  const FitThemeColors({
    required this.background,
    required this.surface,
    required this.card,
    required this.cardHover,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    this.glassTint = FitColors.darkGlassTint,
    this.glow = FitColors.darkGlow,
    this.accent = FitColors.darkAccent,
    this.warmAccent = FitColors.darkWarmAccent,
  });

  static const dark = FitThemeColors(
    background: FitColors.backgroundDark,
    surface: FitColors.surfaceDark,
    card: FitColors.cardDark,
    cardHover: FitColors.cardHoverDark,
    border: FitColors.borderDark,
    textPrimary: FitColors.textPrimaryDark,
    textSecondary: FitColors.textSecondaryDark,
    textMuted: FitColors.textMutedDark,
    glassTint: FitColors.darkGlassTint,
    glow: FitColors.darkGlow,
    accent: FitColors.darkAccent,
    warmAccent: FitColors.darkWarmAccent,
  );

  static const light = FitThemeColors(
    background: FitColors.backgroundLight,
    surface: FitColors.surfaceLight,
    card: FitColors.cardLight,
    cardHover: FitColors.cardHoverLight,
    border: FitColors.borderLight,
    textPrimary: FitColors.textPrimaryLight,
    textSecondary: FitColors.textSecondaryLight,
    textMuted: FitColors.textMutedLight,
    glassTint: FitColors.lightGlassTint,
    glow: FitColors.darkGlow,
    accent: FitColors.darkAccent,
    warmAccent: FitColors.darkWarmAccent,
  );

  static FitThemeColors of(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? dark : light;
  }
}
