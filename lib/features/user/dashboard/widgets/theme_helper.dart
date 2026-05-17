import 'package:flutter/material.dart';
import 'package:study_hub/core/theme/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// theme_helper.dart
//
// UserTheme replaces the old private _T class.
// Every file that previously used _T should import this file and use UserTheme.
// ─────────────────────────────────────────────────────────────────────────────

class UserTheme {
  final bool isDark;
  final Color bg, surface, surface2, border, border2, text, textSub, textMuted;

  UserTheme(this.isDark)
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
