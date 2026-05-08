// ─── fit_colors.dart ────────────────────────────────────────────────────────
// Central design tokens for FitTrack
// Import this in any file that needs colors

import 'package:flutter/material.dart';

class FitColors {
  FitColors._();

  // Backgrounds
  static const background    = Color(0xFF0D1117);
  static const surface       = Color(0xFF161B22);
  static const card          = Color(0xFF1C2333);
  static const cardHover     = Color(0xFF21293A);

  // Borders
  static const border        = Color(0xFF30363D);

  // Brand / Accent
  static const neonGreen     = Color(0xFF22C55E);
  static const neonGreenDim  = Color(0xFF16A34A);

  // Semantic
  static const cyan          = Color(0xFF22C55E); // alias → neonGreen
  static const green         = Color(0xFF22C55E); // alias → neonGreen
  static const orange        = Color(0xFFFF6B35);
  static const blue          = Color(0xFF3B82F6);
  static const purple        = Color(0xFF8B5CF6);
  static const amber         = Color(0xFFF59E0B);
  static const pink          = Color(0xFFEC4899);
  static const red           = Color(0xFFEF4444);

  // Text
  static const textPrimary   = Color(0xFFF0F6FC);
  static const textSecondary = Color(0xFF8B949E);
  static const textMuted     = Color(0xFF484F58);
}
