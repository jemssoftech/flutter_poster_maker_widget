import 'package:flutter/material.dart';
import '../../../core/types/typedefs.dart';
import '../../../core/utils/json_utils.dart';

/// Corner radius configuration for shapes
class CornerRadius {
  final double topLeft;
  final double topRight;
  final double bottomLeft;
  final double bottomRight;
  final bool uniform;

  const CornerRadius({
    this.topLeft = 0,
    this.topRight = 0,
    this.bottomLeft = 0,
    this.bottomRight = 0,
    this.uniform = true,
  });

  /// No corner radius
  static const CornerRadius zero = CornerRadius();

  /// Small uniform radius
  static const CornerRadius small = CornerRadius(
    topLeft: 4,
    topRight: 4,
    bottomLeft: 4,
    bottomRight: 4,
  );

  /// Medium uniform radius
  static const CornerRadius medium = CornerRadius(
    topLeft: 8,
    topRight: 8,
    bottomLeft: 8,
    bottomRight: 8,
  );

  /// Large uniform radius
  static const CornerRadius large = CornerRadius(
    topLeft: 16,
    topRight: 16,
    bottomLeft: 16,
    bottomRight: 16,
  );

  /// Create uniform corner radius
  factory CornerRadius.all(double radius) {
    return CornerRadius(
      topLeft: radius,
      topRight: radius,
      bottomLeft: radius,
      bottomRight: radius,
      uniform: true,
    );
  }

  /// Create from JSON
  factory CornerRadius.fromJson(JsonMap? json) {
    if (json == null) return CornerRadius.zero;

    return CornerRadius(
      topLeft: JsonUtils.getValue<double>(json, 'top_left', 0)!,
      topRight: JsonUtils.getValue<double>(json, 'top_right', 0)!,
      bottomLeft: JsonUtils.getValue<double>(json, 'bottom_left', 0)!,
      bottomRight: JsonUtils.getValue<double>(json, 'bottom_right', 0)!,
      uniform: JsonUtils.getValue<bool>(json, 'uniform', true)!,
    );
  }

  /// Convert to JSON
  JsonMap toJson() => {
    'top_left': topLeft,
    'top_right': topRight,
    'bottom_left': bottomLeft,
    'bottom_right': bottomRight,
    'uniform': uniform,
  };

  /// Get uniform radius value (average if not uniform)
  double get uniformValue {
    if (uniform) return topLeft;
    return (topLeft + topRight + bottomLeft + bottomRight) / 4;
  }

  /// Check if all corners have same radius
  bool get isUniform {
    return topLeft == topRight &&
        topRight == bottomLeft &&
        bottomLeft == bottomRight;
  }

  /// Check if any corner has radius
  bool get hasRadius {
    return topLeft > 0 || topRight > 0 || bottomLeft > 0 || bottomRight > 0;
  }

  /// Convert to Flutter BorderRadius
  BorderRadius toBorderRadius() {
    return BorderRadius.only(
      topLeft: Radius.circular(topLeft),
      topRight: Radius.circular(topRight),
      bottomLeft: Radius.circular(bottomLeft),
      bottomRight: Radius.circular(bottomRight),
    );
  }

  /// Create copy with modifications
  CornerRadius copyWith({
    double? topLeft,
    double? topRight,
    double? bottomLeft,
    double? bottomRight,
    bool? uniform,
  }) {
    return CornerRadius(
      topLeft: topLeft ?? this.topLeft,
      topRight: topRight ?? this.topRight,
      bottomLeft: bottomLeft ?? this.bottomLeft,
      bottomRight: bottomRight ?? this.bottomRight,
      uniform: uniform ?? this.uniform,
    );
  }

  /// Set all corners to same value
  CornerRadius withUniform(double radius) {
    return CornerRadius.all(radius);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CornerRadius &&
        other.topLeft == topLeft &&
        other.topRight == topRight &&
        other.bottomLeft == bottomLeft &&
        other.bottomRight == bottomRight;
  }

  @override
  int get hashCode => Object.hash(topLeft, topRight, bottomLeft, bottomRight);
}