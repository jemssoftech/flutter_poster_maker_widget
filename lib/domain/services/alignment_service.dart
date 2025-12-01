import 'dart:math' as math;
import 'dart:ui' show Offset, Rect, Size;

import 'package:get/get.dart';

import '../../core/constants/editor_constants.dart';

/// Snap result containing the snapped position and guide lines to show
class SnapResult {
  final Offset position;
  final List<SnapGuide> guides;
  final bool snappedX;
  final bool snappedY;

  const SnapResult({
    required this.position,
    this.guides = const [],
    this.snappedX = false,
    this.snappedY = false,
  });

  bool get didSnap => snappedX || snappedY;
}

/// A visual guide line for snapping
class SnapGuide {
  final Offset start;
  final Offset end;
  final SnapGuideType type;

  const SnapGuide({
    required this.start,
    required this.end,
    required this.type,
  });
}

/// Types of snap guides
enum SnapGuideType {
  center,
  edge,
  object,
}

/// Alignment type for layer alignment
enum AlignmentType {
  left,
  centerHorizontal,
  right,
  top,
  centerVertical,
  bottom,
  distributeHorizontal,
  distributeVertical,
}

/// Service for handling alignment and snapping
class AlignmentService extends GetxService {
  /// Snap threshold in pixels
  double snapThreshold = EditorConstants.snapThreshold;

  /// Whether snap to grid is enabled
  bool snapToGrid = true;

  /// Whether snap to objects is enabled
  bool snapToObjects = true;

  /// Whether smart guides are enabled
  bool smartGuides = true;

  /// Grid size in pixels
  int gridSize = 10;

  /// Calculate snapped position
  SnapResult calculateSnap({
    required Offset position,
    required Size layerSize,
    required Size canvasSize,
    required List<Rect> otherLayerBounds,
    List<double> guideColumns = const [],
    List<double> guideRows = const [],
  }) {
    double snappedX = position.dx;
    double snappedY = position.dy;
    bool didSnapX = false;
    bool didSnapY = false;
    final guides = <SnapGuide>[];

    // Calculate layer bounds at current position
    final layerRect = Rect.fromLTWH(
      position.dx - layerSize.width / 2,
      position.dy - layerSize.height / 2,
      layerSize.width,
      layerSize.height,
    );

    // Snap to canvas center
    if (smartGuides) {
      final canvasCenterX = canvasSize.width / 2;
      final canvasCenterY = canvasSize.height / 2;

      // Snap layer center to canvas center
      if ((position.dx - canvasCenterX).abs() < snapThreshold) {
        snappedX = canvasCenterX;
        didSnapX = true;
        guides.add(SnapGuide(
          start: Offset(canvasCenterX, 0),
          end: Offset(canvasCenterX, canvasSize.height),
          type: SnapGuideType.center,
        ));
      }

      if ((position.dy - canvasCenterY).abs() < snapThreshold) {
        snappedY = canvasCenterY;
        didSnapY = true;
        guides.add(SnapGuide(
          start: Offset(0, canvasCenterY),
          end: Offset(canvasSize.width, canvasCenterY),
          type: SnapGuideType.center,
        ));
      }
    }

    // Snap to canvas edges
    if (!didSnapX) {
      // Left edge
      if (layerRect.left.abs() < snapThreshold) {
        snappedX = layerSize.width / 2;
        didSnapX = true;
      }
      // Right edge
      else if ((layerRect.right - canvasSize.width).abs() < snapThreshold) {
        snappedX = canvasSize.width - layerSize.width / 2;
        didSnapX = true;
      }
    }

    if (!didSnapY) {
      // Top edge
      if (layerRect.top.abs() < snapThreshold) {
        snappedY = layerSize.height / 2;
        didSnapY = true;
      }
      // Bottom edge
      else if ((layerRect.bottom - canvasSize.height).abs() < snapThreshold) {
        snappedY = canvasSize.height - layerSize.height / 2;
        didSnapY = true;
      }
    }

    // Snap to guide lines
    for (final column in guideColumns) {
      final guideX = column * canvasSize.width;
      if ((position.dx - guideX).abs() < snapThreshold) {
        snappedX = guideX;
        didSnapX = true;
        guides.add(SnapGuide(
          start: Offset(guideX, 0),
          end: Offset(guideX, canvasSize.height),
          type: SnapGuideType.edge,
        ));
        break;
      }
    }

    for (final row in guideRows) {
      final guideY = row * canvasSize.height;
      if ((position.dy - guideY).abs() < snapThreshold) {
        snappedY = guideY;
        didSnapY = true;
        guides.add(SnapGuide(
          start: Offset(0, guideY),
          end: Offset(canvasSize.width, guideY),
          type: SnapGuideType.edge,
        ));
        break;
      }
    }

    // Snap to other objects
    if (snapToObjects && !didSnapX && !didSnapY) {
      for (final otherRect in otherLayerBounds) {
        // Snap to other layer center X
        if (!didSnapX) {
          final otherCenterX = otherRect.center.dx;
          if ((position.dx - otherCenterX).abs() < snapThreshold) {
            snappedX = otherCenterX;
            didSnapX = true;
            guides.add(SnapGuide(
              start: Offset(otherCenterX, math.min(layerRect.top, otherRect.top)),
              end: Offset(otherCenterX, math.max(layerRect.bottom, otherRect.bottom)),
              type: SnapGuideType.object,
            ));
          }
        }

        // Snap to other layer center Y
        if (!didSnapY) {
          final otherCenterY = otherRect.center.dy;
          if ((position.dy - otherCenterY).abs() < snapThreshold) {
            snappedY = otherCenterY;
            didSnapY = true;
            guides.add(SnapGuide(
              start: Offset(math.min(layerRect.left, otherRect.left), otherCenterY),
              end: Offset(math.max(layerRect.right, otherRect.right), otherCenterY),
              type: SnapGuideType.object,
            ));
          }
        }

        // Snap to other layer edges
        if (!didSnapX) {
          // Left to left
          if ((layerRect.left - otherRect.left).abs() < snapThreshold) {
            snappedX = otherRect.left + layerSize.width / 2;
            didSnapX = true;
          }
          // Right to right
          else if ((layerRect.right - otherRect.right).abs() < snapThreshold) {
            snappedX = otherRect.right - layerSize.width / 2;
            didSnapX = true;
          }
          // Left to right
          else if ((layerRect.left - otherRect.right).abs() < snapThreshold) {
            snappedX = otherRect.right + layerSize.width / 2;
            didSnapX = true;
          }
          // Right to left
          else if ((layerRect.right - otherRect.left).abs() < snapThreshold) {
            snappedX = otherRect.left - layerSize.width / 2;
            didSnapX = true;
          }
        }

        if (!didSnapY) {
          // Top to top
          if ((layerRect.top - otherRect.top).abs() < snapThreshold) {
            snappedY = otherRect.top + layerSize.height / 2;
            didSnapY = true;
          }
          // Bottom to bottom
          else if ((layerRect.bottom - otherRect.bottom).abs() < snapThreshold) {
            snappedY = otherRect.bottom - layerSize.height / 2;
            didSnapY = true;
          }
          // Top to bottom
          else if ((layerRect.top - otherRect.bottom).abs() < snapThreshold) {
            snappedY = otherRect.bottom + layerSize.height / 2;
            didSnapY = true;
          }
          // Bottom to top
          else if ((layerRect.bottom - otherRect.top).abs() < snapThreshold) {
            snappedY = otherRect.top - layerSize.height / 2;
            didSnapY = true;
          }
        }
      }
    }

    // Snap to grid
    if (snapToGrid) {
      if (!didSnapX) {
        final gridX = (position.dx / gridSize).round() * gridSize.toDouble();
        if ((position.dx - gridX).abs() < snapThreshold) {
          snappedX = gridX;
          didSnapX = true;
        }
      }

      if (!didSnapY) {
        final gridY = (position.dy / gridSize).round() * gridSize.toDouble();
        if ((position.dy - gridY).abs() < snapThreshold) {
          snappedY = gridY;
          didSnapY = true;
        }
      }
    }

    return SnapResult(
      position: Offset(snappedX, snappedY),
      guides: guides,
      snappedX: didSnapX,
      snappedY: didSnapY,
    );
  }

  /// Align layers to a specific alignment
  List<Offset> alignLayers({
    required List<Rect> layerBounds,
    required Size canvasSize,
    required AlignmentType alignment,
  }) {
    if (layerBounds.isEmpty) return [];

    final results = <Offset>[];

    // Calculate combined bounds
    Rect combinedBounds = layerBounds.first;
    for (final bounds in layerBounds.skip(1)) {
      combinedBounds = combinedBounds.expandToInclude(bounds);
    }

    switch (alignment) {
      case AlignmentType.left:
        for (final bounds in layerBounds) {
          results.add(Offset(
            combinedBounds.left + bounds.width / 2,
            bounds.center.dy,
          ));
        }
        break;

      case AlignmentType.centerHorizontal:
        final centerX = combinedBounds.center.dx;
        for (final bounds in layerBounds) {
          results.add(Offset(centerX, bounds.center.dy));
        }
        break;

      case AlignmentType.right:
        for (final bounds in layerBounds) {
          results.add(Offset(
            combinedBounds.right - bounds.width / 2,
            bounds.center.dy,
          ));
        }
        break;

      case AlignmentType.top:
        for (final bounds in layerBounds) {
          results.add(Offset(
            bounds.center.dx,
            combinedBounds.top + bounds.height / 2,
          ));
        }
        break;

      case AlignmentType.centerVertical:
        final centerY = combinedBounds.center.dy;
        for (final bounds in layerBounds) {
          results.add(Offset(bounds.center.dx, centerY));
        }
        break;

      case AlignmentType.bottom:
        for (final bounds in layerBounds) {
          results.add(Offset(
            bounds.center.dx,
            combinedBounds.bottom - bounds.height / 2,
          ));
        }
        break;

      case AlignmentType.distributeHorizontal:
        if (layerBounds.length < 3) {
          return layerBounds.map((b) => b.center).toList();
        }

        // Sort by x position
        final sorted = List<Rect>.from(layerBounds)
          ..sort((a, b) => a.center.dx.compareTo(b.center.dx));

        final totalWidth = combinedBounds.width;
        final layersWidth = sorted.fold<double>(0, (sum, b) => sum + b.width);
        final spacing = (totalWidth - layersWidth) / (sorted.length - 1);

        double currentX = combinedBounds.left;
        for (final bounds in sorted) {
          results.add(Offset(currentX + bounds.width / 2, bounds.center.dy));
          currentX += bounds.width + spacing;
        }
        break;

      case AlignmentType.distributeVertical:
        if (layerBounds.length < 3) {
          return layerBounds.map((b) => b.center).toList();
        }

        // Sort by y position
        final sorted = List<Rect>.from(layerBounds)
          ..sort((a, b) => a.center.dy.compareTo(b.center.dy));

        final totalHeight = combinedBounds.height;
        final layersHeight = sorted.fold<double>(0, (sum, b) => sum + b.height);
        final spacing = (totalHeight - layersHeight) / (sorted.length - 1);

        double currentY = combinedBounds.top;
        for (final bounds in sorted) {
          results.add(Offset(bounds.center.dx, currentY + bounds.height / 2));
          currentY += bounds.height + spacing;
        }
        break;
    }

    return results;
  }

  /// Snap rotation angle to common angles
  double snapRotation(double angle, {double snapAngle = 15.0}) {
    final snapped = (angle / snapAngle).round() * snapAngle;
    if ((angle - snapped).abs() < 5) {
      return snapped;
    }
    return angle;
  }
}