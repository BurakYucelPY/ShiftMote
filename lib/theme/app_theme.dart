import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Renk Sistemi ───────────────────────────────────────────────
// 4 ana tema rengi: Koyu gri · Açık gri · Vizon · Kırık beyaz
// Neumorphism gölgeleri NÖTR gri tutulur — paletteki sıcak tonlar
// (vizon / kırık beyaz) shadow'larda DEĞİL, UI vurgu noktalarında kullanılır.
class AppColors {
  // ─── Ana 4 marka rengi ──────────────────────────────────────
  // Koyu gri — ana arkaplan
  static const Color background = Color(0xFF1C1C1C);
  // Açık gri — yükseltilmiş yüzeyler / panel arka planları
  static const Color surface = Color(0xFF2E2E2E);
  // Altın — aksan rengi (yumuşak şampanya gold), butonlar, ikonlar, vurgular için
  static const Color accent = Color(0xFFDCC48A);
  // Kırık beyaz / krem — özel vurgu / dekoratif metin için
  static const Color offWhite = Color(0xFFF5E9C8);

  // ─── Yüzey türevleri ────────────────────────────────────────
  static const Color surfaceLight = Color(0xFF383838); // ekstra yükseltilmiş
  static const Color surfaceDark = Color(0xFF141414);  // içe batık / pressed

  // ─── Altın tonları (gradient ve secondary aksan için) ──────
  static const Color accentSecondary = Color(0xFFB8A06A);
  static const Color accentGradientEnd = Color(0xFF8A7449);

  // ─── Metin hiyerarşisi (parlak ve net) ─────────────────────
  static const Color textPrimary = Color(0xFFF0F0F0);    // parlak beyaz
  static const Color textSecondary = Color(0xFF9E9E9E);  // mat orta gri
  static const Color textTertiary = Color(0xFF6E6E6E);   // sönük gri

  // ─── Neumorphism gölgeleri (NÖTR gri — palette renkleri YOK) ─
  // background ± ~16 birim. Saf nötr gri.
  static const Color shadowLight = Color(0xFF2C2C2C); // bg + 16
  static const Color shadowDark = Color(0xFF0A0A0A);  // bg - 18

  // ─── Durum renkleri ─────────────────────────────────────────
  static const Color error = Color(0xFFFF5252);
  static const Color warning = Color(0xFFFFB74D);
  static const Color success = Color(0xFF4ADE80);

  // ─── Sınırlar ───────────────────────────────────────────────
  static const Color divider = Color(0xFF333333);
  static const Color cardBorder = Color(0xFF3D3D3D);

  // ─── Glow ───────────────────────────────────────────────────
  static Color accentGlow = accent.withValues(alpha: 0.4);
  static Color errorGlow = error.withValues(alpha: 0.4);

  // ─── Klima mod renkleri (canlı ve fonksiyonel) ─────────────
  static const Color modeCool = Color(0xFF4FB8D9); // soğuk - yumuşak cyan
  static const Color modeHeat = Color(0xFFFF7E54); // sıcak - mercan
  static const Color modeFan = Color(0xFF5DC97A);  // fan - yumuşak yeşil
  static const Color modeAuto = Color(0xFF9577ED); // oto - yumuşak lavanta
}

// ─── Spacing & Radius ───────────────────────────────────────────
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double round = 100;
}

// ─── Animasyon Sabitleri ───────────────────────────────────────
class AppDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration stagger = Duration(milliseconds: 80);
}

// ─── Neumorphic Stil Presetleri ────────────────────────────────
// Klasik neumorphism kuralı: element rengi = arka plan rengi.
// Derinlik tamamen nötr gri gölgelerden gelir.
//
// Boyutlandırma kuralı: depth ≈ element çapının %5-8'i.
//   50px buton → depth 3-4 · 100px kart → depth 5-6 · 160px panel → depth 6-8.
// Aşırı depth + yüksek intensity birleşince butonlar "yarım ay"a benzer.
class NeuPresets {
  // Düz yükseltilmiş kart (orta-büyük yüzeyler)
  static NeumorphicStyle card({double depth = 5, double intensity = 0.55}) {
    return NeumorphicStyle(
      shape: NeumorphicShape.flat,
      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(AppRadius.lg)),
      depth: depth,
      intensity: intensity,
      lightSource: LightSource.topLeft,
      color: AppColors.background,
      shadowDarkColor: AppColors.shadowDark,
      shadowLightColor: AppColors.shadowLight,
    );
  }

  // Düz basılabilir buton (küçük-orta)
  static NeumorphicStyle button({double depth = 4, double intensity = 0.5, double radius = AppRadius.lg}) {
    return NeumorphicStyle(
      shape: NeumorphicShape.flat,
      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(radius)),
      depth: depth,
      intensity: intensity,
      lightSource: LightSource.topLeft,
      color: AppColors.background,
      shadowDarkColor: AppColors.shadowDark,
      shadowLightColor: AppColors.shadowLight,
    );
  }

  // İçe batık (pressed / inset)
  static NeumorphicStyle pressed({double radius = AppRadius.lg, double depth = -3, double intensity = 0.5}) {
    return NeumorphicStyle(
      shape: NeumorphicShape.flat,
      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(radius)),
      depth: depth,
      intensity: intensity,
      lightSource: LightSource.topLeft,
      color: AppColors.background,
      shadowDarkColor: AppColors.shadowDark,
      shadowLightColor: AppColors.shadowLight,
    );
  }

  // Yuvarlak buton — boyuta göre küçültüldü
  static NeumorphicStyle circle({double depth = 4, double intensity = 0.5}) {
    return NeumorphicStyle(
      shape: NeumorphicShape.flat,
      boxShape: const NeumorphicBoxShape.circle(),
      depth: depth,
      intensity: intensity,
      lightSource: LightSource.topLeft,
      color: AppColors.background,
      shadowDarkColor: AppColors.shadowDark,
      shadowLightColor: AppColors.shadowLight,
    );
  }

  // İçe batık yuvarlak (D-pad arka planı vb.)
  static NeumorphicStyle circlePressed({double depth = -3, double intensity = 0.5}) {
    return NeumorphicStyle(
      shape: NeumorphicShape.flat,
      boxShape: const NeumorphicBoxShape.circle(),
      depth: depth,
      intensity: intensity,
      lightSource: LightSource.topLeft,
      color: AppColors.background,
      shadowDarkColor: AppColors.shadowDark,
      shadowLightColor: AppColors.shadowLight,
    );
  }

  // Yükseltilmiş "açık gri" panel
  static NeumorphicStyle elevated({double depth = 4, double intensity = 0.45, double radius = AppRadius.lg}) {
    return NeumorphicStyle(
      shape: NeumorphicShape.flat,
      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(radius)),
      depth: depth,
      intensity: intensity,
      lightSource: LightSource.topLeft,
      color: AppColors.surface,
      shadowDarkColor: AppColors.shadowDark,
      shadowLightColor: AppColors.shadowLight,
    );
  }
}

// ─── Material ThemeData ────────────────────────────────────────
class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.accent,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        secondary: AppColors.accentSecondary,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.5),
          headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.textPrimary, letterSpacing: -0.3),
          headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
          bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textPrimary),
          bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondary),
          bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textSecondary),
          labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.accent),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: false,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        labelStyle: TextStyle(color: AppColors.textSecondary),
        hintStyle: TextStyle(color: AppColors.textSecondary),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.divider, thickness: 1),
    );
  }

  static NeumorphicThemeData get neumorphicDark {
    return const NeumorphicThemeData(
      baseColor: AppColors.background,
      accentColor: AppColors.accent,
      lightSource: LightSource.topLeft,
      depth: 5,
      intensity: 0.55,
      shadowDarkColor: AppColors.shadowDark,
      shadowLightColor: AppColors.shadowLight,
    );
  }
}
