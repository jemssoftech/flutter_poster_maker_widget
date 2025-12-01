import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../presentation/controllers/tool_controller.dart';
import '../../../presentation/controllers/ui_controller.dart';
import '../../../presentation/controllers/history_controller.dart';
import 'tool_button.dart';
import 'toolbar_divider.dart';

/// Bottom toolbar with tools
class BottomToolbar extends StatelessWidget {
  const BottomToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    final toolController = Get.find<ToolController>();
    final uiController = Get.find<UIController>();

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF1e1e1e),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),

          // Tool buttons
          Obx(() => ToolButton(
            icon: Icons.near_me_outlined,
            label: 'Select',
            shortcut: 'V',
            isSelected: toolController.activeTool.value == EditorTool.select,
            onPressed: () => toolController.selectTool(EditorTool.select),
          )),

          Obx(() => ToolButton(
            icon: Icons.text_fields,
            label: 'Text',
            shortcut: 'T',
            isSelected: toolController.activeTool.value == EditorTool.text,
            onPressed: () => toolController.selectTool(EditorTool.text),
          )),

          Obx(() => ToolButton(
            icon: Icons.image_outlined,
            label: 'Image',
            shortcut: 'I',
            isSelected: toolController.activeTool.value == EditorTool.image,
            onPressed: () {
              toolController.selectTool(EditorTool.image);
              uiController.setAssetsTab(AssetsPanelTab.images);
              uiController.openAssetsSidebar();
            },
          )),

          Obx(() => ToolButton(
            icon: Icons.emoji_emotions_outlined,
            label: 'Sticker',
            shortcut: 'S',
            isSelected: toolController.activeTool.value == EditorTool.svg,
            onPressed: () {
              toolController.selectTool(EditorTool.svg);
              uiController.setAssetsTab(AssetsPanelTab.stickers);
              uiController.openAssetsSidebar();
            },
          )),

          Obx(() => ToolButton(
            icon: Icons.category_outlined,
            label: 'Shape',
            shortcut: 'U',
            isSelected: toolController.activeTool.value == EditorTool.shape,
            onPressed: () {
              toolController.selectTool(EditorTool.shape);
              uiController.setAssetsTab(AssetsPanelTab.shapes);
              uiController.openAssetsSidebar();
            },
          )),

          const ToolbarDivider(),

          // Align button
          ToolButton(
            icon: Icons.align_horizontal_center,
            label: 'Align',
            onPressed: () =>
                uiController.openPropertyPanel(PropertyPanelType.alignment),
          ),

          const Spacer(),

          // View options
          Obx(() => ToolButton(
            icon: uiController.showGrid.value
                ? Icons.grid_on
                : Icons.grid_off,
            label: 'Grid',
            isSelected: uiController.showGrid.value,
            onPressed: uiController.toggleGrid,
          )),

          Obx(() => ToolButton(
            icon: Icons.straighten,
            label: 'Rulers',
            isSelected: uiController.showRulers.value,
            onPressed: uiController.toggleRulers,
          )),

          const ToolbarDivider(),

          // Hand tool
          Obx(() => ToolButton(
            icon: Icons.pan_tool_outlined,
            label: 'Pan',
            shortcut: 'H',
            isSelected: toolController.activeTool.value == EditorTool.hand,
            onPressed: () => toolController.selectTool(EditorTool.hand),
          )),

          const SizedBox(width: 16),
        ],
      ),
    );
  }
}