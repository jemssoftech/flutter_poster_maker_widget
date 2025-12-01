import 'dart:ui' show Size, Rect, Offset;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../presentation/controllers/layer_controller.dart';
import '../../../domain/services/transform_service.dart';
import '../../../data/models/selection/selection_state.dart';
import 'resize_handle.dart';
import 'rotate_handle.dart';

/// Transform box with handles for a single layer
class TransformBox extends StatelessWidget {
  final String layerId;
  final Size canvasSize;

  const TransformBox({
    super.key,
    required this.layerId,
    required this.canvasSize,
  });

  @override
  Widget build(BuildContext context) {
    final layerController = Get.find<LayerController>();
    final transformService = Get.find<TransformService>();

    final layer = layerController.getLayerById(layerId);
    if (layer == null || layer.locked) {
      return const SizedBox.shrink();
    }

    // Calculate bounds
    final bounds = transformService.calculateBounds(
      transform: layer.transform,
      canvasSize: canvasSize,
    );

    return Positioned(
      left: bounds.left,
      top: bounds.top,
      width: bounds.width,
      height: bounds.height,
      child: _TransformBoxContent(
        layerId: layerId,
        bounds: bounds,
      ),
    );
  }
}

class _TransformBoxContent extends StatelessWidget {
  final String layerId;
  final Rect bounds;

  const _TransformBoxContent({
    required this.layerId,
    required this.bounds,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Border
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFF0080FF),
              width: 2,
            ),
          ),
        ),

        // Resize handles
        ResizeHandle(
          position: HandlePosition.topLeft,
          layerId: layerId,
        ),
        ResizeHandle(
          position: HandlePosition.topCenter,
          layerId: layerId,
        ),
        ResizeHandle(
          position: HandlePosition.topRight,
          layerId: layerId,
        ),
        ResizeHandle(
          position: HandlePosition.centerLeft,
          layerId: layerId,
        ),
        ResizeHandle(
          position: HandlePosition.centerRight,
          layerId: layerId,
        ),
        ResizeHandle(
          position: HandlePosition.bottomLeft,
          layerId: layerId,
        ),
        ResizeHandle(
          position: HandlePosition.bottomCenter,
          layerId: layerId,
        ),
        ResizeHandle(
          position: HandlePosition.bottomRight,
          layerId: layerId,
        ),

        // Rotate handle
        RotateHandle(layerId: layerId),
      ],
    );
  }
}