import 'dart:ui' show Size, Offset;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../presentation/controllers/canvas_controller.dart';
import '../../../presentation/controllers/poster_controller.dart';

/// Grid overlay for the canvas
class CanvasGrid extends StatelessWidget {
  const CanvasGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final canvasController = Get.find<CanvasController>();
    final posterController = Get.find<PosterController>();

    return Obx(() {
      final canvasSize = posterController.canvasSize;
      final gridSize = posterController.settings.gridSize.toDouble();
      final zoom = canvasController.zoom.value;
      final panOffset = canvasController.panOffset.value;

      return CustomPaint(
        size: Size.infinite,
        painter: _GridPainter(
          canvasWidth: canvasSize.width,
          canvasHeight: canvasSize.height,
          gridSize: gridSize,
          zoom: zoom,
          panOffset: panOffset,
        ),
      );
    });
  }
}

class _GridPainter extends CustomPainter {
  final double canvasWidth;
  final double canvasHeight;
  final double gridSize;
  final double zoom;
  final Offset panOffset;

  _GridPainter({
    required this.canvasWidth,
    required this.canvasHeight,
    required this.gridSize,
    required this.zoom,
    required this.panOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final scaledGridSize = gridSize * zoom;

    // Only draw grid if it's not too small or too large
    if (scaledGridSize < 5 || scaledGridSize > 200) return;

    // Calculate visible area
    final startX = (-panOffset.dx / zoom).floorToDouble();
    final startY = (-panOffset.dy / zoom).floorToDouble();
    final endX = ((size.width - panOffset.dx) / zoom).ceilToDouble();
    final endY = ((size.height - panOffset.dy) / zoom).ceilToDouble();

    // Clamp to canvas bounds
    final clampedStartX = startX.clamp(0.0, canvasWidth);
    final clampedStartY = startY.clamp(0.0, canvasHeight);
    final clampedEndX = endX.clamp(0.0, canvasWidth);
    final clampedEndY = endY.clamp(0.0, canvasHeight);

    // Vertical lines
    for (double x = (clampedStartX / gridSize).floor() * gridSize;
    x <= clampedEndX;
    x += gridSize) {
      final screenX = x * zoom + panOffset.dx;
      canvas.drawLine(
        Offset(screenX, 0),
        Offset(screenX, size.height),
        paint,
      );
    }

    // Horizontal lines
    for (double y = (clampedStartY / gridSize).floor() * gridSize;
    y <= clampedEndY;
    y += gridSize) {
      final screenY = y * zoom + panOffset.dy;
      canvas.drawLine(
        Offset(0, screenY),
        Offset(size.width, screenY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) {
    return oldDelegate.zoom != zoom ||
        oldDelegate.panOffset != panOffset ||
        oldDelegate.gridSize != gridSize ||
        oldDelegate.canvasWidth != canvasWidth ||
        oldDelegate.canvasHeight != canvasHeight;
  }
}