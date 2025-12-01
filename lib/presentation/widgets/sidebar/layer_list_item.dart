import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/layers/layer_base.dart';
import '../../../presentation/controllers/layer_controller.dart';
import '../../../presentation/controllers/selection_controller.dart';
import '../../../presentation/controllers/ui_controller.dart';
import 'layer_thumbnail.dart';

/// Single layer item in the layers list
class LayerListItem extends StatelessWidget {
  final LayerBase layer;
  final int index;

  const LayerListItem({
    super.key,
    required this.layer,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final layerController = Get.find<LayerController>();
    final selectionController = Get.find<SelectionController>();
    final uiController = Get.find<UIController>();

    return Obx(() {
      final isSelected = selectionController.isSelected(layer.id);

      return GestureDetector(
        onTap: () {
          selectionController.selectWithModifier(layer.id);
          // Open property panel for layer type
          uiController.openPanelForLayerType(layer.type);
        },
        onDoubleTap: () {
          // Start renaming
          _showRenameDialog(context);
        },
        onSecondaryTap: () {
          _showContextMenu(context);
        },
        child: Container(
          height: 56,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF0080FF).withOpacity(0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: isSelected
                ? Border.all(color: const Color(0xFF0080FF), width: 1)
                : null,
          ),
          child: Row(
            children: [
              // Drag handle
              ReorderableDragStartListener(
                index: index,
                child: Container(
                  width: 24,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.drag_indicator,
                    size: 16,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),

              // Thumbnail
              LayerThumbnail(layer: layer),

              const SizedBox(width: 8),

              // Layer info
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      layer.name,
                      style: TextStyle(
                        color: layer.visible
                            ? Colors.white
                            : Colors.white.withOpacity(0.4),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getLayerTypeLabel(layer.type),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              // Visibility toggle
              IconButton(
                icon: Icon(
                  layer.visible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 18,
                ),
                color: layer.visible
                    ? Colors.white.withOpacity(0.7)
                    : Colors.white.withOpacity(0.3),
                onPressed: () => layerController.toggleVisibility(layer.id),
                tooltip: layer.visible ? 'Hide' : 'Show',
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),

              // Lock toggle
              IconButton(
                icon: Icon(
                  layer.locked ? Icons.lock_outlined : Icons.lock_open_outlined,
                  size: 18,
                ),
                color: layer.locked
                    ? Colors.orange.withOpacity(0.7)
                    : Colors.white.withOpacity(0.3),
                onPressed: () => layerController.toggleLock(layer.id),
                tooltip: layer.locked ? 'Unlock' : 'Lock',
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        ),
      );
    });
  }

  String _getLayerTypeLabel(String type) {
    switch (type) {
      case 'text':
        return 'Text';
      case 'image':
        return 'Image';
      case 'svg':
        return 'Sticker';
      case 'shape':
        return 'Shape';
      default:
        return type;
    }
  }

  void _showRenameDialog(BuildContext context) {
    final layerController = Get.find<LayerController>();
    final textController = TextEditingController(text: layer.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a2a),
        title: const Text('Rename Layer', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: textController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Layer name',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF0080FF)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              layerController.renameLayer(layer.id, textController.text);
              Navigator.pop(context);
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    final layerController = Get.find<LayerController>();
    final selectionController = Get.find<SelectionController>();

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        MediaQuery.of(context).size.width / 2,
        MediaQuery.of(context).size.height / 2,
        MediaQuery.of(context).size.width / 2,
        MediaQuery.of(context).size.height / 2,
      ),
      color: const Color(0xFF2a2a2a),
      items: [
        _buildMenuItem(
          icon: Icons.content_copy,
          label: 'Duplicate',
          onTap: () => layerController.duplicateLayer(layer.id),
        ),
        _buildMenuItem(
          icon: Icons.delete_outline,
          label: 'Delete',
          onTap: () {
            selectionController.onLayerDeleted(layer.id);
            layerController.removeLayer(layer.id);
          },
          isDestructive: true,
        ),
        _buildMenuItem(
          icon: Icons.flip_to_front,
          label: 'Bring to Front',
          onTap: () => layerController.bringToFront(layer.id),
        ),
        _buildMenuItem(
          icon: Icons.flip_to_back,
          label: 'Send to Back',
          onTap: () => layerController.sendToBack(layer.id),
        ),
      ],
    );
  }

  PopupMenuItem _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return PopupMenuItem(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isDestructive ? Colors.red : Colors.white70,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: isDestructive ? Colors.red : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}