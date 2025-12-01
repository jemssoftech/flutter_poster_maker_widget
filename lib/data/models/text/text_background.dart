import 'package:flutter/material.dart';
import '../../../core/types/typedefs.dart';
import '../../../core/utils/json_utils.dart';

/// Background box for text
class TextBackground {
  final bool enabled;
  final Color color;
  final double paddingX;
  final double paddingY;
  final double cornerRadius;

  const TextBackground({
    this.enabled = false,
    this.color = Colors.yellow,
    this.paddingX = 8,
    this.paddingY = 4,
    this.cornerRadius = 4,
  });

  /// No background
  static const TextBackground none = TextBackground(enabled: false);

  /// Create from JSON
  factory TextBackground.fromJson(JsonMap? json) {
    if (json == null) return TextBackground.none;

    return TextBackground(
      enabled: JsonUtils.getValue<bool>(json, 'enabled', false)!,
      color: JsonUtils.parseColor(json['color'], Colors.yellow)!,
      paddingX: JsonUtils.getValue<double>(json, 'padding_x') ??
          (json['padding'] as Map<String, dynamic>?)?['x'] as double? ??
          8,
      paddingY: JsonUtils.getValue<double>(json, 'padding_y') ??
          (json['padding'] as Map<String, dynamic>?)?['y'] as double? ??
          4,
      cornerRadius: JsonUtils.getValue<double>(json, 'corner_radius', 4)!,
    );
  }

  /// Convert to JSON
  JsonMap toJson() => {
    'enabled': enabled,
    'color': JsonUtils.colorToJson(color),
    'padding': {'x': paddingX, 'y': paddingY},
    'corner_radius': cornerRadius,
  };

  /// Get padding as EdgeInsets
  EdgeInsets get padding => EdgeInsets.symmetric(
    horizontal: paddingX,
    vertical: paddingY,
  );

  /// Get border radius
  BorderRadius get borderRadius => BorderRadius.circular(cornerRadius);

  /// Create copy with modifications
  TextBackground copyWith({
    bool? enabled,
    Color? color,
    double? paddingX,
    double? paddingY,
    double? cornerRadius,
  }) {
    return TextBackground(
      enabled: enabled ?? this.enabled,
      color: color ?? this.color,
      paddingX: paddingX ?? this.paddingX,
      paddingY: paddingY ?? this.paddingY,
      cornerRadius: cornerRadius ?? this.cornerRadius,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TextBackground &&
        other.enabled == enabled &&
        other.color == color &&
        other.paddingX == paddingX &&
        other.paddingY == paddingY &&
        other.cornerRadius == cornerRadius;
  }

  @override
  int get hashCode => Object.hash(enabled, color, paddingX, paddingY, cornerRadius);
}