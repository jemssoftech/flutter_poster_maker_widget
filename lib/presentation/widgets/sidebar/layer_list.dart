import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../presentation/controllers/layer_controller.dart';
import '../../../presentation/controllers/selection_controller.dart';
import 'layer_list_item.dart';

/// Reorderable list of layers
class LayerList extends StatelessWidget {
  const LayerList({super.key});

  @override
  Widget build(BuildContext context) {
    final layerController = Get.find<LayerController>();

    return Obx(() {
      final layers = layerController.panelOrder; // Top to bottom for UI

      if (layers.isEmpty) {
        return _EmptyLayersList();
      }

      return ReorderableListView.builder(
        itemCount: layers.length,
        onReorder: (oldIndex, newIndex) {
          // Convert panel index to layer index (reversed)
          final layerOldIndex = layers.length - 1 - oldIndex;
          var layerNewIndex = layers.length - 1 - newIndex;

          // Adjust for ReorderableListView behavior
          if (oldIndex < newIndex) {
            layerNewIndex++;
          }

          layerController.reorderLayer(layerOldIndex, layerNewIndex);
        },
        buildDefaultDragHandles: false,
        proxyDecorator: (child, index, animation) {
          return AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              final scale = Tween<double>(begin: 1.0, end: 1.02)
                  .animate(animation)
                  .value;
              return Transform.scale(
                scale: scale,
                child: Material(
                  elevation: 4,
                  color: Colors.transparent,
                  child: child,
                ),
              );
            },
            child: child,
          );
        },
        itemBuilder: (context, index) {
          final layer = layers[index];
          return LayerListItem(
            key: ValueKey(layer.id),
            layer: layer,
            index: index,
          );
        },
      );
    });
  }
}

class _EmptyLayersList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.layers_outlined,
              size: 48,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No layers yet',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add text, images, or shapes to get started',
              style: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}