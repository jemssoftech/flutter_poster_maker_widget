import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:flutter_poster_maker/models/template_element.dart';

class SignatureElement extends TemplateElement {
  List<Offset> points;
  Color strokeColor;
  double strokeWidth;
  Uint8List? signatureImage;
  String? placeholderKey;

  SignatureElement({
    required super.id,
    required super.name,
    required super.position,
    required super.size,
    super.rotation,
    super.opacity,
    super.isLocked,
    super.isVisible,
    super.zIndex,
    this.points = const [],
    this.strokeColor = Colors.black,
    this.strokeWidth = 2.0,
    this.signatureImage,
    this.placeholderKey,
  }) : super(type: ElementType.signature);

  factory SignatureElement.fromJson(Map<String, dynamic> json) {
    return SignatureElement(
      id: json['id'],
      name: json['name'] ?? 'Signature',
      position: Offset(
        (json['position']?['x'] ?? 0).toDouble(),
        (json['position']?['y'] ?? 0).toDouble(),
      ),
      size: Size(
        (json['size']['width'] ?? 150).toDouble(),
        (json['size']['height'] ?? 50).toDouble(),
      ),
      rotation: (json['rotation'] ?? 0).toDouble(),
      opacity: (json['opacity'] ?? 1).toDouble(),
      isLocked: json['isLocked'] ?? false,
      isVisible: json['isVisible'] ?? true,
      zIndex: json['zIndex'] ?? 0,
      strokeColor: Color(json['strokeColor'] ?? 0xFF000000),
      strokeWidth: (json['strokeWidth'] ?? 2).toDouble(),
      signatureImage: json['signatureBase64'] != null ? base64Decode(json['signatureBase64']) : null,
      placeholderKey: json['placeholderKey'],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.name,
    'position': {'x': position.dx, 'y': position.dy},
    'size': {'width': size.width, 'height': size.height},
    'rotation': rotation,
    'opacity': opacity,
    'isLocked': isLocked,
    'isVisible': isVisible,
    'zIndex': zIndex,
    'strokeColor': strokeColor.value,
    'strokeWidth': strokeWidth,
    'signatureBase64': signatureImage != null ? base64Encode(signatureImage!) : null,
    'placeholderKey': placeholderKey,
  };

  @override
  SignatureElement clone() => SignatureElement(
    id: '${id}_copy',
    name: '$name Copy',
    position: position + const Offset(20, 20),
    size: size,
    rotation: rotation,
    opacity: opacity,
    isLocked: false,
    isVisible: isVisible,
    zIndex: zIndex,
    points: [...points],
    strokeColor: strokeColor,
    strokeWidth: strokeWidth,
    signatureImage: signatureImage,
    placeholderKey: placeholderKey,
  );
}

/// Signature Pad Widget
class SignaturePadWidget extends StatefulWidget {
  final Function(Uint8List) onSignatureComplete;
  final Color strokeColor;
  final double strokeWidth;

  const SignaturePadWidget({
    super.key,
    required this.onSignatureComplete,
    this.strokeColor = Colors.black,
    this.strokeWidth = 2.0,
  });

  @override
  State<SignaturePadWidget> createState() => _SignaturePadWidgetState();
}

class _SignaturePadWidgetState extends State<SignaturePadWidget> {
  final List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onPanStart: (details) {
              setState(() {
                _currentStroke = [details.localPosition];
              });
            },
            onPanUpdate: (details) {
              setState(() {
                _currentStroke.add(details.localPosition);
              });
            },
            onPanEnd: (details) {
              setState(() {
                _strokes.add(_currentStroke);
                _currentStroke = [];
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomPaint(
                painter: _SignaturePainter(
                  strokes: _strokes,
                  currentStroke: _currentStroke,
                  strokeColor: widget.strokeColor,
                  strokeWidth: widget.strokeWidth,
                ),
                size: Size.infinite,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            OutlinedButton.icon(
              icon: const Icon(Icons.clear),
              label: const Text('Clear'),
              onPressed: () {
                setState(() {
                  _strokes.clear();
                  _currentStroke.clear();
                });
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text('Done'),
              onPressed: _saveSignature,
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _saveSignature() async {
    if (_strokes.isEmpty) return;

    // Calculate actual bounds of all strokes with padding
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (final stroke in _strokes) {
      for (final point in stroke) {
        if (point.dx < minX) minX = point.dx;
        if (point.dy < minY) minY = point.dy;
        if (point.dx > maxX) maxX = point.dx;
        if (point.dy > maxY) maxY = point.dy;
      }
    }

    // Add padding around the signature (10px on each side)
    const padding = 10.0;
    minX = (minX - padding).clamp(0, double.infinity);
    minY = (minY - padding).clamp(0, double.infinity);
    maxX = maxX + padding;
    maxY = maxY + padding;

    final width = (maxX - minX).ceil();
    final height = (maxY - minY).ceil();

    // Ensure minimum size
    final finalWidth = width.clamp(50, 1000);
    final finalHeight = height.clamp(30, 500);

    // Convert to image with proper bounds
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Translate canvas to account for cropped bounds
    canvas.translate(-minX, -minY);

    final painter = _SignaturePainter(
      strokes: _strokes,
      currentStroke: [],
      strokeColor: widget.strokeColor,
      strokeWidth: widget.strokeWidth,
    );

    painter.paint(canvas, Size(maxX, maxY));

    final picture = recorder.endRecording();
    final image = await picture.toImage(finalWidth, finalHeight);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData != null) {
      widget.onSignatureComplete(byteData.buffer.asUint8List());
    }
  }
}

class _SignaturePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;
  final Color strokeColor;
  final double strokeWidth;

  _SignaturePainter({
    required this.strokes,
    required this.currentStroke,
    required this.strokeColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      _drawStroke(canvas, stroke, paint);
    }

    if (currentStroke.isNotEmpty) {
      _drawStroke(canvas, currentStroke, paint);
    }
  }

  void _drawStroke(Canvas canvas, List<Offset> points, Paint paint) {
    if (points.length < 2) return;

    final path = Path()..moveTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


/// Horizontal Ruler
class HorizontalRuler extends StatelessWidget {
  final double zoom;
  final double offset;

  const HorizontalRuler({
    super.key,
    required this.zoom,
    required this.offset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      color: Colors.grey.shade100,
      child: CustomPaint(
        painter: _HorizontalRulerPainter(zoom: zoom, offset: offset),
        size: Size.infinite,
      ),
    );
  }
}

class _HorizontalRulerPainter extends CustomPainter {
  final double zoom;
  final double offset;

  _HorizontalRulerPainter({required this.zoom, required this.offset});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade600
      ..strokeWidth = 1;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    final step = 50.0 * zoom;
    final startX = (offset % step) - step;

    for (double x = startX; x < size.width; x += step) {
      final value = ((x - offset) / zoom).round();

      // Major tick
      canvas.drawLine(Offset(x, size.height - 10), Offset(x, size.height), paint);

      // Label
      textPainter.text = TextSpan(
        text: '$value',
        style: TextStyle(fontSize: 9, color: Colors.grey.shade700),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, 2));

      // Minor ticks
      for (int i = 1; i < 5; i++) {
        final minorX = x + (step / 5) * i;
        if (minorX < size.width) {
          canvas.drawLine(
            Offset(minorX, size.height - 5),
            Offset(minorX, size.height),
            paint..strokeWidth = 0.5,
          );
        }
      }
    }

    // Bottom border
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      paint..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Vertical Ruler
class VerticalRuler extends StatelessWidget {
  final double zoom;
  final double offset;

  const VerticalRuler({
    super.key,
    required this.zoom,
    required this.offset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      color: Colors.grey.shade100,
      child: CustomPaint(
        painter: _VerticalRulerPainter(zoom: zoom, offset: offset),
        size: Size.infinite,
      ),
    );
  }
}

class _VerticalRulerPainter extends CustomPainter {
  final double zoom;
  final double offset;

  _VerticalRulerPainter({required this.zoom, required this.offset});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade600
      ..strokeWidth = 1;

    final step = 50.0 * zoom;
    final startY = (offset % step) - step;

    for (double y = startY; y < size.height; y += step) {
      final value = ((y - offset) / zoom).round();

      // Major tick
      canvas.drawLine(Offset(size.width - 10, y), Offset(size.width, y), paint);

      // Label (rotated)
      canvas.save();
      canvas.translate(6, y);
      canvas.rotate(-1.5708); // -90 degrees

      final textPainter = TextPainter(
        text: TextSpan(
          text: '$value',
          style: TextStyle(fontSize: 9, color: Colors.grey.shade700),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(-textPainter.width / 2, 0));
      canvas.restore();

      // Minor ticks
      for (int i = 1; i < 5; i++) {
        final minorY = y + (step / 5) * i;
        if (minorY < size.height) {
          canvas.drawLine(
            Offset(size.width - 5, minorY),
            Offset(size.width, minorY),
            paint..strokeWidth = 0.5,
          );
        }
      }
    }

    // Right border
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width, size.height),
      paint..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


/// Grid Overlay Widget
class GridOverlay extends StatelessWidget {
  final double gridSize;
  final Color color;

  const GridOverlay({
    super.key,
    required this.gridSize,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridPainter(gridSize: gridSize, color: color),
      size: Size.infinite,
    );
  }
}

class _GridPainter extends CustomPainter {
  final double gridSize;
  final Color color;

  _GridPainter({required this.gridSize, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5;

    // Vertical lines
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Horizontal lines
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}