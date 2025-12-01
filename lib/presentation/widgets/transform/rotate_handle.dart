import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../presentation/controllers/transform_controller.dart';

/// Rotate handle for transform box
class RotateHandle extends StatelessWidget {
  final String layerId;

  static const double handleSize = 12.0;
  static const double handleDistance = 30.0;

  const RotateHandle({
    super.key,
    required this.layerId,
  });

  @override
  Widget build(BuildContext context) {
    final transformController = Get.find<TransformController>();

    return Positioned(
      left: 0,
      right: 0,
      top: -handleDistance,
      child: Center(
        child: GestureDetector(
          onPanStart: (details) {
            transformController.startRotate(layerId, details.globalPosition);
          },
          onPanUpdate: (details) {
            transformController.updateRotate(
              details.globalPosition,
              snap: false, // Hold Shift to snap in real implementation
            );
          },
          onPanEnd: (_) {
            transformController.endRotate();
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: handleSize,
                  height: handleSize,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFF0080FF), width: 2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.rotate_right,
                    size: 8,
                    color: Color(0xFF0080FF),
                  ),
                ),
                Container(
                  width: 2,
                  height: handleDistance - handleSize,
                  color: const Color(0xFF0080FF),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}