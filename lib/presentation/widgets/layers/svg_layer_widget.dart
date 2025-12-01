import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/layers/svg_layer.dart';
import '../../../presentation/controllers/assets_controller.dart';

/// Renders an SVG layer
class SvgLayerWidget extends StatelessWidget {
  final SvgLayer layer;

  const SvgLayerWidget({
    super.key,
    required this.layer,
  });

  @override
  Widget build(BuildContext context) {
    final assetsController = Get.find<AssetsController>();
    final asset = assetsController.getSvg(layer.assetId);

    if (asset == null) {
      return _PlaceholderSvg();
    }

    // Calculate size
    final width = layer.transform.width != null
        ? layer.transform.width! * 1080
        : asset.width;
    final height = layer.transform.height != null
        ? layer.transform.height! * 1920
        : asset.height;

    // In production, use flutter_svg package:
    // return SvgPicture.string(
    //   _getModifiedSvgData(asset.data, layer.elementOverrides),
    //   width: width,
    //   height: height,
    //   fit: layer.preserveAspectRatio ? BoxFit.contain : BoxFit.fill,
    // );

    // Placeholder for now
    return Container(
      width: width,
      height: height,
      color: Colors.purple.withOpacity(0.2),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.image, size: 48, color: Colors.purple),
            const SizedBox(height: 8),
            Text(
              asset.name,
              style: const TextStyle(color: Colors.purple, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // In production, modify SVG data based on element overrides
  String _getModifiedSvgData(
      String originalSvg,
      Map<String, dynamic> overrides,
      ) {
    // Parse SVG and apply color overrides
    // This would use an XML parser in production
    return originalSvg;
  }
}

class _PlaceholderSvg extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      color: Colors.grey.shade200,
      child: Center(
        child: Icon(Icons.category, size: 48, color: Colors.grey.shade400),
      ),
    );
  }
}