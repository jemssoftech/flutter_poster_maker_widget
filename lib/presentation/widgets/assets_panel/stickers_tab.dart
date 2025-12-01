import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../presentation/controllers/assets_controller.dart';
import '../../../presentation/controllers/layer_controller.dart';
import '../../../presentation/controllers/selection_controller.dart';

/// Stickers tab in assets panel
class StickersTab extends StatelessWidget {
  const StickersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final assetsController = Get.find<AssetsController>();

    return Obx(() {
      final packs = assetsController.stickerPacks;

      if (packs.isEmpty) {
        return _LoadingOrEmpty(
          isLoading: assetsController.isLoading.value,
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: packs.length,
        itemBuilder: (context, index) {
          final pack = packs[index];
          return _StickerPackItem(pack: pack);
        },
      );
    });
  }
}

class _StickerPackItem extends StatelessWidget {
  final StickerPack pack;

  const _StickerPackItem({required this.pack});

  @override
  Widget build(BuildContext context) {
    final assetsController = Get.find<AssetsController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pack header
        InkWell(
          onTap: () => assetsController.toggleStickerPack(pack.id),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(
                  pack.isExpanded
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_right,
                  color: Colors.white70,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    pack.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  '${pack.stickers.length}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Stickers grid (when expanded)
        if (pack.isExpanded)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: pack.stickers.isEmpty ? 8 : pack.stickers.length,
            itemBuilder: (context, index) {
              if (pack.stickers.isEmpty) {
                // Placeholder stickers
                return _StickerPlaceholder();
              }
              final sticker = pack.stickers[index];
              return _StickerItem(sticker: sticker);
            },
          ),

        Divider(color: Colors.white.withOpacity(0.1)),
      ],
    );
  }
}

class _StickerItem extends StatelessWidget {
  final dynamic sticker;

  const _StickerItem({required this.sticker});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _addStickerLayer(),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.emoji_emotions,
          color: Colors.white.withOpacity(0.5),
        ),
      ),
    );
  }

  void _addStickerLayer() {
    final layerController = Get.find<LayerController>();
    final selectionController = Get.find<SelectionController>();

    final layerId = layerController.addSvgLayer(
      assetId: sticker.id,
      name: sticker.name ?? 'Sticker',
    );

    selectionController.select(layerId);
  }
}

class _StickerPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.emoji_emotions_outlined,
        color: Colors.white.withOpacity(0.3),
      ),
    );
  }
}

class _LoadingOrEmpty extends StatelessWidget {
  final bool isLoading;

  const _LoadingOrEmpty({required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF0080FF)),
      );
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.emoji_emotions_outlined,
            size: 48,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No stickers available',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}