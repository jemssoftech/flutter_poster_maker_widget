import 'package:flutter/material.dart';
import '../../../core/types/typedefs.dart';
import '../../../core/utils/json_utils.dart';
import '../gradient_stop.dart';

/// Fill type for shapes
enum FillType {
  solid,
  linearGradient,
  radialGradient,
  none,
}

/// Fill configuration for shapes
class ShapeFill {
  final FillType type;
  final Color? color;
  final double? opacity;
  final double? angle; // For linear gradient
  final List<GradientStop>? stops;
  final Offset? center; // For radial gradient
  final double? radius; // For radial gradient

  const ShapeFill({
    this.type = FillType.solid,
    this.color,
    this.opacity = 1.0,
    this.angle,
    this.stops,
    this.center,
    this.radius,
  });

  /// No fill
  static const ShapeFill none = ShapeFill(type: FillType.none);

  /// White fill
  static const ShapeFill white = ShapeFill(
    type: FillType.solid,
    color: Colors.white,
  );

  /// Black fill
  static const ShapeFill black = ShapeFill(
    type: FillType.solid,
    color: Colors.black,
  );

  /// Create solid fill
  factory ShapeFill.solid(Color color, [double opacity = 1.0]) {
    return ShapeFill(
      type: FillType.solid,
      color: color,
      opacity: opacity,
    );
  }

  /// Create linear gradient fill
  factory ShapeFill.linearGradient({
    required List<GradientStop> stops,
    double angle = 0,
  }) {
    return ShapeFill(
      type: FillType.linearGradient,
      stops: stops,
      angle: angle,
    );
  }

  /// Create radial gradient fill
  factory ShapeFill.radialGradient({
    required List<GradientStop> stops,
    Offset center = const Offset(0.5, 0.5),
    double radius = 0.5,
  }) {
    return ShapeFill(
      type: FillType.radialGradient,
      stops: stops,
      center: center,
      radius: radius,
    );
  }

  /// Create from JSON
  factory ShapeFill.fromJson(JsonMap? json) {
    if (json == null) return ShapeFill.none;

    final typeStr = json['type'] as String?;
    final type = FillType.values.firstWhere(
          (e) => e.name == typeStr || _snakeToCamel(typeStr ?? '') == e.name,
      orElse: () => FillType.solid,
    );

    return ShapeFill(
      type: type,
      color: JsonUtils.parseColor(json['color']),
      opacity: JsonUtils.getValue<double>(json, 'opacity', 1.0),
      angle: JsonUtils.getValue<double>(json, 'angle'),
      stops: (json['stops'] as List<dynamic>?)
          ?.map((e) => GradientStop.fromJson(e as JsonMap))
          .toList(),
      center: JsonUtils.parseOffset(json['center'] as JsonMap?),
      radius: JsonUtils.getValue<double>(json, 'radius'),
    );
  }

  /// Convert to JSON
  JsonMap toJson() {
    final json = <String, dynamic>{
      'type': _camelToSnake(type.name),
    };

    if (type == FillType.solid && color != null) {
      json['color'] = JsonUtils.colorToJson(color!);
      if (opacity != 1.0) json['opacity'] = opacity;
    }

    if (type == FillType.linearGradient) {
      json['angle'] = angle ?? 0;
      json['stops'] = stops?.map((s) => s.toJson()).toList() ?? [];
    }

    if (type == FillType.radialGradient) {
      json['center'] = JsonUtils.offsetToJson(center ?? const Offset(0.5, 0.5));
      json['radius'] = radius ?? 0.5;
      json['stops'] = stops?.map((s) => s.toJson()).toList() ?? [];
    }

    return json;
  }

  /// Convert to Flutter Paint
  Paint? toPaint(Rect bounds) {
    if (type == FillType.none) return null;

    final paint = Paint()..style = PaintingStyle.fill;

    switch (type) {
      case FillType.solid:
        paint.color = (color ?? Colors.black).withOpacity(opacity ?? 1.0);
        break;

      case FillType.linearGradient:
        if (stops != null && stops!.isNotEmpty) {
          final gradient = LinearGradient(
            colors: stops!.map((s) => s.color).toList(),
            stops: stops!.map((s) => s.offset).toList(),
            begin: _angleToAlignment(angle ?? 0),
            end: _angleToAlignment((angle ?? 0) + 180),
          );
          paint.shader = gradient.createShader(bounds);
        }
        break;

      case FillType.radialGradient:
        if (stops != null && stops!.isNotEmpty) {
          final gradient = RadialGradient(
            colors: stops!.map((s) => s.color).toList(),
            stops: stops!.map((s) => s.offset).toList(),
            center: Alignment(
              (center?.dx ?? 0.5) * 2 - 1,
              (center?.dy ?? 0.5) * 2 - 1,
            ),
            radius: radius ?? 0.5,
          );
          paint.shader = gradient.createShader(bounds);
        }
        break;

      case FillType.none:
        return null;
    }

    return paint;
  }

  /// Create copy with modifications
  ShapeFill copyWith({
    FillType? type,
    Color? color,
    double? opacity,
    double? angle,
    List<GradientStop>? stops,
    Offset? center,
    double? radius,
  }) {
    return ShapeFill(
      type: type ?? this.type,
      color: color ?? this.color,
      opacity: opacity ?? this.opacity,
      angle: angle ?? this.angle,
      stops: stops ?? this.stops,
      center: center ?? this.center,
      radius: radius ?? this.radius,
    );
  }

  static Alignment _angleToAlignment(double angle) {
    final radians = angle * (3.14159265359 / 180);
    return Alignment(
      (1.0 * (angle == 90 || angle == 270 ? 0 : (angle < 180 ? 1 : -1))),
      (1.0 * (angle == 0 || angle == 180 ? 0 : (angle < 90 || angle > 270 ? -1 : 1))),
    );
  }

  static String _snakeToCamel(String text) {
    return text.replaceAllMapped(
      RegExp(r'_([a-z])'),
          (match) => match.group(1)!.toUpperCase(),
    );
  }

  static String _camelToSnake(String text) {
    return text.replaceAllMapped(
      RegExp(r'[A-Z]'),
          (match) => '_${match.group(0)!.toLowerCase()}',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ShapeFill &&
        other.type == type &&
        other.color == color &&
        other.opacity == opacity;
  }

  @override
  int get hashCode => Object.hash(type, color, opacity);
}