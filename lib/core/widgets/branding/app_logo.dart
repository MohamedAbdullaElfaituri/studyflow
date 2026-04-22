import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 56,
    this.framed = true,
    this.radius = 22,
    this.padding,
    this.backgroundColor,
    this.borderColor,
    this.elevation = true,
  });

  final double size;
  final bool framed;
  final double radius;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool elevation;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final logoGraphic = Image.asset(
      'assets/branding/app_logo.png',
      width: framed ? size * 0.62 : size,
      height: framed ? size * 0.62 : size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );

    if (!framed) {
      return SizedBox.square(
        dimension: size,
        child: Center(child: logoGraphic),
      );
    }

    return Container(
      width: size,
      height: size,
      padding: padding ?? EdgeInsets.all(size * 0.18),
      decoration: BoxDecoration(
        color: backgroundColor ?? scheme.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: borderColor ?? scheme.outlineVariant.withValues(alpha: 0.42),
        ),
        boxShadow: elevation
            ? [
                BoxShadow(
                  color: scheme.shadow.withValues(
                    alpha: Theme.of(context).brightness == Brightness.dark
                        ? 0.24
                        : 0.08,
                  ),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ]
            : const [],
      ),
      child: logoGraphic,
    );
  }
}
