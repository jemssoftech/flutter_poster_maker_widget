import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/layers/image_layer.dart';
import '../../../presentation/controllers/assets_controller.dart';

/// Renders an image layer
class ImageLayerWidget extends StatelessWidget {
  final ImageLayer layer;

  const ImageLayerWidget({
    super.key,
    required this.layer,
  });

  @override
  Widget build(BuildContext context) {
    final assetsController = Get.find<AssetsController>();
    final asset = assetsController.getImage(layer.assetId);

    if (asset == null) {
      return const _PlaceholderImage();
    }

    // Calculate size
    final width = layer.transform.width != null
        ? layer.transform.width! * 1080 // Default canvas width
        : 200.0;
    final height = layer.transform.height != null
        ? layer.transform.height! * 1920 // Default canvas height
        : 200.0;

    Widget imageWidget;

    // Load image based on source
    if (asset.data != null && asset.data!.isNotEmpty) {
      // Base64 data
      final bytes = _base64ToBytes(asset.data!);
      if (bytes != null && bytes.isNotEmpty) {
        imageWidget = Image.memory(
          bytes,
          width: width,
          height: height,
          fit: layer.fit.toBoxFit(),
          alignment: Alignment(
            layer.alignment.dx * 2 - 1,
            layer.alignment.dy * 2 - 1,
          ),
          errorBuilder: (context, error, stackTrace) {
            return const _ErrorImage();
          },
        );
      } else {
        return const _PlaceholderImage();
      }
    } else if (asset.url != null && asset.url!.isNotEmpty) {
      // Network image
      imageWidget = Image.network(
        asset.url!,
        width: width,
        height: height,
        fit: layer.fit.toBoxFit(),
        alignment: Alignment(
          layer.alignment.dx * 2 - 1,
          layer.alignment.dy * 2 - 1,
        ),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _PlaceholderImage(progress: loadingProgress);
        },
        errorBuilder: (context, error, stackTrace) {
          return const _ErrorImage();
        },
      );
    } else {
      return const _PlaceholderImage();
    }

    // Apply filters
    if (layer.filters.hasFilters) {
      final colorFilter = layer.filters.toColorFilter();
      if (colorFilter != null) {
        imageWidget = ColorFiltered(
          colorFilter: colorFilter,
          child: imageWidget,
        );
      }
    }

    // Apply corner radius
    if (layer.cornerRadius.hasRadius) {
      imageWidget = ClipRRect(
        borderRadius: layer.cornerRadius.toBorderRadius(),
        child: imageWidget,
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: imageWidget,
    );
  }

  /// Decode base64 to Uint8List
  Uint8List? _base64ToBytes(String base64String) {
    try {
      // Strip data URI prefix if present
      String data = base64String;
      if (data.contains(',')) {
        data = data.split(',').last;
      }
      return base64Decode(data);
    } catch (e) {
      return null;
    }
  }
}

class _PlaceholderImage extends StatelessWidget {
  final ImageChunkEvent? progress;

  const _PlaceholderImage({this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: progress != null
            ? CircularProgressIndicator(
          value: progress!.expectedTotalBytes != null
              ? progress!.cumulativeBytesLoaded /
              progress!.expectedTotalBytes!
              : null,
        )
            : Icon(Icons.image, size: 48, color: Colors.grey.shade400),
      ),
    );
  }
}

class _ErrorImage extends StatelessWidget {
  const _ErrorImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red.shade100,
      child: Center(
        child: Icon(Icons.broken_image, size: 48, color: Colors.red.shade400),
      ),
    );
  }
}