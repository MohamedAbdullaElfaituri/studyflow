import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData light(
    Locale? locale, {
    bool accessibilityMode = false,
  }) {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.seed,
      secondary: AppColors.secondary,
      tertiary: AppColors.tertiary,
      error: AppColors.danger,
      surface: Colors.white,
      onSurface: AppColors.neutral900,
    );

    return _buildTheme(
      scheme,
      Brightness.light,
      locale,
      accessibilityMode: accessibilityMode,
    );
  }

  static ThemeData dark(
    Locale? locale, {
    bool accessibilityMode = false,
  }) {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: Brightness.dark,
    ).copyWith(
      primary: const Color(0xFFA7D0F4),
      secondary: const Color(0xFF86E0D1),
      tertiary: const Color(0xFFF6C77A),
      error: const Color(0xFFFFB4A0),
      surface: AppColors.darkSurface,
      onSurface: Colors.white,
    );

    return _buildTheme(
      scheme,
      Brightness.dark,
      locale,
      accessibilityMode: accessibilityMode,
    );
  }

  static ThemeData _buildTheme(
    ColorScheme scheme,
    Brightness brightness,
    Locale? locale, {
    required bool accessibilityMode,
  }) {
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
      materialTapTargetSize: accessibilityMode
          ? MaterialTapTargetSize.padded
          : MaterialTapTargetSize.shrinkWrap,
      visualDensity: accessibilityMode
          ? VisualDensity.comfortable
          : VisualDensity.standard,
      scaffoldBackgroundColor: brightness == Brightness.light
          ? AppColors.neutral50
          : AppColors.darkBackground,
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: scheme.outlineVariant.withOpacity(0.5),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          side: BorderSide(color: scheme.outlineVariant.withOpacity(0.7)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface
            .withOpacity(brightness == Brightness.dark ? 0.78 : 0.92),
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
        labelTextStyle: WidgetStatePropertyAll(textTheme.labelMedium),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return scheme.onPrimary;
          }
          return scheme.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return scheme.primary;
          }
          return scheme.surfaceContainerHighest;
        }),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withOpacity(0.55),
        space: 24,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surface.withOpacity(0.72),
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
        backgroundColor: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
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
