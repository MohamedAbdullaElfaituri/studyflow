import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData light([Locale? locale]) {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.seed,
      secondary: AppColors.secondary,
      tertiary: AppColors.tertiary,
      error: AppColors.danger,
      surface: Colors.white,
      surfaceContainerHighest: const Color(0xFFEFF4F9),
      onSurface: AppColors.neutral900,
    );

    return _buildTheme(scheme, Brightness.light, locale);
  }

  static ThemeData dark([Locale? locale]) {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: Brightness.dark,
    ).copyWith(
      primary: const Color(0xFFA7D0F4),
      secondary: const Color(0xFF86E0D1),
      tertiary: const Color(0xFFF6C77A),
      error: const Color(0xFFFFB4A0),
      surface: AppColors.darkSurface,
      surfaceContainerHighest: const Color(0xFF1C2740),
      onSurface: Colors.white,
    );

    return _buildTheme(scheme, Brightness.dark, locale);
  }

  static ThemeData _buildTheme(
    ColorScheme scheme,
    Brightness brightness,
    Locale? locale,
  ) {
    final isArabic = locale?.languageCode == 'ar';
    final baseTextTheme = isArabic
        ? GoogleFonts.notoSansArabicTextTheme()
        : GoogleFonts.plusJakartaSansTextTheme();

    final textTheme = baseTextTheme.copyWith(
      headlineMedium: (isArabic
              ? GoogleFonts.notoSansArabic()
              : GoogleFonts.plusJakartaSans())
          .copyWith(fontWeight: FontWeight.w700),
      titleLarge: (isArabic
              ? GoogleFonts.notoSansArabic()
              : GoogleFonts.plusJakartaSans())
          .copyWith(fontWeight: FontWeight.w700),
      titleMedium: (isArabic
              ? GoogleFonts.notoSansArabic()
              : GoogleFonts.plusJakartaSans())
          .copyWith(fontWeight: FontWeight.w600),
      bodyLarge: (isArabic
              ? GoogleFonts.notoSansArabic()
              : GoogleFonts.plusJakartaSans())
          .copyWith(height: 1.4),
      bodyMedium: (isArabic
              ? GoogleFonts.notoSansArabic()
              : GoogleFonts.plusJakartaSans())
          .copyWith(height: 1.4),
      labelLarge: (isArabic
              ? GoogleFonts.notoSansArabic()
              : GoogleFonts.plusJakartaSans())
          .copyWith(fontWeight: FontWeight.w600),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      textTheme: textTheme,
      scaffoldBackgroundColor:
          brightness == Brightness.light ? AppColors.neutral50 : AppColors.darkBackground,
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.primary, width: 1.4),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: scheme.onSurface,
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
