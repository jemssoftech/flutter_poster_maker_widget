import 'dart:ui' show Size;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../presentation/controllers/poster_controller.dart';
import '../../../presentation/controllers/layer_controller.dart';
import '../../../presentation/controllers/selection_controller.dart';
import 'canvas_background.dart';
import '../layers/layer_renderer.dart';
import '../transform/transform_box.dart';
import '../transform/multi_transform_box.dart';
import 'selection_rectangle.dart';
import '../shared/checkerboard_pattern.dart';

/// Main poster canvas that renders the document
class PosterCanvas extends StatelessWidget {
  const PosterCanvas({super.key});

  @override
  Widget build(BuildContext context) {
    final posterController = Get.find<PosterController>();
    final layerController = Get.find<LayerController>();
    final selectionController = Get.find<SelectionController>();

    return Obx(() {
      final document = posterController.document;
      if (document == null) {
        return _EmptyCanvas();
      }

      final canvasSize = posterController.canvasSize;

      return SizedBox(
        width: canvasSize.width,
        height: canvasSize.height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Checkerboard pattern for transparency
            const CheckerboardPattern(),

            // Canvas background
            CanvasBackground(background: posterController.background),

            // Layers (rendered bottom to top)
            ...layerController.renderOrder.map((layer) {
              return LayerRenderer(
                key: ValueKey(layer.id),
                layer: layer,
                canvasSize: canvasSize,
              );
            }),

            // Transform box for selected layers
            Obx(() {
              if (!selectionController.hasSelection) {
                return const SizedBox.shrink();
              }

              if (selectionController.hasSingleSelection) {
                final layerId = selectionController.selectedIds.first;
                return TransformBox(
                  key: ValueKey('transform_$layerId'),
                  layerId: layerId,
                  canvasSize: canvasSize,
                );
              }

              // Multi-selection transform box
              return MultiTransformBox(
                layerIds: selectionController.selectedIds.toList(),
                canvasSize: canvasSize,
              );
            }),

            // Selection rectangle (during drag selection)
            Obx(() {
              if (!selectionController.isDrawingSelectionRect) {
                return const SizedBox.shrink();
              }

              return SelectionRectangle(
                rect: selectionController.selectionRect,
              );
            }),
          ],
        ),
      );
    });
  }
}

/// Empty canvas placeholder
class _EmptyCanvas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 600,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_photo_alternate_outlined,
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No document loaded',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}