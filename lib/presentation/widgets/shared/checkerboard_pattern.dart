import 'package:flutter/material.dart';

/// Checkerboard pattern for transparency visualization
class CheckerboardPattern extends StatelessWidget {
  final double squareSize;
  final Color lightColor;
  final Color darkColor;

  const CheckerboardPattern({
    super.key,
    this.squareSize = 16.0,
    this.lightColor = Colors.white,
    this.darkColor = const Color(0xFFE0E0E0),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CheckerboardPainter(
        squareSize: squareSize,
        lightColor: lightColor,
        darkColor: darkColor,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _CheckerboardPainter extends CustomPainter {
  final double squareSize;
  final Color lightColor;
  final Color darkColor;

  _CheckerboardPainter({
    required this.squareSize,
    required this.lightColor,
    required this.darkColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final lightPaint = Paint()..color = lightColor;
    final darkPaint = Paint()..color = darkColor;

    final rows = (size.height / squareSize).ceil();
    final cols = (size.width / squareSize).ceil();

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        final paint = (row + col) % 2 == 0 ? lightPaint : darkPaint;
        final rect = Rect.fromLTWH(
          col * squareSize,
          row * squareSize,
          squareSize,
          squareSize,
        );
        canvas.drawRect(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_CheckerboardPainter oldDelegate) {
    return oldDelegate.squareSize != squareSize ||
        oldDelegate.lightColor != lightColor ||
        oldDelegate.darkColor != darkColor;
  }
}