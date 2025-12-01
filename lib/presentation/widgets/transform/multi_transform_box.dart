import 'dart:ui' show Size, Rect;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../presentation/controllers/layer_controller.dart';
import '../../../domain/services/transform_service.dart';

/// Transform box for multiple selected layers
class MultiTransformBox extends StatelessWidget {
  final List<String> layerIds;
  final Size canvasSize;

  const MultiTransformBox({
    super.key,
    required this.layerIds,
    required this.canvasSize,
  });

  @override
  Widget build(BuildContext context) {
    final layerController = Get.find<LayerController>();
    final transformService = Get.find<TransformService>();

    // Calculate combined bounds
    Rect? combinedBounds;

    for (final layerId in layerIds) {
      final layer = layerController.getLayerById(layerId);
      if (layer == null) continue;

      final bounds = transformService.calculateBounds(
        transform: layer.transform,
        canvasSize: Size(canvasSize.width, canvasSize.height),
      );

      combinedBounds = combinedBounds?.expandToInclude(bounds) ?? bounds;
    }

    if (combinedBounds == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: combinedBounds.left,
      top: combinedBounds.top,
      width: combinedBounds.width,
      height: combinedBounds.height,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFF0080FF),
            width: 2,
          ),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF0080FF),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${layerIds.length} layers',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}