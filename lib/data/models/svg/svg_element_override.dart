import 'package:flutter/material.dart';
import '../../../core/types/typedefs.dart';
import '../../../core/utils/json_utils.dart';

/// Override values for a specific SVG element
class SvgElementOverride {
  final Color? fill;
  final Color? stroke;
  final double? strokeWidth;
  final double? opacity;

  const SvgElementOverride({
    this.fill,
    this.stroke,
    this.strokeWidth,
    this.opacity,
  });

  /// Empty override (no changes)
  static const SvgElementOverride empty = SvgElementOverride();

  /// Check if override has any values
  bool get hasOverrides {
    return fill != null || stroke != null || strokeWidth != null || opacity != null;
  }

  /// Create from JSON
  factory SvgElementOverride.fromJson(JsonMap? json) {
    if (json == null) return SvgElementOverride.empty;

    return SvgElementOverride(
      fill: JsonUtils.parseColor(json['fill']),
      stroke: JsonUtils.parseColor(json['stroke']),
      strokeWidth: JsonUtils.getValue<double>(json, 'stroke_width'),
      opacity: JsonUtils.getValue<double>(json, 'opacity'),
    );
  }

  /// Convert to JSON
  JsonMap toJson() => {
    if (fill != null) 'fill': JsonUtils.colorToJson(fill),
    if (stroke != null) 'stroke': JsonUtils.colorToJson(stroke),
    if (strokeWidth != null) 'stroke_width': strokeWidth,
    if (opacity != null) 'opacity': opacity,
  };

  /// Create copy with modifications
  SvgElementOverride copyWith({
    Color? fill,
    Color? stroke,
    double? strokeWidth,
    double? opacity,
    bool clearFill = false,
    bool clearStroke = false,
    bool clearStrokeWidth = false,
    bool clearOpacity = false,
  }) {
    return SvgElementOverride(
      fill: clearFill ? null : (fill ?? this.fill),
      stroke: clearStroke ? null : (stroke ?? this.stroke),
      strokeWidth: clearStrokeWidth ? null : (strokeWidth ?? this.strokeWidth),
      opacity: clearOpacity ? null : (opacity ?? this.opacity),
    );
  }

  /// Merge with another override (other takes precedence)
  SvgElementOverride merge(SvgElementOverride other) {
    return SvgElementOverride(
      fill: other.fill ?? fill,
      stroke: other.stroke ?? stroke,
      strokeWidth: other.strokeWidth ?? strokeWidth,
      opacity: other.opacity ?? opacity,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SvgElementOverride &&
        other.fill == fill &&
        other.stroke == stroke &&
        other.strokeWidth == strokeWidth &&
        other.opacity == opacity;
  }

  @override
  int get hashCode => Object.hash(fill, stroke, strokeWidth, opacity);
}