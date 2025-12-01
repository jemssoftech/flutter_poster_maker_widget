import 'package:flutter/material.dart';

import '../../../data/models/layers/layer_base.dart';

/// Thumbnail preview for a layer
class LayerThumbnail extends StatelessWidget {
  final LayerBase layer;
  final double size;

  const LayerThumbnail({
    super.key,
    required this.layer,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: _buildThumbnailContent(),
      ),
    );
  }

  Widget _buildThumbnailContent() {
    switch (layer.type) {
      case 'text':
        return Center(
          child: Icon(
            Icons.text_fields,
            size: size * 0.5,
            color: Colors.white.withOpacity(0.7),
          ),
        );
      case 'image':
        return Center(
          child: Icon(
            Icons.image_outlined,
            size: size * 0.5,
            color: Colors.white.withOpacity(0.7),
          ),
        );
      case 'svg':
        return Center(
          child: Icon(
            Icons.category_outlined,
            size: size * 0.5,
            color: Colors.white.withOpacity(0.7),
          ),
        );
      case 'shape':
        return Center(
          child: Icon(
            Icons.square_outlined,
            size: size * 0.5,
            color: Colors.white.withOpacity(0.7),
          ),
        );
      default:
        return Center(
          child: Icon(
            Icons.layers_outlined,
            size: size * 0.5,
            color: Colors.white.withOpacity(0.7),
          ),
        );
    }
  }
}