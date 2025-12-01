import 'package:flutter/material.dart';
import '../../core/types/typedefs.dart';
import '../../core/utils/json_utils.dart';

/// A color stop in a gradient
class GradientStop {
  final double offset; // 0.0 to 1.0
  final Color color;

  const GradientStop({
    required this.offset,
    required this.color,
  });

  /// Create from JSON
  factory GradientStop.fromJson(JsonMap json) {
    return GradientStop(
      offset: JsonUtils.getValue<double>(json, 'offset', 0.0)!,
      color: JsonUtils.parseColor(json['color'], Colors.black)!,
    );
  }

  /// Convert to JSON
  JsonMap toJson() => {
    'offset': offset,
    'color': JsonUtils.colorToJson(color),
  };

  /// Create copy with modifications
  GradientStop copyWith({
    double? offset,
    Color? color,
  }) {
    return GradientStop(
      offset: offset ?? this.offset,
      color: color ?? this.color,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GradientStop && other.offset == offset && other.color == color;
  }

  @override
  int get hashCode => Object.hash(offset, color);
}