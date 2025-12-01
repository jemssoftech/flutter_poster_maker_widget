import 'package:flutter/material.dart';
import '../../../core/types/typedefs.dart';
import '../../../core/utils/json_utils.dart';

/// Stroke line cap style
enum StrokeLineCap {
  butt,
  round,
  square,
}

/// Stroke line join style
enum StrokeLineJoin {
  miter,
  round,
  bevel,
}

/// Arrow style for lines
enum ArrowStyle {
  none,
  triangle,
  circle,
  diamond,
  open,
}

/// Stroke configuration for shapes
class ShapeStroke {
  final bool enabled;
  final Color color;
  final double width;
  final StrokeLineCap lineCap;
  final StrokeLineJoin lineJoin;
  final List<double>? dashArray;
  final double? dashOffset;
  final ArrowStyle startArrow;
  final ArrowStyle endArrow;

  const ShapeStroke({
    this.enabled = true,
    this.color = Colors.black,
    this.width = 2.0,
    this.lineCap = StrokeLineCap.round,
    this.lineJoin = StrokeLineJoin.round,
    this.dashArray,
    this.dashOffset,
    this.startArrow = ArrowStyle.none,
    this.endArrow = ArrowStyle.none,
  });

  /// No stroke
  static const ShapeStroke none = ShapeStroke(enabled: false);

  /// Thin black stroke
  static const ShapeStroke thin = ShapeStroke(width: 1.0);

  /// Medium black stroke
  static const ShapeStroke medium = ShapeStroke(width: 2.0);

  /// Thick black stroke
  static const ShapeStroke thick = ShapeStroke(width: 4.0);

  /// Dashed stroke
  factory ShapeStroke.dashed({
    Color color = Colors.black,
    double width = 2.0,
    double dashLength = 10.0,
    double gapLength = 5.0,
  }) {
    return ShapeStroke(
      color: color,
      width: width,
      dashArray: [dashLength, gapLength],
    );
  }

  /// Dotted stroke
  factory ShapeStroke.dotted({
    Color color = Colors.black,
    double width = 2.0,
  }) {
    return ShapeStroke(
      color: color,
      width: width,
      dashArray: [width, width * 2],
      lineCap: StrokeLineCap.round,
    );
  }

  /// Create from JSON
  factory ShapeStroke.fromJson(JsonMap? json) {
    if (json == null) return ShapeStroke.none;

    return ShapeStroke(
      enabled: JsonUtils.getValue<bool>(json, 'enabled', true)!,
      color: JsonUtils.parseColor(json['color'], Colors.black)!,
      width: JsonUtils.getValue<double>(json, 'width', 2.0)!,
      lineCap: JsonUtils.parseEnum(
        json['line_cap'] as String?,
        StrokeLineCap.values,
      ) ??
          StrokeLineCap.round,
      lineJoin: JsonUtils.parseEnum(
        json['line_join'] as String?,
        StrokeLineJoin.values,
      ) ??
          StrokeLineJoin.round,
      dashArray: (json['dash_array'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
      dashOffset: JsonUtils.getValue<double>(json, 'dash_offset'),
      startArrow: JsonUtils.parseEnum(
        json['start_arrow'] as String?,
        ArrowStyle.values,
      ) ??
          ArrowStyle.none,
      endArrow: JsonUtils.parseEnum(
        json['end_arrow'] as String?,
        ArrowStyle.values,
      ) ??
          ArrowStyle.none,
    );
  }

  /// Convert to JSON
  JsonMap toJson() => {
    'enabled': enabled,
    'color': JsonUtils.colorToJson(color),
    'width': width,
    'line_cap': lineCap.name,
    'line_join': lineJoin.name,
    if (dashArray != null) 'dash_array': dashArray,
    if (dashOffset != null) 'dash_offset': dashOffset,
    if (startArrow != ArrowStyle.none) 'start_arrow': startArrow.name,
    if (endArrow != ArrowStyle.none) 'end_arrow': endArrow.name,
  };

  /// Check if stroke is dashed
  bool get isDashed => dashArray != null && dashArray!.isNotEmpty;

  /// Convert to Flutter Paint
  Paint? toPaint() {
    if (!enabled) return null;

    return Paint()
      ..style = PaintingStyle.stroke
      ..color = color
      ..strokeWidth = width
      ..strokeCap = _toStrokeCap(lineCap)
      ..strokeJoin = _toStrokeJoin(lineJoin);
  }

  StrokeCap _toStrokeCap(StrokeLineCap cap) {
    switch (cap) {
      case StrokeLineCap.butt:
        return StrokeCap.butt;
      case StrokeLineCap.round:
        return StrokeCap.round;
      case StrokeLineCap.square:
        return StrokeCap.square;
    }
  }

  StrokeJoin _toStrokeJoin(StrokeLineJoin join) {
    switch (join) {
      case StrokeLineJoin.miter:
        return StrokeJoin.miter;
      case StrokeLineJoin.round:
        return StrokeJoin.round;
      case StrokeLineJoin.bevel:
        return StrokeJoin.bevel;
    }
  }

  /// Create copy with modifications
  ShapeStroke copyWith({
    bool? enabled,
    Color? color,
    double? width,
    StrokeLineCap? lineCap,
    StrokeLineJoin? lineJoin,
    List<double>? dashArray,
    double? dashOffset,
    ArrowStyle? startArrow,
    ArrowStyle? endArrow,
  }) {
    return ShapeStroke(
      enabled: enabled ?? this.enabled,
      color: color ?? this.color,
      width: width ?? this.width,
      lineCap: lineCap ?? this.lineCap,
      lineJoin: lineJoin ?? this.lineJoin,
      dashArray: dashArray ?? this.dashArray,
      dashOffset: dashOffset ?? this.dashOffset,
      startArrow: startArrow ?? this.startArrow,
      endArrow: endArrow ?? this.endArrow,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ShapeStroke &&
        other.enabled == enabled &&
        other.color == color &&
        other.width == width &&
        other.lineCap == lineCap &&
        other.lineJoin == lineJoin;
  }

  @override
  int get hashCode => Object.hash(enabled, color, width, lineCap, lineJoin);
}