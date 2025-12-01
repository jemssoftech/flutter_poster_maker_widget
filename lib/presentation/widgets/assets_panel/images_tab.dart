import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../presentation/controllers/assets_controller.dart';
import '../../../presentation/controllers/layer_controller.dart';
import '../../../presentation/controllers/selection_controller.dart';
import 'asset_grid.dart';

/// Images tab in assets panel
class ImagesTab extends StatelessWidget {
  const ImagesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final assetsController = Get.find<AssetsController>();

    return Column(
      children: [
        // Upload button
        Padding(
          padding: const EdgeInsets.all(12),
          child: _UploadButton(
            onUpload: () => _handleUpload(),
          ),
        ),

        // Recent images
        Obx(() {
          final recentImages = assetsController.recentImages;

          if (recentImages.isNotEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'Recent',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: recentImages.length,
                    itemBuilder: (context, index) {
                      final image = recentImages[index];
                      return _RecentImageItem(
                        imageAsset: image,
                        onTap: () => _addImageLayer(image.id),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Divider(color: Colors.white.withOpacity(0.1), height: 1),
              ],
            );
          }
          return const SizedBox.shrink();
        }),

        // All images grid
        Expanded(
          child: Obx(() {
            final images = assetsController.imageList;

            if (images.isEmpty) {
              return _EmptyState(
                icon: Icons.image_outlined,
                message: 'No images yet',
                subMessage: 'Upload images to use in your design',
              );
            }

            return AssetGrid(
              itemCount: images.length,
              itemBuilder: (context, index) {
                final image = images[index];
                return _ImageGridItem(
                  imageAsset: image,
                  onTap: () => _addImageLayer(image.id),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  void _handleUpload() {
    // TODO: Implement file picker
    // For now, show a placeholder message
    Get.snackbar(
      'Upload',
      'File picker will be implemented',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF2a2a2a),
      colorText: Colors.white,
    );
  }

  void _addImageLayer(String assetId) {
    final layerController = Get.find<LayerController>();
    final selectionController = Get.find<SelectionController>();

    final layerId = layerController.addImageLayer(
      assetId: assetId,
      name: 'Image',
    );

    selectionController.select(layerId);
  }
}

class _UploadButton extends StatelessWidget {
  final VoidCallback onUpload;

  const _UploadButton({required this.onUpload});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onUpload,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFF0080FF).withOpacity(0.5),
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(8),
          color: const Color(0xFF0080FF).withOpacity(0.1),
        ),
        child: Column(
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              color: const Color(0xFF0080FF).withOpacity(0.8),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'Upload Image',
              style: TextStyle(
                color: const Color(0xFF0080FF).withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentImageItem extends StatelessWidget {
  final dynamic imageAsset;
  final VoidCallback onTap;

  const _RecentImageItem({
    required this.imageAsset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        height: 70,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Icon(
          Icons.image,
          color: Colors.white.withOpacity(0.5),
        ),
      ),
    );
  }
}

class _ImageGridItem extends StatelessWidget {
  final dynamic imageAsset;
  final VoidCallback onTap;

  const _ImageGridItem({
    required this.imageAsset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Icon(
          Icons.image,
          color: Colors.white.withOpacity(0.5),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String subMessage;

  const _EmptyState({
    required this.icon,
    required this.message,
    required this.subMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Colors.white.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subMessage,
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