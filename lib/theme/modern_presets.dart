import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Modern tema için dekorasyon presetleri.
/// Neumorphic olmayan, modern Material 3 benzeri düz tasarım.
class ModernPresets {
  // Yükseltilmiş kart — ince border + subtle shadow
  static BoxDecoration card({double radius = AppRadius.lg, bool hasBorder = true}) {
    return BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(radius),
      border: hasBorder ? Border.all(color: AppColors.cardBorder.withValues(alpha: 0.5), width: 0.5) : null,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 12,
          offset: const Offset(0, 4),
          spreadRadius: -2,
        ),
      ],
    );
  }

  // İçe batık alan — input, seçici arka planları
  static BoxDecoration inset({double radius = AppRadius.lg}) {
    return BoxDecoration(
      color: AppColors.surfaceDark,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: AppColors.divider.withValues(alpha: 0.3), width: 0.5),
    );
  }

  // Buton — gradient arka plan + glow
  static BoxDecoration button({double radius = AppRadius.lg, Color? color}) {
    final c = color ?? AppColors.accent;
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      color: c.withValues(alpha: 0.12),
      border: Border.all(color: c.withValues(alpha: 0.2), width: 0.5),
    );
  }

  // Seçili buton
  static BoxDecoration selectedChip({double radius = AppRadius.md, Color? color}) {
    final c = color ?? AppColors.accent;
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      color: c.withValues(alpha: 0.15),
      border: Border.all(color: c.withValues(alpha: 0.35), width: 1),
    );
  }

  // Seçilmemiş buton
  static BoxDecoration unselectedChip({double radius = AppRadius.md}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      color: AppColors.surface,
      border: Border.all(color: AppColors.divider, width: 0.5),
    );
  }

  // Yuvarlak buton — kumanda butonları için
  static BoxDecoration circleButton({Color? color, bool isPressed = false}) {
    return BoxDecoration(
      shape: BoxShape.circle,
      color: isPressed ? AppColors.surfaceDark : AppColors.surface,
      border: Border.all(color: AppColors.divider.withValues(alpha: 0.4), width: 0.5),
      boxShadow: isPressed
          ? []
          : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 3),
                spreadRadius: -1,
              ),
            ],
    );
  }

  // İçe batık yuvarlak — D-pad arka planı
  static BoxDecoration circleInset() {
    return BoxDecoration(
      shape: BoxShape.circle,
      color: AppColors.surfaceDark,
      border: Border.all(color: AppColors.divider.withValues(alpha: 0.3), width: 0.5),
    );
  }

  // Bottom nav bar
  static BoxDecoration navBar({double radius = AppRadius.xxl}) {
    return BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: AppColors.divider.withValues(alpha: 0.3), width: 0.5),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 16,
          offset: const Offset(0, -2),
          spreadRadius: -4,
        ),
      ],
    );
  }
}
