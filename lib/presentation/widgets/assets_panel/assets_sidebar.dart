import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../presentation/controllers/ui_controller.dart';
import 'images_tab.dart';
import 'stickers_tab.dart';
import 'shapes_tab.dart';
import 'fonts_tab.dart';

/// Assets sidebar (right side)
class AssetsSidebar extends StatelessWidget {
  const AssetsSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final uiController = Get.find<UIController>();

    return Obx(() => Container(
      width: uiController.assetsSidebarWidth.value,
      decoration: BoxDecoration(
        color: const Color(0xFF1e1e1e),
        border: Border(
          left: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: Column(
        children: [
          // Header with collapse button
          _AssetsSidebarHeader(),

          // Tab bar
          _AssetsTabBar(),

          // Search
          _SearchBar(),

          // Tab content
          Expanded(
            child: Obx(() {
              switch (uiController.activeAssetsTab.value) {
                case AssetsPanelTab.images:
                  return const ImagesTab();
                case AssetsPanelTab.stickers:
                  return const StickersTab();
                case AssetsPanelTab.shapes:
                  return const ShapesTab();
                case AssetsPanelTab.fonts:
                  return const FontsTab();
              }
            }),
          ),
        ],
      ),
    ));
  }
}

class _AssetsSidebarHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final uiController = Get.find<UIController>();

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
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 20),
            color: Colors.white70,
            onPressed: uiController.closeAssetsSidebar,
            tooltip: 'Collapse',
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          const Expanded(
            child: Text(
              'Assets',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssetsTabBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final uiController = Get.find<UIController>();

    return Container(
      padding: const EdgeInsets.all(8),
      child: Obx(() => Row(
        children: [
          _TabButton(
            icon: Icons.image_outlined,
            label: 'Images',
            isSelected:
            uiController.activeAssetsTab.value == AssetsPanelTab.images,
            onTap: () => uiController.setAssetsTab(AssetsPanelTab.images),
          ),
          _TabButton(
            icon: Icons.emoji_emotions_outlined,
            label: 'Stickers',
            isSelected: uiController.activeAssetsTab.value ==
                AssetsPanelTab.stickers,
            onTap: () => uiController.setAssetsTab(AssetsPanelTab.stickers),
          ),
          _TabButton(
            icon: Icons.category_outlined,
            label: 'Shapes',
            isSelected:
            uiController.activeAssetsTab.value == AssetsPanelTab.shapes,
            onTap: () => uiController.setAssetsTab(AssetsPanelTab.shapes),
          ),
          _TabButton(
            icon: Icons.text_fields,
            label: 'Fonts',
            isSelected:
            uiController.activeAssetsTab.value == AssetsPanelTab.fonts,
            onTap: () => uiController.setAssetsTab(AssetsPanelTab.fonts),
          ),
        ],
      )),
    );
  }
}

class _TabButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF0080FF).withOpacity(0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? const Color(0xFF0080FF) : Colors.white54,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF0080FF) : Colors.white54,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final uiController = Get.find<UIController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: TextField(
        onChanged: uiController.setAssetsSearchQuery,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
          prefixIcon:
          Icon(Icons.search, color: Colors.white.withOpacity(0.3), size: 20),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF0080FF)),
          ),
        ),
      ),
    );
  }
}