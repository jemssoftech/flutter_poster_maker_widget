import 'dart:ui' show Size, Offset;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../presentation/controllers/canvas_controller.dart';
import '../../../presentation/controllers/poster_controller.dart';

/// Rulers for the canvas (top and left)
class CanvasRulers extends StatelessWidget {
  const CanvasRulers({super.key});

  static const double rulerSize = 24.0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top ruler
        Positioned(
          top: 0,
          left: rulerSize,
          right: 0,
          height: rulerSize,
          child: const _HorizontalRuler(),
        ),

        // Left ruler
        Positioned(
          left: 0,
          top: rulerSize,
          width: rulerSize,
          bottom: 0,
          child: const _VerticalRuler(),
        ),

        // Corner box
        Positioned(
          left: 0,
          top: 0,
          width: rulerSize,
          height: rulerSize,
          child: Container(
            color: const Color(0xFF2a2a2a),
            child: const Icon(
              Icons.grid_4x4,
              size: 16,
              color: Colors.white54,
            ),
          ),
        ),
      ],
    );
  }
}

class _HorizontalRuler extends StatelessWidget {
  const _HorizontalRuler();

  @override
  Widget build(BuildContext context) {
    final canvasController = Get.find<CanvasController>();
    final posterController = Get.find<PosterController>();

    return Obx(() {
      final canvasSize = posterController.canvasSize;
      final zoom = canvasController.zoom.value;
      final panOffset = canvasController.panOffset.value;

      return CustomPaint(
        painter: _RulerPainter(
          canvasDimension: canvasSize.width,
          zoom: zoom,
          offset: panOffset.dx,
          isHorizontal: true,
        ),
      );
    });
  }
}

class _VerticalRuler extends StatelessWidget {
  const _VerticalRuler();

  @override
  Widget build(BuildContext context) {
    final canvasController = Get.find<CanvasController>();
    final posterController = Get.find<PosterController>();

    return Obx(() {
      final canvasSize = posterController.canvasSize;
      final zoom = canvasController.zoom.value;
      final panOffset = canvasController.panOffset.value;

      return CustomPaint(
        painter: _RulerPainter(
          canvasDimension: canvasSize.height,
          zoom: zoom,
          offset: panOffset.dy,
          isHorizontal: false,
        ),
      );
    });
  }
}

class _RulerPainter extends CustomPainter {
  final double canvasDimension;
  final double zoom;
  final double offset;
  final bool isHorizontal;

  _RulerPainter({
    required this.canvasDimension,
    required this.zoom,
    required this.offset,
    required this.isHorizontal,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    final bgPaint = Paint()..color = const Color(0xFF2a2a2a);
    canvas.drawRect(Offset.zero & size, bgPaint);

    // Determine tick spacing based on zoom
    const baseTickSpacing = 50.0; // pixels

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final tickPaint = Paint()
      ..color = Colors.white54
      ..strokeWidth = 1;

    // Calculate visible range
    final start = (-offset / zoom).floor().toDouble();
    final end = ((isHorizontal ? size.width : size.height) - offset) / zoom;

    // Draw ticks
    for (double pos = (start / baseTickSpacing).floor() * baseTickSpacing;
    pos <= end;
    pos += baseTickSpacing) {
      final screenPos = pos * zoom + offset;

      if (screenPos < 0 || screenPos > (isHorizontal ? size.width : size.height)) {
        continue;
      }

      // Major tick every 100px
      final isMajor = (pos % 100) == 0;
      final tickLength = isMajor ? 12.0 : 6.0;

      if (isHorizontal) {
        canvas.drawLine(
          Offset(screenPos, size.height - tickLength),
          Offset(screenPos, size.height),
          tickPaint,
        );

        if (isMajor) {
          textPainter.text = TextSpan(
            text: pos.toInt().toString(),
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          );
          textPainter.layout();
          textPainter.paint(
            canvas,
            Offset(screenPos - textPainter.width / 2, 2),
          );
        }
      } else {
        canvas.drawLine(
          Offset(size.width - tickLength, screenPos),
          Offset(size.width, screenPos),
          tickPaint,
        );

        if (isMajor) {
          textPainter.text = TextSpan(
            text: pos.toInt().toString(),
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          );
          textPainter.layout();
          canvas.save();
          canvas.translate(2, screenPos + textPainter.width / 2);
          canvas.rotate(-1.5708); // -90 degrees
          textPainter.paint(canvas, Offset.zero);
          canvas.restore();
        }
      }
    }
  }

  @override
  bool shouldRepaint(_RulerPainter oldDelegate) {
    return oldDelegate.zoom != zoom ||
        oldDelegate.offset != offset ||
        oldDelegate.canvasDimension != canvasDimension;
  }
}