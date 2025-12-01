import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../../data/models/layers/shape_layer.dart';
import '../../../data/models/shapes/shape_type.dart';

/// Renders a shape layer
class ShapeLayerWidget extends StatelessWidget {
  final ShapeLayer layer;

  const ShapeLayerWidget({
    super.key,
    required this.layer,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate size
    final width = layer.transform.width != null
        ? layer.transform.width! * 1080
        : 200.0;
    final height = layer.transform.height != null
        ? layer.transform.height! * 1920
        : 200.0;

    return CustomPaint(
      size: Size(width, height),
      painter: _ShapePainter(
        shapeType: layer.shapeType,
        fill: layer.fill,
        stroke: layer.stroke,
        cornerRadius: layer.cornerRadius,
        sides: layer.sides,
        innerRadiusRatio: layer.innerRadiusRatio,
      ),
    );
  }
}

class _ShapePainter extends CustomPainter {
  final ShapeType shapeType;
  final dynamic fill;
  final dynamic stroke;
  final dynamic cornerRadius;
  final int sides;
  final double innerRadiusRatio;

  _ShapePainter({
    required this.shapeType,
    required this.fill,
    required this.stroke,
    required this.cornerRadius,
    required this.sides,
    required this.innerRadiusRatio,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Fill paint
    final fillPaint = fill.toPaint(rect);

    // Stroke paint
    final strokePaint = stroke.toPaint();

    switch (shapeType) {
      case ShapeType.rectangle:
        _drawRectangle(canvas, rect, fillPaint, strokePaint);
        break;
      case ShapeType.circle:
        _drawCircle(canvas, rect, fillPaint, strokePaint);
        break;
      case ShapeType.ellipse:
        _drawEllipse(canvas, rect, fillPaint, strokePaint);
        break;
      case ShapeType.triangle:
        _drawPolygon(canvas, rect, 3, fillPaint, strokePaint);
        break;
      case ShapeType.polygon:
        _drawPolygon(canvas, rect, sides, fillPaint, strokePaint);
        break;
      case ShapeType.star:
        _drawStar(canvas, rect, sides, fillPaint, strokePaint);
        break;
      case ShapeType.line:
        _drawLine(canvas, rect, strokePaint);
        break;
      case ShapeType.arrow:
        _drawArrow(canvas, rect, fillPaint, strokePaint);
        break;
    }
  }

  void _drawRectangle(Canvas canvas, Rect rect, Paint? fill, Paint? stroke) {
    final rrect = RRect.fromRectAndCorners(
      rect,
      topLeft: Radius.circular(cornerRadius.topLeft),
      topRight: Radius.circular(cornerRadius.topRight),
      bottomLeft: Radius.circular(cornerRadius.bottomLeft),
      bottomRight: Radius.circular(cornerRadius.bottomRight),
    );

    if (fill != null) canvas.drawRRect(rrect, fill);
    if (stroke != null) canvas.drawRRect(rrect, stroke);
  }

  void _drawCircle(Canvas canvas, Rect rect, Paint? fill, Paint? stroke) {
    final center = rect.center;
    final radius = math.min(rect.width, rect.height) / 2;

    if (fill != null) canvas.drawCircle(center, radius, fill);
    if (stroke != null) canvas.drawCircle(center, radius, stroke);
  }

  void _drawEllipse(Canvas canvas, Rect rect, Paint? fill, Paint? stroke) {
    if (fill != null) canvas.drawOval(rect, fill);
    if (stroke != null) canvas.drawOval(rect, stroke);
  }

  void _drawPolygon(Canvas canvas, Rect rect, int sides, Paint? fill, Paint? stroke) {
    if (sides < 3) return;

    final center = rect.center;
    final radius = math.min(rect.width, rect.height) / 2;
    final path = Path();

    for (int i = 0; i < sides; i++) {
      final angle = (i * 2 * math.pi / sides) - math.pi / 2;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    if (fill != null) canvas.drawPath(path, fill);
    if (stroke != null) canvas.drawPath(path, stroke);
  }

  void _drawStar(Canvas canvas, Rect rect, int points, Paint? fill, Paint? stroke) {
    if (points < 3) return;

    final center = rect.center;
    final outerRadius = math.min(rect.width, rect.height) / 2;
    final innerRadius = outerRadius * innerRadiusRatio;
    final path = Path();

    for (int i = 0; i < points * 2; i++) {
      final angle = (i * math.pi / points) - math.pi / 2;
      final radius = i.isEven ? outerRadius : innerRadius;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    if (fill != null) canvas.drawPath(path, fill);
    if (stroke != null) canvas.drawPath(path, stroke);
  }

  void _drawLine(Canvas canvas, Rect rect, Paint? stroke) {
    if (stroke == null) return;

    canvas.drawLine(
      Offset(rect.left, rect.center.dy),
      Offset(rect.right, rect.center.dy),
      stroke,
    );
  }

  void _drawArrow(Canvas canvas, Rect rect, Paint? fill, Paint? stroke) {
    final path = Path();
    final arrowWidth = rect.width * 0.3;
    final arrowHeight = rect.height * 0.5;

    path.moveTo(rect.left, rect.center.dy);
    path.lineTo(rect.right - arrowWidth, rect.top);
    path.lineTo(rect.right - arrowWidth, rect.top + (rect.height - arrowHeight) / 2);
    path.lineTo(rect.right, rect.center.dy);
    path.lineTo(rect.right - arrowWidth, rect.bottom - (rect.height - arrowHeight) / 2);
    path.lineTo(rect.right - arrowWidth, rect.bottom);
    path.close();

    if (fill != null) canvas.drawPath(path, fill);
    if (stroke != null) canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(_ShapePainter oldDelegate) => true;
}