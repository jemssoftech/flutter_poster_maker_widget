import 'package:flutter/material.dart';
import '../../../core/types/typedefs.dart';
import '../../../core/utils/json_utils.dart';
import '../../../core/constants/editor_constants.dart';
import '../transform/layer_transform.dart';
import '../effects/layer_effects.dart';
import '../shapes/shape_type.dart';
import '../shapes/shape_fill.dart';
import '../shapes/shape_stroke.dart';
import '../shapes/corner_radius.dart';
import 'layer_base.dart';

/// Shape-specific properties for polygon/star
class ShapeSpecificProps {
  /// Number of sides (polygon) or points (star)
  final int? sides;

  /// Inner radius ratio for stars (0.0 to 1.0)
  final double? innerRadiusRatio;

  /// Start arrow style (for lines)
  final String? startArrow;

  /// End arrow style (for lines)
  final String? endArrow;

  const ShapeSpecificProps({
    this.sides,
    this.innerRadiusRatio,
    this.startArrow,
    this.endArrow,
  });

  /// Empty props
  static const ShapeSpecificProps empty = ShapeSpecificProps();

  /// Create from JSON
  factory ShapeSpecificProps.fromJson(JsonMap? json) {
    if (json == null) return ShapeSpecificProps.empty;

    return ShapeSpecificProps(
      sides: JsonUtils.getValue<int>(json, 'sides'),
      innerRadiusRatio: JsonUtils.getValue<double>(json, 'inner_radius_ratio'),
      startArrow: JsonUtils.getValue<String>(json, 'start_arrow'),
      endArrow: JsonUtils.getValue<String>(json, 'end_arrow'),
    );
  }

  /// Convert to JSON
  JsonMap toJson() => {
    if (sides != null) 'sides': sides,
    if (innerRadiusRatio != null) 'inner_radius_ratio': innerRadiusRatio,
    if (startArrow != null) 'start_arrow': startArrow,
    if (endArrow != null) 'end_arrow': endArrow,
  };

  /// Create copy with modifications
  ShapeSpecificProps copyWith({
    int? sides,
    double? innerRadiusRatio,
    String? startArrow,
    String? endArrow,
  }) {
    return ShapeSpecificProps(
      sides: sides ?? this.sides,
      innerRadiusRatio: innerRadiusRatio ?? this.innerRadiusRatio,
      startArrow: startArrow ?? this.startArrow,
      endArrow: endArrow ?? this.endArrow,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ShapeSpecificProps &&
        other.sides == sides &&
        other.innerRadiusRatio == innerRadiusRatio &&
        other.startArrow == startArrow &&
        other.endArrow == endArrow;
  }

  @override
  int get hashCode => Object.hash(sides, innerRadiusRatio, startArrow, endArrow);
}

/// Shape layer
class ShapeLayer extends LayerBase {
  /// Shape type
  final ShapeType shapeType;

  /// Fill configuration
  final ShapeFill fill;

  /// Stroke configuration
  final ShapeStroke stroke;

  /// Corner radius (for rectangles)
  final CornerRadius cornerRadius;

  /// Shape-specific properties
  final ShapeSpecificProps shapeSpecific;

  const ShapeLayer({
    required super.id,
    required super.name,
    super.visible,
    super.locked,
    super.opacity,
    super.blendMode,
    super.transform,
    super.effects,
    required this.shapeType,
    this.fill = const ShapeFill(),
    this.stroke = const ShapeStroke(),
    this.cornerRadius = const CornerRadius(),
    this.shapeSpecific = const ShapeSpecificProps(),
  }) : super(type: LayerTypes.shape);

  /// Check if shape has fill
  bool get hasFill => fill.type != FillType.none;

  /// Check if shape has stroke
  bool get hasStroke => stroke.enabled;

  /// Get number of sides (for polygon/star)
  int get sides => shapeSpecific.sides ?? shapeType.defaultSides;

  /// Get inner radius ratio (for star)
  double get innerRadiusRatio => shapeSpecific.innerRadiusRatio ?? 0.4;

  /// Create from JSON
  factory ShapeLayer.fromJson(JsonMap json) {
    final props = LayerJsonParser.parseProps(json);

    return ShapeLayer(
      id: LayerJsonParser.parseId(json),
      name: LayerJsonParser.parseName(json, 'Shape'),
      visible: LayerJsonParser.parseVisible(json),
      locked: LayerJsonParser.parseLocked(json),
      opacity: LayerJsonParser.parseOpacity(json),
      blendMode: LayerJsonParser.parseBlendMode(json),
      transform: LayerJsonParser.parseTransform(json),
      effects: LayerJsonParser.parseEffects(json),
      shapeType: ShapeTypeExtension.fromString(
        JsonUtils.getValue<String>(props, 'shape_type'),
      ) ??
          ShapeType.rectangle,
      fill: ShapeFill.fromJson(props['fill'] as JsonMap?),
      stroke: ShapeStroke.fromJson(props['stroke'] as JsonMap?),
      cornerRadius: CornerRadius.fromJson(props['corner_radius'] as JsonMap?),
      shapeSpecific: ShapeSpecificProps.fromJson(props['shape_specific'] as JsonMap?),
    );
  }

  @override
  JsonMap propsToJson() => {
    'shape_type': shapeType.name,
    'fill': fill.toJson(),
    'stroke': stroke.toJson(),
    'corner_radius': cornerRadius.toJson(),
    'shape_specific': shapeSpecific.toJson(),
  };

  @override
  ShapeLayer copyWith({
    String? id,
    String? name,
    bool? visible,
    bool? locked,
    double? opacity,
    LayerBlendMode? blendMode,
    LayerTransform? transform,
    LayerEffects? effects,
    ShapeType? shapeType,
    ShapeFill? fill,
    ShapeStroke? stroke,
    CornerRadius? cornerRadius,
    ShapeSpecificProps? shapeSpecific,
  }) {
    return ShapeLayer(
      id: id ?? this.id,
      name: name ?? this.name,
      visible: visible ?? this.visible,
      locked: locked ?? this.locked,
      opacity: opacity ?? this.opacity,
      blendMode: blendMode ?? this.blendMode,
      transform: transform ?? this.transform,
      effects: effects ?? this.effects,
      shapeType: shapeType ?? this.shapeType,
      fill: fill ?? this.fill,
      stroke: stroke ?? this.stroke,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      shapeSpecific: shapeSpecific ?? this.shapeSpecific,
    );
  }

  @override
  ShapeLayer withTransform(LayerTransform transform) {
    return copyWith(transform: transform);
  }

  @override
  ShapeLayer withEffects(LayerEffects effects) {
    return copyWith(effects: effects);
  }

  /// Create rectangle shape layer
  factory ShapeLayer.rectangle({
    required String id,
    String name = 'Rectangle',
    Color fillColor = Colors.blue,
    CornerRadius cornerRadius = const CornerRadius(),
    LayerTransform transform = const LayerTransform(),
  }) {
    return ShapeLayer(
      id: id,
      name: name,
      shapeType: ShapeType.rectangle,
      fill: ShapeFill.solid(fillColor),
      cornerRadius: cornerRadius,
      transform: transform,
    );
  }

  /// Create circle shape layer
  factory ShapeLayer.circle({
    required String id,
    String name = 'Circle',
    Color fillColor = Colors.blue,
    LayerTransform transform = const LayerTransform(),
  }) {
    return ShapeLayer(
      id: id,
      name: name,
      shapeType: ShapeType.circle,
      fill: ShapeFill.solid(fillColor),
      transform: transform,
    );
  }

  /// Create line shape layer
  factory ShapeLayer.line({
    required String id,
    String name = 'Line',
    Color strokeColor = Colors.black,
    double strokeWidth = 2,
    LayerTransform transform = const LayerTransform(),
  }) {
    return ShapeLayer(
      id: id,
      name: name,
      shapeType: ShapeType.line,
      fill: ShapeFill.none,
      stroke: ShapeStroke(
        color: strokeColor,
        width: strokeWidth,
      ),
      transform: transform,
    );
  }

  /// Create polygon shape layer
  factory ShapeLayer.polygon({
    required String id,
    String name = 'Polygon',
    Color fillColor = Colors.blue,
    int sides = 6,
    LayerTransform transform = const LayerTransform(),
  }) {
    return ShapeLayer(
      id: id,
      name: name,
      shapeType: ShapeType.polygon,
      fill: ShapeFill.solid(fillColor),
      shapeSpecific: ShapeSpecificProps(sides: sides),
      transform: transform,
    );
  }

  /// Create star shape layer
  factory ShapeLayer.star({
    required String id,
    String name = 'Star',
    Color fillColor = Colors.yellow,
    int points = 5,
    double innerRadiusRatio = 0.4,
    LayerTransform transform = const LayerTransform(),
  }) {
    return ShapeLayer(
      id: id,
      name: name,
      shapeType: ShapeType.star,
      fill: ShapeFill.solid(fillColor),
      shapeSpecific: ShapeSpecificProps(
        sides: points,
        innerRadiusRatio: innerRadiusRatio,
      ),
      transform: transform,
    );
  }
}