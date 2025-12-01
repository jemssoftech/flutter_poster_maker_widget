import 'package:flutter/material.dart' hide TextOverflow;
import 'package:flutter/material.dart' as material show TextOverflow;

import '../../../data/models/layers/text_layer.dart';
import '../../../data/models/layers/text_layer.dart' as model show TextOverflow;

/// Renders a text layer
class TextLayerWidget extends StatelessWidget {
  final TextLayer layer;

  const TextLayerWidget({
    super.key,
    required this.layer,
  });

  @override
  Widget build(BuildContext context) {
    // Build text style
    final textStyle = layer.buildTextStyle();

    // Build text widget
    Widget textWidget = Text(
      layer.transformedText,
      style: textStyle,
      textAlign: layer.paragraph.flutterTextAlign,
      textDirection: layer.paragraph.flutterTextDirection,
      maxLines: layer.maxLines,
      overflow: _getTextOverflow(),
    );

    // Apply text background if enabled
    if (layer.background.enabled) {
      textWidget = Container(
        padding: layer.background.padding,
        decoration: BoxDecoration(
          color: layer.background.color,
          borderRadius: layer.background.borderRadius,
        ),
        child: textWidget,
      );
    }

    // Apply outline if enabled
    if (layer.outline.enabled) {
      textWidget = Stack(
        children: [
          // Outline (using stroke paint)
          Text(
            layer.transformedText,
            style: textStyle.copyWith(
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = layer.outline.width
                ..color = layer.outline.color,
              shadows: null,
            ),
            textAlign: layer.paragraph.flutterTextAlign,
            textDirection: layer.paragraph.flutterTextDirection,
            maxLines: layer.maxLines,
          ),
          // Fill
          textWidget,
        ],
      );
    }

    // Calculate size
    final width = layer.transform.width != null
        ? layer.transform.width! * 1080
        : null;

    return SizedBox(
      width: width,
      child: textWidget,
    );
  }

  /// Convert model TextOverflow to Flutter TextOverflow
  material.TextOverflow _getTextOverflow() {
    switch (layer.overflow) {
      case model.TextOverflow.clip:
        return material.TextOverflow.clip;
      case model.TextOverflow.ellipsis:
        return material.TextOverflow.ellipsis;
      case model.TextOverflow.fade:
        return material.TextOverflow.fade;
      case model.TextOverflow.visible:
      default:
        return material.TextOverflow.visible;
    }
  }
}