import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/editor_constants.dart';
import '../../../presentation/controllers/ui_controller.dart';
import '../../../presentation/controllers/layer_controller.dart';
import 'layer_list.dart';
import 'add_layer_menu.dart';

/// Layers sidebar (left side)
class LayersSidebar extends StatelessWidget {
  const LayersSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final uiController = Get.find<UIController>();
    final layerController = Get.find<LayerController>();

    return Obx(() => Container(
      width: uiController.layersSidebarWidth.value,
      decoration: BoxDecoration(
        color: const Color(0xFF1e1e1e),
        border: Border(
          right: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: Column(
        children: [
          // Header
          _SidebarHeader(
            title: 'Layers',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Add layer button
                const AddLayerMenu(),

                // Collapse button
                IconButton(
                  icon: const Icon(Icons.chevron_left, size: 20),
                  color: Colors.white70,
                  onPressed: uiController.closeLayersSidebar,
                  tooltip: 'Collapse',
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
          ),

          // Layer count
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Obx(() => Text(
                  '${layerController.layerCount} layer${layerController.layerCount != 1 ? 's' : ''}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                )),
              ],
            ),
          ),

          // Divider
          Divider(color: Colors.white.withOpacity(0.1), height: 1),

          // Layer list
          const Expanded(
            child: LayerList(),
          ),
        ],
      ),
    ));
  }
}

class _SidebarHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const _SidebarHeader({
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}