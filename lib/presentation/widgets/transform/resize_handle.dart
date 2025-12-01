import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../presentation/controllers/transform_controller.dart';
import '../../../data/models/selection/selection_state.dart';

/// Resize handle for transform box
class ResizeHandle extends StatelessWidget {
  final HandlePosition position;
  final String layerId;

  static const double handleSize = 12.0;

  const ResizeHandle({
    super.key,
    required this.position,
    required this.layerId,
  });

  @override
  Widget build(BuildContext context) {
    final transformController = Get.find<TransformController>();

    // Position handle based on HandlePosition
    Widget handle = GestureDetector(
      onPanStart: (details) {
        transformController.startResize(layerId, position, details.globalPosition);
      },
      onPanUpdate: (details) {
        transformController.updateResize(
          details.globalPosition,
          maintainAspectRatio: position.isCorner,
        );
      },
      onPanEnd: (_) {
        transformController.endResize();
      },
      child: MouseRegion(
        cursor: position.cursor,
        child: Container(
          width: handleSize,
          height: handleSize,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFF0080FF), width: 2),
            borderRadius: BorderRadius.circular(handleSize / 2),
          ),
        ),
      ),
    );

    // Position the handle
    final offset = position.relativePosition;

    return Positioned(
      left: offset.dx == 0
          ? -handleSize / 2
          : offset.dx == 1
          ? null
          : null,
      right: offset.dx == 1 ? -handleSize / 2 : null,
      top: offset.dy == 0
          ? -handleSize / 2
          : offset.dy == 1
          ? null
          : null,
      bottom: offset.dy == 1 ? -handleSize / 2 : null,
      child: offset.dx == 0.5 || offset.dy == 0.5
          ? Align(
        alignment: Alignment(
          offset.dx == 0.5 ? 0 : (offset.dx == 0 ? -1 : 1),
          offset.dy == 0.5 ? 0 : (offset.dy == 0 ? -1 : 1),
        ),
        child: handle,
      )
          : handle,
    );
  }
}