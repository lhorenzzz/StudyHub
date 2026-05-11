import 'package:flutter/material.dart';
import 'package:study_hub/core/theme/app_colors.dart';

// ─── THEME HELPER ─────────────────────────────────────────────────────────────
class AdminTheme {
  final bool isDark;
  final Color bg, surface, surface2, border, border2, text, textSub, textMuted;

  AdminTheme(this.isDark)
    : bg = isDark ? AppColors.darkBg : AppColors.lightBg,
      surface = isDark ? AppColors.darkSurface : AppColors.lightSurface,
      surface2 = isDark ? AppColors.darkSurface2 : AppColors.lightSurface2,
      border = isDark ? AppColors.darkBorder : AppColors.lightBorder,
      border2 = isDark ? AppColors.darkBorder2 : AppColors.lightBorder2,
      text = isDark ? AppColors.darkText : AppColors.lightText,
      textSub = isDark ? const Color(0xFFAAAAAA) : const Color(0xFF666666),
      textMuted = isDark ? const Color(0xFF777777) : const Color(0xFF999999);

  Color get hover =>
      isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04);
}

// Keep the old alias so all existing references (_T) compile without changes.

// ─── CATEGORY COLOR PALETTE ───────────────────────────────────────────────────
class CatColor {
  final Color border;
  final Color bg;
  final Color icon;
  const CatColor({required this.border, required this.bg, required this.icon});
}

const kCatColorsDark = [
  CatColor(
    border: Color(0xFF1D4ED8),
    bg: Color(0xFF0F1E3A),
    icon: Color(0xFF1E3A5F),
  ),
  CatColor(
    border: Color(0xFF0F766E),
    bg: Color(0xFF0A2520),
    icon: Color(0xFF0D3330),
  ),
  CatColor(
    border: Color(0xFFB45309),
    bg: Color(0xFF2A1A05),
    icon: Color(0xFF3A2208),
  ),
  CatColor(
    border: Color(0xFF7C3AED),
    bg: Color(0xFF1A0D35),
    icon: Color(0xFF2A1255),
  ),
  CatColor(
    border: Color(0xFFBE185D),
    bg: Color(0xFF2A0D1E),
    icon: Color(0xFF3A1028),
  ),
  CatColor(
    border: Color(0xFF15803D),
    bg: Color(0xFF0A2015),
    icon: Color(0xFF0D2E1A),
  ),
];

const kCatColorsLight = [
  CatColor(
    border: Color(0xFF93C5FD),
    bg: Color(0xFFEFF6FF),
    icon: Color(0xFFDBEAFE),
  ),
  CatColor(
    border: Color(0xFF5EEAD4),
    bg: Color(0xFFF0FDFA),
    icon: Color(0xFFCCFBF1),
  ),
  CatColor(
    border: Color(0xFFFCD34D),
    bg: Color(0xFFFFFBEB),
    icon: Color(0xFFFEF3C7),
  ),
  CatColor(
    border: Color(0xFFC4B5FD),
    bg: Color(0xFFF5F3FF),
    icon: Color(0xFFEDE9FE),
  ),
  CatColor(
    border: Color(0xFFF9A8D4),
    bg: Color(0xFFFDF2F8),
    icon: Color(0xFFFCE7F3),
  ),
  CatColor(
    border: Color(0xFF86EFAC),
    bg: Color(0xFFF0FDF4),
    icon: Color(0xFFDCFCE7),
  ),
];

CatColor resolveCatColor(int i, bool dark) => dark
    ? kCatColorsDark[i % kCatColorsDark.length]
    : kCatColorsLight[i % kCatColorsLight.length];

// Internal shorthand used throughout the dashboard files.
// Keeps all existing call-sites (resolveCatColor(i, t.isDark)) unchanged.
