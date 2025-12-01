import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../presentation/controllers/layer_controller.dart';
import '../../../presentation/controllers/selection_controller.dart';
import '../../../presentation/controllers/ui_controller.dart';
import '../../../data/models/shapes/shape_type.dart';

/// Shapes tab in assets panel
class ShapesTab extends StatelessWidget {
  const ShapesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      padding: const EdgeInsets.all(12),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _ShapeItem(
          icon: Icons.rectangle_outlined,
          label: 'Rectangle',
          shapeType: ShapeType.rectangle,
        ),
        _ShapeItem(
          icon: Icons.circle_outlined,
          label: 'Circle',
          shapeType: ShapeType.circle,
        ),
        _ShapeItem(
          icon: Icons.change_history,
          label: 'Triangle',
          shapeType: ShapeType.triangle,
        ),
        _ShapeItem(
          icon: Icons.star_outline,
          label: 'Star',
          shapeType: ShapeType.star,
        ),
        _ShapeItem(
          icon: Icons.hexagon_outlined,
          label: 'Polygon',
          shapeType: ShapeType.polygon,
        ),
        _ShapeItem(
          icon: Icons.horizontal_rule,
          label: 'Line',
          shapeType: ShapeType.line,
        ),
        _ShapeItem(
          icon: Icons.arrow_forward,
          label: 'Arrow',
          shapeType: ShapeType.arrow,
        ),
      ],
    );
  }
}

class _ShapeItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final ShapeType shapeType;

  const _ShapeItem({
    required this.icon,
    required this.label,
    required this.shapeType,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _addShapeLayer,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white70, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addShapeLayer() {
    final layerController = Get.find<LayerController>();
    final selectionController = Get.find<SelectionController>();
    final uiController = Get.find<UIController>();

    final layerId = layerController.addShapeLayer(
      shapeType: shapeType,
      name: label,
    );

    selectionController.select(layerId);
    uiController.openPropertyPanel(PropertyPanelType.shape);
  }
}