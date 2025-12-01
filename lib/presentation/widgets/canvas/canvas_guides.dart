import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../presentation/controllers/transform_controller.dart';
import '../../../domain/services/alignment_service.dart';

/// Snap guides overlay
class CanvasGuides extends StatelessWidget {
  const CanvasGuides({super.key});

  @override
  Widget build(BuildContext context) {
    final transformController = Get.find<TransformController>();

    return Obx(() {
      final guides = transformController.snapGuides;

      if (guides.isEmpty) {
        return const SizedBox.shrink();
      }

      return CustomPaint(
        size: Size.infinite,
        painter: _GuidesPainter(guides: guides),
      );
    });
  }
}

class _GuidesPainter extends CustomPainter {
  final List<SnapGuide> guides;

  _GuidesPainter({required this.guides});

  @override
  void paint(Canvas canvas, Size size) {
    for (final guide in guides) {
      final paint = Paint()
        ..color = _getColorForGuideType(guide.type)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;

      canvas.drawLine(guide.start, guide.end, paint);
    }
  }

  Color _getColorForGuideType(SnapGuideType type) {
    switch (type) {
      case SnapGuideType.center:
        return const Color(0xFFFF00FF); // Magenta for center
      case SnapGuideType.edge:
        return const Color(0xFF00FFFF); // Cyan for edges
      case SnapGuideType.object:
        return const Color(0xFFFF0099); // Pink for objects
    }
  }

  @override
  bool shouldRepaint(_GuidesPainter oldDelegate) {
    return oldDelegate.guides.length != guides.length;
  }
}