import 'dart:math' as math;
import 'dart:ui' show Offset, Size, Rect;

import 'package:flutter/material.dart' show Matrix4;
import 'package:get/get.dart';

import '../../data/models/transform/layer_transform.dart';
import '../../data/models/selection/selection_state.dart';

/// Service for handling transform calculations
class TransformService extends GetxService {

  /// Calculate new transform for move operation
  LayerTransform calculateMove({
    required LayerTransform current,
    required Offset delta,
    required Size canvasSize,
  }) {
    // Convert pixel delta to relative delta
    final relativeDeltaX = delta.dx / canvasSize.width;
    final relativeDeltaY = delta.dy / canvasSize.height;

    return current.copyWith(
      x: (current.x + relativeDeltaX).clamp(0.0, 1.0),
      y: (current.y + relativeDeltaY).clamp(0.0, 1.0),
    );
  }

  /// Calculate new transform for resize operation
  LayerTransform calculateResize({
    required LayerTransform current,
    required HandlePosition handle,
    required Offset delta,
    required Size canvasSize,
    required Size originalSize,
    bool maintainAspectRatio = true,
  }) {
    // Get current size in pixels
    final currentWidth = (current.width ?? 0.5) * canvasSize.width;
    final currentHeight = (current.height ?? 0.5) * canvasSize.height;

    double newWidth = currentWidth;
    double newHeight = currentHeight;
    double newX = current.x;
    double newY = current.y;

    // Calculate size changes based on handle
    switch (handle) {
      case HandlePosition.topLeft:
        newWidth = currentWidth - delta.dx;
        newHeight = currentHeight - delta.dy;
        newX = current.x + (delta.dx / 2) / canvasSize.width;
        newY = current.y + (delta.dy / 2) / canvasSize.height;
        break;

      case HandlePosition.topCenter:
        newHeight = currentHeight - delta.dy;
        newY = current.y + (delta.dy / 2) / canvasSize.height;
        break;

      case HandlePosition.topRight:
        newWidth = currentWidth + delta.dx;
        newHeight = currentHeight - delta.dy;
        newX = current.x + (delta.dx / 2) / canvasSize.width;
        newY = current.y + (delta.dy / 2) / canvasSize.height;
        break;

      case HandlePosition.centerLeft:
        newWidth = currentWidth - delta.dx;
        newX = current.x + (delta.dx / 2) / canvasSize.width;
        break;

      case HandlePosition.centerRight:
        newWidth = currentWidth + delta.dx;
        newX = current.x + (delta.dx / 2) / canvasSize.width;
        break;

      case HandlePosition.bottomLeft:
        newWidth = currentWidth - delta.dx;
        newHeight = currentHeight + delta.dy;
        newX = current.x + (delta.dx / 2) / canvasSize.width;
        newY = current.y + (delta.dy / 2) / canvasSize.height;
        break;

      case HandlePosition.bottomCenter:
        newHeight = currentHeight + delta.dy;
        newY = current.y + (delta.dy / 2) / canvasSize.height;
        break;

      case HandlePosition.bottomRight:
        newWidth = currentWidth + delta.dx;
        newHeight = currentHeight + delta.dy;
        newX = current.x + (delta.dx / 2) / canvasSize.width;
        newY = current.y + (delta.dy / 2) / canvasSize.height;
        break;

      case HandlePosition.rotation:
      // Rotation is handled separately
        return current;
    }

    // Maintain aspect ratio if needed
    if (maintainAspectRatio && handle.isCorner) {
      final aspectRatio = currentWidth / currentHeight;
      if (delta.dx.abs() > delta.dy.abs()) {
        newHeight = newWidth / aspectRatio;
      } else {
        newWidth = newHeight * aspectRatio;
      }
    }

    // Ensure minimum size
    const minSize = 20.0;
    newWidth = newWidth.clamp(minSize, canvasSize.width * 2);
    newHeight = newHeight.clamp(minSize, canvasSize.height * 2);

    return current.copyWith(
      x: newX.clamp(0.0, 1.0),
      y: newY.clamp(0.0, 1.0),
      width: newWidth / canvasSize.width,
      height: newHeight / canvasSize.height,
    );
  }

  /// Calculate new transform for rotation operation
  LayerTransform calculateRotation({
    required LayerTransform current,
    required Offset center,
    required Offset startPosition,
    required Offset currentPosition,
    bool snapToAngles = false,
  }) {
    // Calculate angles
    final startAngle = math.atan2(
      startPosition.dy - center.dy,
      startPosition.dx - center.dx,
    );
    final currentAngle = math.atan2(
      currentPosition.dy - center.dy,
      currentPosition.dx - center.dx,
    );

    // Calculate delta angle in degrees
    double deltaAngle = (currentAngle - startAngle) * (180 / math.pi);
    double newRotation = current.rotation + deltaAngle;

    // Normalize to 0-360
    newRotation = newRotation % 360;
    if (newRotation < 0) newRotation += 360;

    // Snap to common angles if enabled
    if (snapToAngles) {
      const snapAngles = [0.0, 45.0, 90.0, 135.0, 180.0, 225.0, 270.0, 315.0, 360.0];
      for (final snapAngle in snapAngles) {
        if ((newRotation - snapAngle).abs() < 5) {
          newRotation = snapAngle;
          break;
        }
      }
    }

    return current.copyWith(rotation: newRotation);
  }

  /// Calculate bounds rectangle for a layer
  Rect calculateBounds({
    required LayerTransform transform,
    required Size canvasSize,
    Size? contentSize,
  }) {
    final width = transform.width != null
        ? transform.width! * canvasSize.width
        : contentSize?.width ?? 100;
    final height = transform.height != null
        ? transform.height! * canvasSize.height
        : contentSize?.height ?? 100;

    final centerX = transform.x * canvasSize.width;
    final centerY = transform.y * canvasSize.height;

    return Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: width * transform.scaleX,
      height: height * transform.scaleY,
    );
  }

  /// Calculate rotated bounds (axis-aligned bounding box of rotated rect)
  Rect calculateRotatedBounds({
    required LayerTransform transform,
    required Size canvasSize,
    Size? contentSize,
  }) {
    final bounds = calculateBounds(
      transform: transform,
      canvasSize: canvasSize,
      contentSize: contentSize,
    );

    if (transform.rotation == 0) return bounds;

    // Calculate corners
    final center = bounds.center;
    final halfWidth = bounds.width / 2;
    final halfHeight = bounds.height / 2;

    final corners = [
      Offset(-halfWidth, -halfHeight),
      Offset(halfWidth, -halfHeight),
      Offset(halfWidth, halfHeight),
      Offset(-halfWidth, halfHeight),
    ];

    // Rotate corners
    final radians = transform.rotation * (math.pi / 180);
    final cos = math.cos(radians);
    final sin = math.sin(radians);

    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (final corner in corners) {
      final rotatedX = corner.dx * cos - corner.dy * sin + center.dx;
      final rotatedY = corner.dx * sin + corner.dy * cos + center.dy;

      minX = math.min(minX, rotatedX);
      minY = math.min(minY, rotatedY);
      maxX = math.max(maxX, rotatedX);
      maxY = math.max(maxY, rotatedY);
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  /// Build transformation matrix for rendering
  Matrix4 buildMatrix({
    required LayerTransform transform,
    required Size canvasSize,
    Size? contentSize,
  }) {
    final matrix = Matrix4.identity();

    // Get position in pixels
    final x = transform.x * canvasSize.width;
    final y = transform.y * canvasSize.height;

    // Translate to position
    matrix.translate(x, y);

    // Apply rotation
    if (transform.rotation != 0) {
      matrix.rotateZ(transform.rotation * (math.pi / 180));
    }

    // Apply scale
    matrix.scale(
      transform.scaleX * (transform.flipHorizontal ? -1.0 : 1.0),
      transform.scaleY * (transform.flipVertical ? -1.0 : 1.0),
    );

    return matrix;
  }

  /// Check if a point is inside the layer bounds (considering rotation)
  bool hitTest({
    required Offset point,
    required LayerTransform transform,
    required Size canvasSize,
    Size? contentSize,
  }) {
    final bounds = calculateBounds(
      transform: transform,
      canvasSize: canvasSize,
      contentSize: contentSize,
    );

    if (transform.rotation == 0) {
      return bounds.contains(point);
    }

    // Transform point to layer's local space
    final center = bounds.center;
    final radians = -transform.rotation * (math.pi / 180);
    final cos = math.cos(radians);
    final sin = math.sin(radians);

    final localX = (point.dx - center.dx) * cos - (point.dy - center.dy) * sin;
    final localY = (point.dx - center.dx) * sin + (point.dy - center.dy) * cos;

    final localBounds = Rect.fromCenter(
      center: Offset.zero,
      width: bounds.width,
      height: bounds.height,
    );

    return localBounds.contains(Offset(localX, localY));
  }
}