import 'package:flutter/material.dart';
import 'package:flutter_poster_maker_widget/presentation/controllers/history_controller.dart';
import 'package:get/get.dart';

import '../../../presentation/controllers/ui_controller.dart';
import '../../../presentation/controllers/poster_controller.dart';
import '../canvas/editor_canvas.dart';
import '../sidebar/layers_sidebar.dart';
import '../assets_panel/assets_sidebar.dart';
import '../toolbar/bottom_toolbar.dart';
import '../property_panels/property_sheet.dart';
import '../shared/loading_indicator.dart';

/// Main scaffold for the editor layout
class EditorScaffold extends StatelessWidget {
  final bool showToolbar;
  final bool showLayersSidebar;
  final bool showAssetsSidebar;
  final void Function(String json)? onSave;
  final void Function(String format, dynamic data)? onExport;

  const EditorScaffold({
    super.key,
    this.showToolbar = true,
    this.showLayersSidebar = true,
    this.showAssetsSidebar = true,
    this.onSave,
    this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    final uiController = Get.find<UIController>();
    final posterController = Get.find<PosterController>();

    return LayoutBuilder(
      builder: (context, constraints) {
        // Update screen width for responsive layout
        WidgetsBinding.instance.addPostFrameCallback((_) {
          uiController.updateScreenWidth(constraints.maxWidth);
        });

        return Scaffold(
          backgroundColor: const Color(0xFF121212),
          body: Stack(
            children: [
              // Main content
              Column(
                children: [
                  // Header bar
                  _HeaderBar(onSave: onSave, onExport: onExport),

                  // Main area with sidebars
                  Expanded(
                    child: Row(
                      children: [
                        // Layers sidebar (left)
                        if (showLayersSidebar)
                          Obx(() => uiController.isLayersSidebarOpen.value
                              ? const LayersSidebar()
                              : const SizedBox.shrink()),

                        // Canvas area
                        const Expanded(
                          child: EditorCanvas(),
                        ),

                        // Assets sidebar (right)
                        if (showAssetsSidebar)
                          Obx(() => uiController.isAssetsSidebarOpen.value
                              ? const AssetsSidebar()
                              : const SizedBox.shrink()),
                      ],
                    ),
                  ),

                  // Bottom toolbar
                  if (showToolbar) const BottomToolbar(),
                ],
              ),

              // Property panel (bottom sheet)
              Obx(() => uiController.isPropertyPanelOpen.value
                  ? const PropertySheet()
                  : const SizedBox.shrink()),

              // Loading overlay
              Obx(() => posterController.isLoading.value ||
                  posterController.isSaving.value
                  ? Container(
                color: Colors.black54,
                child: LoadingIndicator(
                  message: posterController.isSaving.value
                      ? 'Saving...'
                      : 'Loading...',
                ),
              )
                  : const SizedBox.shrink()),
            ],
          ),
        );
      },
    );
  }
}

/// Header bar with title and actions
class _HeaderBar extends StatelessWidget {
  final void Function(String json)? onSave;
  final void Function(String format, dynamic data)? onExport;

  const _HeaderBar({this.onSave, this.onExport});

  @override
  Widget build(BuildContext context) {
    final posterController = Get.find<PosterController>();
    final historyController = Get.find<HistoryController>();
    final uiController = Get.find<UIController>();

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1e1e1e),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: Row(
        children: [
          // Menu button
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              // Toggle sidebars or show menu
            },
            tooltip: 'Menu',
          ),

          const SizedBox(width: 16),

          // Document title
          Obx(() => Expanded(
            child: Row(
              children: [
                Text(
                  posterController.documentName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (posterController.isDirty.value)
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Text(
                      '•',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 20,
                      ),
                    ),
                  ),
              ],
            ),
          )),

          // Undo button
          Obx(() => IconButton(
            icon: const Icon(Icons.undo),
            color: historyController.canUndo.value
                ? Colors.white
                : Colors.white38,
            onPressed: historyController.canUndo.value
                ? historyController.undo
                : null,
            tooltip: historyController.undoActionName.value.isNotEmpty
                ? 'Undo ${historyController.undoActionName.value}'
                : 'Undo',
          )),

          // Redo button
          Obx(() => IconButton(
            icon: const Icon(Icons.redo),
            color: historyController.canRedo.value
                ? Colors.white
                : Colors.white38,
            onPressed: historyController.canRedo.value
                ? historyController.redo
                : null,
            tooltip: historyController.redoActionName.value.isNotEmpty
                ? 'Redo ${historyController.redoActionName.value}'
                : 'Redo',
          )),

          const SizedBox(width: 8),

          // Save button
          _ActionButton(
            icon: Icons.save_outlined,
            label: 'Save',
            onPressed: () async {
              final json = await posterController.saveToJson();
              if (json != null && onSave != null) {
                onSave!(json);
              }
            },
          ),

          const SizedBox(width: 8),

          // Export button
          _ActionButton(
            icon: Icons.download_outlined,
            label: 'Export',
            isPrimary: true,
            onPressed: () {
              uiController.openPropertyPanel(PropertyPanelType.export);
            },
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onPressed,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: isPrimary ? Colors.white : Colors.white70,
        backgroundColor:
        isPrimary ? const Color(0xFF0080FF) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: isPrimary
              ? BorderSide.none
              : BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
      ),
    );
  }
}