import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../presentation/controllers/layer_controller.dart';
import '../../../presentation/controllers/selection_controller.dart';
import '../../../presentation/controllers/ui_controller.dart';
import '../../../data/models/shapes/shape_type.dart';

/// Menu for adding new layers
class AddLayerMenu extends StatelessWidget {
  const AddLayerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.add, color: Colors.white70, size: 20),
      tooltip: 'Add Layer',
      color: const Color(0xFF2a2a2a),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      offset: const Offset(0, 40),
      onSelected: (value) => _handleSelection(value),
      itemBuilder: (context) => [
        _buildMenuItem(
          value: 'text',
          icon: Icons.text_fields,
          label: 'Text',
        ),
        _buildMenuItem(
          value: 'image',
          icon: Icons.image_outlined,
          label: 'Image',
        ),
        _buildMenuItem(
          value: 'sticker',
          icon: Icons.emoji_emotions_outlined,
          label: 'Sticker',
        ),
        const PopupMenuDivider(),
        _buildMenuItem(
          value: 'rectangle',
          icon: Icons.rectangle_outlined,
          label: 'Rectangle',
        ),
        _buildMenuItem(
          value: 'circle',
          icon: Icons.circle_outlined,
          label: 'Circle',
        ),
        _buildMenuItem(
          value: 'star',
          icon: Icons.star_outline,
          label: 'Star',
        ),
        _buildMenuItem(
          value: 'line',
          icon: Icons.horizontal_rule,
          label: 'Line',
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildMenuItem({
    required String value,
    required IconData icon,
    required String label,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.white70),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  void _handleSelection(String value) {
    final layerController = Get.find<LayerController>();
    final selectionController = Get.find<SelectionController>();
    final uiController = Get.find<UIController>();

    String? newLayerId;

    switch (value) {
      case 'text':
        newLayerId = layerController.addTextLayer(
          text: 'New Text',
          name: 'Text',
        );
        uiController.openPropertyPanel(PropertyPanelType.text);
        break;

      case 'image':
        uiController.setAssetsTab(AssetsPanelTab.images);
        uiController.openAssetsSidebar();
        break;

      case 'sticker':
        uiController.setAssetsTab(AssetsPanelTab.stickers);
        uiController.openAssetsSidebar();
        break;

      case 'rectangle':
        newLayerId = layerController.addShapeLayer(
          shapeType: ShapeType.rectangle,
          name: 'Rectangle',
        );
        uiController.openPropertyPanel(PropertyPanelType.shape);
        break;

      case 'circle':
        newLayerId = layerController.addShapeLayer(
          shapeType: ShapeType.circle,
          name: 'Circle',
        );
        uiController.openPropertyPanel(PropertyPanelType.shape);
        break;

      case 'star':
        newLayerId = layerController.addShapeLayer(
          shapeType: ShapeType.star,
          name: 'Star',
        );
        uiController.openPropertyPanel(PropertyPanelType.shape);
        break;

      case 'line':
        newLayerId = layerController.addShapeLayer(
          shapeType: ShapeType.line,
          name: 'Line',
        );
        uiController.openPropertyPanel(PropertyPanelType.shape);
        break;
    }

    // Select the new layer
    if (newLayerId != null) {
      selectionController.select(newLayerId);
    }
  }
}