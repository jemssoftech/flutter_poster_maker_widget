import 'package:flutter/material.dart';
import '../extensions/color_extension.dart';

/// Utility class for JSON parsing helpers
class JsonUtils {
  JsonUtils._();

  /// Safely get value from map with type checking
  static T? getValue<T>(Map<String, dynamic>? json, String key, [T? defaultValue]) {
    if (json == null || !json.containsKey(key)) {
      return defaultValue;
    }

    final value = json[key];
    if (value == null) {
      return defaultValue;
    }

    if (value is T) {
      return value;
    }

    // Handle type conversions
    if (T == double && value is int) {
      return value.toDouble() as T;
    }
    if (T == int && value is double) {
      return value.toInt() as T;
    }

    return defaultValue;
  }

  /// Get required value, throws if missing
  static T getRequired<T>(Map<String, dynamic> json, String key, String context) {
    if (!json.containsKey(key)) {
      throw FormatException('Missing required field "$key" in $context');
    }

    final value = json[key];
    if (value == null) {
      throw FormatException('Field "$key" cannot be null in $context');
    }

    if (value is T) {
      return value;
    }

    // Handle type conversions
    if (T == double && value is int) {
      return value.toDouble() as T;
    }

    throw FormatException(
      'Field "$key" expected ${T.toString()} but got ${value.runtimeType} in $context',
    );
  }

  /// Parse color from JSON (supports hex string)
  static Color? parseColor(dynamic value, [Color? defaultValue]) {
    if (value == null) return defaultValue;
    if (value is String) {
      return value.toColor() ?? defaultValue;
    }
    return defaultValue;
  }

  /// Parse color, throws if invalid
  static Color parseColorRequired(dynamic value, String field) {
    if (value == null) {
      throw FormatException('Color field "$field" cannot be null');
    }
    if (value is String) {
      final color = value.toColor();
      if (color != null) return color;
    }
    throw FormatException('Invalid color value for "$field": $value');
  }

  /// Convert color to JSON string
  static String? colorToJson(Color? color, {bool includeAlpha = true}) {
    if (color == null) return null;
    return color.toHex(includeAlpha: includeAlpha);
  }

  /// Parse list from JSON
  static List<T> parseList<T>(
      dynamic value,
      T Function(dynamic) parser, [
        List<T> defaultValue = const [],
      ]) {
    if (value == null) return defaultValue;
    if (value is! List) return defaultValue;

    return value.map((item) => parser(item)).toList();
  }

  /// Parse map from JSON
  static Map<String, T> parseMap<T>(
      dynamic value,
      T Function(dynamic) parser, [
        Map<String, T> defaultValue = const {},
      ]) {
    if (value == null) return defaultValue;
    if (value is! Map<String, dynamic>) return defaultValue;

    return value.map((key, val) => MapEntry(key, parser(val)));
  }

  /// Parse enum from string
  static T? parseEnum<T extends Enum>(String? value, List<T> values) {
    if (value == null) return null;

    for (final enumValue in values) {
      if (enumValue.name == value || enumValue.toString().split('.').last == value) {
        return enumValue;
      }
    }
    return null;
  }

  /// Convert enum to JSON string
  static String? enumToJson<T extends Enum>(T? value) {
    return value?.name;
  }

  /// Parse Offset from JSON
  static Offset? parseOffset(Map<String, dynamic>? json, [Offset? defaultValue]) {
    if (json == null) return defaultValue;

    final x = getValue<double>(json, 'x') ?? getValue<double>(json, 'dx');
    final y = getValue<double>(json, 'y') ?? getValue<double>(json, 'dy');

    if (x == null || y == null) return defaultValue;
    return Offset(x, y);
  }

  /// Convert Offset to JSON
  static Map<String, dynamic>? offsetToJson(Offset? offset) {
    if (offset == null) return null;
    return {'x': offset.dx, 'y': offset.dy};
  }

  /// Parse Size from JSON
  static Size? parseSize(Map<String, dynamic>? json, [Size? defaultValue]) {
    if (json == null) return defaultValue;

    final width = getValue<double>(json, 'width');
    final height = getValue<double>(json, 'height');

    if (width == null || height == null) return defaultValue;
    return Size(width, height);
  }

  /// Convert Size to JSON
  static Map<String, dynamic>? sizeToJson(Size? size) {
    if (size == null) return null;
    return {'width': size.width, 'height': size.height};
  }

  /// Deep clone a JSON map
  static Map<String, dynamic> deepClone(Map<String, dynamic> json) {
    return json.map((key, value) {
      if (value is Map<String, dynamic>) {
        return MapEntry(key, deepClone(value));
      }
      if (value is List) {
        return MapEntry(key, _deepCloneList(value));
      }
      return MapEntry(key, value);
    });
  }

  static List<dynamic> _deepCloneList(List<dynamic> list) {
    return list.map((item) {
      if (item is Map<String, dynamic>) {
        return deepClone(item);
      }
      if (item is List) {
        return _deepCloneList(item);
      }
      return item;
    }).toList();
  }
}