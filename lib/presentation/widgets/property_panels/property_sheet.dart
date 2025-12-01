import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../presentation/controllers/ui_controller.dart';
import '../../../presentation/controllers/selection_controller.dart';
import 'text_properties.dart';
import 'image_properties.dart';
import 'shape_properties.dart';
import 'transform_properties.dart';
import 'alignment_panel.dart';

/// Bottom sheet for property panels
class PropertySheet extends StatelessWidget {
  const PropertySheet({super.key});

  @override
  Widget build(BuildContext context) {
    final uiController = Get.find<UIController>();

    return Obx(() {
      final panelType = uiController.activePropertyPanel.value;
      final panelHeight = uiController.propertyPanelHeight.value;

      return Positioned(
        left: 0,
        right: 0,
        bottom: 56, // Above bottom toolbar
        child: GestureDetector(
          onVerticalDragUpdate: (details) {
            final screenHeight = MediaQuery.of(context).size.height;
            final newHeight = panelHeight - (details.delta.dy / screenHeight);
            uiController.setPropertyPanelHeight(newHeight);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: MediaQuery.of(context).size.height * panelHeight,
            decoration: BoxDecoration(
              color: const Color(0xFF1e1e1e),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Drag handle and header
                _PanelHeader(panelType: panelType),

                // Panel content
                Expanded(
                  child: _buildPanelContent(panelType),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildPanelContent(PropertyPanelType type) {
    switch (type) {
      case PropertyPanelType.text:
        return const TextPropertiesPanel();
      case PropertyPanelType.image:
        return const ImagePropertiesPanel();
      case PropertyPanelType.shape:
        return const ShapePropertiesPanel();
      case PropertyPanelType.svg:
        return const _SvgPropertiesPlaceholder();
      case PropertyPanelType.transform:
        return const TransformPropertiesPanel();
      case PropertyPanelType.effects:
        return const _EffectsPropertiesPlaceholder();
      case PropertyPanelType.alignment:
        return const AlignmentPanel();
      case PropertyPanelType.canvas:
        return const _CanvasPropertiesPlaceholder();
      case PropertyPanelType.export:
        return const _ExportPanelPlaceholder();
      default:
        return const Center(
          child: Text(
            'Select a layer to edit properties',
            style: TextStyle(color: Colors.white54),
          ),
        );
    }
  }
}

class _PanelHeader extends StatelessWidget {
  final PropertyPanelType panelType;

  const _PanelHeader({required this.panelType});

  @override
  Widget build(BuildContext context) {
    final uiController = Get.find<UIController>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: Column(
        children: [
          // Drag indicator
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title and close button
          Row(
            children: [
              Text(
                panelType.displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                color: Colors.white70,
                onPressed: uiController.closePropertyPanel,
                tooltip: 'Close',
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Placeholder panels for features to be implemented
class _SvgPropertiesPlaceholder extends StatelessWidget {
  const _SvgPropertiesPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'SVG Properties - Coming Soon',
        style: TextStyle(color: Colors.white54),
      ),
    );
  }
}

class _EffectsPropertiesPlaceholder extends StatelessWidget {
  const _EffectsPropertiesPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Effects Properties - Coming Soon',
        style: TextStyle(color: Colors.white54),
      ),
    );
  }
}

class _CanvasPropertiesPlaceholder extends StatelessWidget {
  const _CanvasPropertiesPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Canvas Settings - Coming Soon',
        style: TextStyle(color: Colors.white54),
      ),
    );
  }
}

class _ExportPanelPlaceholder extends StatelessWidget {
  const _ExportPanelPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Export Options - Coming Soon',
        style: TextStyle(color: Colors.white54),
      ),
    );
  }
}