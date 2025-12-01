import 'dart:ui' show Size;

import 'package:flutter/material.dart';

import '../../../data/models/layers/layer_base.dart';
import '../../../data/models/layers/image_layer.dart';
import '../../../data/models/layers/text_layer.dart';
import '../../../data/models/layers/svg_layer.dart';
import '../../../data/models/layers/shape_layer.dart';
import 'image_layer_widget.dart';
import 'text_layer_widget.dart';
import 'svg_layer_widget.dart';
import 'shape_layer_widget.dart';
import 'layer_effects_wrapper.dart';

/// Dispatches layer rendering to appropriate widget
class LayerRenderer extends StatelessWidget {
  final LayerBase layer;
  final Size canvasSize;

  const LayerRenderer({
    super.key,
    required this.layer,
    required this.canvasSize,
  });

  @override
  Widget build(BuildContext context) {
    // Don't render if invisible
    if (!layer.visible) {
      return const SizedBox.shrink();
    }

    // Get transform matrix
    final transform = layer.transform.buildMatrix(canvasSize);

    // Render layer based on type
    Widget child;

    if (layer is ImageLayer) {
      child = ImageLayerWidget(layer: layer as ImageLayer);
    } else if (layer is TextLayer) {
      child = TextLayerWidget(layer: layer as TextLayer);
    } else if (layer is SvgLayer) {
      child = SvgLayerWidget(layer: layer as SvgLayer);
    } else if (layer is ShapeLayer) {
      child = ShapeLayerWidget(layer: layer as ShapeLayer);
    } else {
      child = const SizedBox.shrink();
    }

    // Apply transform
    child = Transform(
      transform: transform,
      child: child,
    );

    // Apply opacity
    if (layer.opacity < 1.0) {
      child = Opacity(
        opacity: layer.opacity,
        child: child,
      );
    }

    // Apply effects (shadow, blur, border)
    if (layer.hasEffects) {
      child = LayerEffectsWrapper(
        effects: layer.effects,
        child: child,
      );
    }

    return child;
  }
}