import 'package:flutter/material.dart';

/// Extension methods for Color
extension ColorExtension on Color {
  /// Convert color to hex string (e.g., "#FF5733" or "#80FF5733" with alpha)
  String toHex({bool includeAlpha = false}) {
    if (includeAlpha && alpha != 255) {
      return '#${alpha.toRadixString(16).padLeft(2, '0').toUpperCase()}'
          '${red.toRadixString(16).padLeft(2, '0').toUpperCase()}'
          '${green.toRadixString(16).padLeft(2, '0').toUpperCase()}'
          '${blue.toRadixString(16).padLeft(2, '0').toUpperCase()}';
    }
    return '#${red.toRadixString(16).padLeft(2, '0').toUpperCase()}'
        '${green.toRadixString(16).padLeft(2, '0').toUpperCase()}'
        '${blue.toRadixString(16).padLeft(2, '0').toUpperCase()}';
  }

  /// Create color with modified alpha (0.0 to 1.0)
  Color withOpacityValue(double opacity) {
    return withAlpha((opacity.clamp(0.0, 1.0) * 255).round());
  }

  /// Lighten color by percentage (0.0 to 1.0)
  Color lighten([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  /// Darken color by percentage (0.0 to 1.0)
  Color darken([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  /// Check if color is dark
  bool get isDark => computeLuminance() < 0.5;

  /// Check if color is light
  bool get isLight => !isDark;

  /// Get contrasting color (black or white)
  Color get contrastColor => isDark ? Colors.white : Colors.black;
}

/// Extension to parse color from string
extension ColorParsing on String {
  /// Parse hex color string to Color
  /// Supports: "#RGB", "#RRGGBB", "#AARRGGBB", "RGB", "RRGGBB", "AARRGGBB"
  Color? toColor() {
    try {
      String hex = replaceAll('#', '').trim();

      // Handle shorthand (RGB -> RRGGBB)
      if (hex.length == 3) {
        hex = hex.split('').map((c) => '$c$c').join();
      }

      // Handle RRGGBB
      if (hex.length == 6) {
        hex = 'FF$hex';
      }

      // Should now be AARRGGBB (8 chars)
      if (hex.length != 8) {
        return null;
      }

      return Color(int.parse(hex, radix: 16));
    } catch (_) {
      return null;
    }
  }

  /// Parse hex color with fallback
  Color toColorOrDefault([Color fallback = Colors.black]) {
    return toColor() ?? fallback;
  }
}