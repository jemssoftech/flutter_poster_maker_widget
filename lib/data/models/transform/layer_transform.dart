import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/types/typedefs.dart';
import '../../../core/utils/json_utils.dart';
import 'transform_origin.dart';

/// Represents the transform properties of a layer
/// Position values (x, y, width, height) are relative (0.0 to 1.0) to poster dimensions
class LayerTransform {
  /// X position (0.0 = left, 1.0 = right, 0.5 = center)
  final double x;

  /// Y position (0.0 = top, 1.0 = bottom, 0.5 = center)
  final double y;

  /// Width relative to poster width (null = auto from content)
  final double? width;

  /// Height relative to poster height (null = auto from content)
  final double? height;

  /// Scale factor for X axis
  final double scaleX;

  /// Scale factor for Y axis
  final double scaleY;

  /// Rotation in degrees (clockwise)
  final double rotation;

  /// Transform origin point
  final TransformOrigin origin;

  /// Flip horizontally
  final bool flipHorizontal;

  /// Flip vertically
  final bool flipVertical;

  const LayerTransform({
    this.x = 0.5,
    this.y = 0.5,
    this.width,
    this.height,
    this.scaleX = 1.0,
    this.scaleY = 1.0,
    this.rotation = 0.0,
    this.origin = const TransformOrigin(),
    this.flipHorizontal = false,
    this.flipVertical = false,
  });

  /// Default centered transform
  static const LayerTransform centered = LayerTransform();

  /// Create from JSON
  factory LayerTransform.fromJson(JsonMap? json) {
    if (json == null) return LayerTransform.centered;

    return LayerTransform(
      x: JsonUtils.getValue<double>(json, 'x', 0.5)!,
      y: JsonUtils.getValue<double>(json, 'y', 0.5)!,
      width: JsonUtils.getValue<double>(json, 'width'),
      height: JsonUtils.getValue<double>(json, 'height'),
      scaleX: JsonUtils.getValue<double>(json, 'scale_x') ??
          JsonUtils.getValue<double>(json, 'scale', 1.0)!,
      scaleY: JsonUtils.getValue<double>(json, 'scale_y') ??
          JsonUtils.getValue<double>(json, 'scale', 1.0)!,
      rotation: JsonUtils.getValue<double>(json, 'rotation', 0.0)!,
      origin: TransformOrigin.fromJson(
        json['origin'] as Map<String, dynamic>?,
      ),
      flipHorizontal: JsonUtils.getValue<bool>(json, 'flip_horizontal', false)!,
      flipVertical: JsonUtils.getValue<bool>(json, 'flip_vertical', false)!,
    );
  }

  /// Convert to JSON
  JsonMap toJson() => {
    'x': x,
    'y': y,
    if (width != null) 'width': width,
    if (height != null) 'height': height,
    'scale_x': scaleX,
    'scale_y': scaleY,
    'rotation': rotation,
    'origin': origin.toJson(),
    'flip_horizontal': flipHorizontal,
    'flip_vertical': flipVertical,
  };

  /// Get uniform scale (average of scaleX and scaleY)
  double get scale => (scaleX + scaleY) / 2;

  /// Check if transform has uniform scale
  bool get hasUniformScale => scaleX == scaleY;

  /// Check if layer is flipped
  bool get isFlipped => flipHorizontal || flipVertical;

  /// Get rotation in radians
  double get rotationRadians => rotation * (math.pi / 180);

  /// Calculate absolute position given poster size
  Offset absolutePosition(Size posterSize) {
    return Offset(
      x * posterSize.width,
      y * posterSize.height,
    );
  }

  /// Calculate absolute size given poster size
  Size? absoluteSize(Size posterSize) {
    if (width == null || height == null) return null;
    return Size(
      width! * posterSize.width,
      height! * posterSize.height,
    );
  }

  /// Calculate bounds rectangle given poster size
  Rect? bounds(Size posterSize) {
    final absSize = absoluteSize(posterSize);
    if (absSize == null) return null;

    final absPos = absolutePosition(posterSize);
    final originOffset = Offset(
      absSize.width * origin.x,
      absSize.height * origin.y,
    );

    return Rect.fromLTWH(
      absPos.dx - originOffset.dx,
      absPos.dy - originOffset.dy,
      absSize.width,
      absSize.height,
    );
  }

  /// Build transformation matrix
  Matrix4 buildMatrix(Size posterSize, [Size? contentSize]) {
    final matrix = Matrix4.identity();

    // Get actual size
    final size = absoluteSize(posterSize) ?? contentSize ?? Size.zero;
    final position = absolutePosition(posterSize);

    // Calculate origin offset in pixels
    final originOffsetX = size.width * origin.x;
    final originOffsetY = size.height * origin.y;

    // Translate to position
    matrix.translate(position.dx, position.dy);

    // Rotate around origin
    if (rotation != 0) {
      matrix.translate(originOffsetX, originOffsetY);
      matrix.rotateZ(rotationRadians);
      matrix.translate(-originOffsetX, -originOffsetY);
    }

    // Scale around origin
    if (scaleX != 1.0 || scaleY != 1.0) {
      matrix.translate(originOffsetX, originOffsetY);
      matrix.scale(
        scaleX * (flipHorizontal ? -1.0 : 1.0),
        scaleY * (flipVertical ? -1.0 : 1.0),
      );
      matrix.translate(-originOffsetX, -originOffsetY);
    } else if (flipHorizontal || flipVertical) {
      matrix.translate(originOffsetX, originOffsetY);
      matrix.scale(
        flipHorizontal ? -1.0 : 1.0,
        flipVertical ? -1.0 : 1.0,
      );
      matrix.translate(-originOffsetX, -originOffsetY);
    }

    // Offset by origin so the layer is centered on position
    matrix.translate(-originOffsetX, -originOffsetY);

    return matrix;
  }

  /// Create copy with modifications
  LayerTransform copyWith({
    double? x,
    double? y,
    double? width,
    double? height,
    double? scaleX,
    double? scaleY,
    double? rotation,
    TransformOrigin? origin,
    bool? flipHorizontal,
    bool? flipVertical,
    bool clearWidth = false,
    bool clearHeight = false,
  }) {
    return LayerTransform(
      x: x ?? this.x,
      y: y ?? this.y,
      width: clearWidth ? null : (width ?? this.width),
      height: clearHeight ? null : (height ?? this.height),
      scaleX: scaleX ?? this.scaleX,
      scaleY: scaleY ?? this.scaleY,
      rotation: rotation ?? this.rotation,
      origin: origin ?? this.origin,
      flipHorizontal: flipHorizontal ?? this.flipHorizontal,
      flipVertical: flipVertical ?? this.flipVertical,
    );
  }

  /// Create copy with uniform scale
  LayerTransform withScale(double scale) {
    return copyWith(scaleX: scale, scaleY: scale);
  }

  /// Translate by delta (relative values)
  LayerTransform translate(double dx, double dy) {
    return copyWith(x: x + dx, y: y + dy);
  }

  /// Rotate by delta (degrees)
  LayerTransform rotate(double degrees) {
    return copyWith(rotation: (rotation + degrees) % 360);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LayerTransform &&
        other.x == x &&
        other.y == y &&
        other.width == width &&
        other.height == height &&
        other.scaleX == scaleX &&
        other.scaleY == scaleY &&
        other.rotation == rotation &&
        other.origin == origin &&
        other.flipHorizontal == flipHorizontal &&
        other.flipVertical == flipVertical;
  }

  @override
  int get hashCode => Object.hash(
    x, y, width, height, scaleX, scaleY,
    rotation, origin, flipHorizontal, flipVertical,
  );

  @override
  String toString() => 'LayerTransform(x: $x, y: $y, rotation: $rotation)';
}