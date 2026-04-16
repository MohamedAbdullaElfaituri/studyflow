import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

class AppTheme {
  static const _fontFamily = 'PlusJakartaSans';

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
    final baseTextTheme = ThemeData(
      useMaterial3: true,
      brightness: brightness,
    ).textTheme;

    final textTheme = baseTextTheme
        .apply(
          fontFamily: _fontFamily,
          bodyColor: scheme.onSurface,
          displayColor: scheme.onSurface,
        )
        .copyWith(
          headlineLarge: baseTextTheme.headlineLarge?.copyWith(
            fontFamily: _fontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 30,
            height: 1.12,
          ),
          headlineMedium: baseTextTheme.headlineMedium?.copyWith(
            fontFamily: _fontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 26,
            height: 1.14,
          ),
          headlineSmall: baseTextTheme.headlineSmall?.copyWith(
            fontFamily: _fontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 22,
            height: 1.16,
          ),
          titleLarge: baseTextTheme.titleLarge?.copyWith(
            fontFamily: _fontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            height: 1.2,
          ),
          titleMedium: baseTextTheme.titleMedium?.copyWith(
            fontFamily: _fontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 16,
            height: 1.24,
          ),
          titleSmall: baseTextTheme.titleSmall?.copyWith(
            fontFamily: _fontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 14,
            height: 1.24,
          ),
          bodyLarge: baseTextTheme.bodyLarge?.copyWith(
            fontFamily: _fontFamily,
            fontWeight: FontWeight.w400,
            fontSize: 16,
            height: 1.45,
          ),
          bodyMedium: baseTextTheme.bodyMedium?.copyWith(
            fontFamily: _fontFamily,
            fontWeight: FontWeight.w400,
            fontSize: 14,
            height: 1.45,
          ),
          bodySmall: baseTextTheme.bodySmall?.copyWith(
            fontFamily: _fontFamily,
            fontWeight: FontWeight.w400,
            fontSize: 12,
            height: 1.4,
          ),
          labelLarge: baseTextTheme.labelLarge?.copyWith(
            fontFamily: _fontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
          labelMedium: baseTextTheme.labelMedium?.copyWith(
            fontFamily: _fontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
          labelSmall: baseTextTheme.labelSmall?.copyWith(
            fontFamily: _fontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        );

    final overlayStyle = brightness == Brightness.dark
        ? SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: Brightness.light,
          )
        : SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: Brightness.dark,
          );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: _fontFamily,
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
            color: scheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.7)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(44, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface.withValues(
          alpha: brightness == Brightness.dark ? 0.78 : 0.92,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
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
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surface.withValues(alpha: 0.84),
        selectedColor: scheme.primaryContainer,
        disabledColor: scheme.surfaceContainerHighest,
        labelStyle: textTheme.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        side: BorderSide(color: scheme.outlineVariant),
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
        color: scheme.outlineVariant.withValues(alpha: 0.55),
        space: 24,
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
        backgroundColor: Color.alphaBlend(
          scheme.primary.withValues(alpha: 0.08),
          scheme.surface,
        ),
        elevation: 0,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 2,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: overlayStyle,
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
