import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/layers/shape_layer.dart';
import '../../../data/models/shapes/shape_type.dart';
import '../../../data/models/shapes/shape_fill.dart';
import '../../../presentation/controllers/layer_controller.dart';
import '../../../presentation/controllers/selection_controller.dart';
import '../shared/section_header.dart';
import '../shared/slider_input.dart';
import '../shared/color_picker.dart';

/// Shape properties panel
class ShapePropertiesPanel extends StatelessWidget {
  const ShapePropertiesPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final layerController = Get.find<LayerController>();
    final selectionController = Get.find<SelectionController>();

    return Obx(() {
      final primaryId = selectionController.primaryId;
      if (primaryId == null) {
        return const Center(
          child: Text(
            'Select a shape layer',
            style: TextStyle(color: Colors.white54),
          ),
        );
      }

      final layer = layerController.getLayerById(primaryId);
      if (layer is! ShapeLayer) {
        return const Center(
          child: Text(
            'Selected layer is not a shape layer',
            style: TextStyle(color: Colors.white54),
          ),
        );
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fill
            const SectionHeader(title: 'Fill'),
            _FillColorPicker(layer: layer),
            const SizedBox(height: 24),

            // Stroke
            const SectionHeader(title: 'Stroke'),
            _StrokeToggle(layer: layer),
            if (layer.stroke.enabled) ...[
              const SizedBox(height: 12),
              _StrokeColorPicker(layer: layer),
              const SizedBox(height: 12),
              _StrokeWidthSlider(layer: layer),
            ],
            const SizedBox(height: 24),

            // Corner radius (for rectangles)
            if (layer.shapeType == ShapeType.rectangle) ...[
              const SectionHeader(title: 'Corner Radius'),
              _CornerRadiusSlider(layer: layer),
              const SizedBox(height: 24),
            ],

            // Sides (for polygon/star)
            if (layer.shapeType == ShapeType.polygon ||
                layer.shapeType == ShapeType.star) ...[
              const SectionHeader(title: 'Shape Settings'),
              _SidesSlider(layer: layer),
              if (layer.shapeType == ShapeType.star) ...[
                const SizedBox(height: 12),
                _InnerRadiusSlider(layer: layer),
              ],
              const SizedBox(height: 24),
            ],

            // Opacity
            const SectionHeader(title: 'Opacity'),
            _OpacitySlider(layer: layer),
          ],
        ),
      );
    });
  }
}

class _FillColorPicker extends StatelessWidget {
  final ShapeLayer layer;

  const _FillColorPicker({required this.layer});

  @override
  Widget build(BuildContext context) {
    final layerController = Get.find<LayerController>();

    return ColorPickerButton(
      color: layer.fill.color ?? Colors.blue,
      label: 'Fill Color',
      onColorChanged: (color) {
        layerController.updateLayer(layer.id, (l) {
          return (l as ShapeLayer).copyWith(
            fill: ShapeFill.solid(color),
          );
        });
      },
    );
  }
}

class _StrokeToggle extends StatelessWidget {
  final ShapeLayer layer;

  const _StrokeToggle({required this.layer});

  @override
  Widget build(BuildContext context) {
    final layerController = Get.find<LayerController>();

    return Row(
      children: [
        const Text(
          'Enable Stroke',
          style: TextStyle(color: Colors.white70),
        ),
        const Spacer(),
        Switch(
          value: layer.stroke.enabled,
          activeColor: const Color(0xFF0080FF),
          onChanged: (value) {
            layerController.updateLayer(layer.id, (l) {
              return (l as ShapeLayer).copyWith(
                stroke: l.stroke.copyWith(enabled: value),
              );
            });
          },
        ),
      ],
    );
  }
}

class _StrokeColorPicker extends StatelessWidget {
  final ShapeLayer layer;

  const _StrokeColorPicker({required this.layer});

  @override
  Widget build(BuildContext context) {
    final layerController = Get.find<LayerController>();

    return ColorPickerButton(
      color: layer.stroke.color,
      label: 'Stroke Color',
      onColorChanged: (color) {
        layerController.updateLayer(layer.id, (l) {
          return (l as ShapeLayer).copyWith(
            stroke: l.stroke.copyWith(color: color),
          );
        });
      },
    );
  }
}

class _StrokeWidthSlider extends StatelessWidget {
  final ShapeLayer layer;

  const _StrokeWidthSlider({required this.layer});

  @override
  Widget build(BuildContext context) {
    final layerController = Get.find<LayerController>();

    return SliderInput(
      label: 'Stroke Width',
      value: layer.stroke.width,
      min: 1,
      max: 50,
      divisions: 49,
      onChanged: (value) {
        layerController.updateLayer(layer.id, (l) {
          return (l as ShapeLayer).copyWith(
            stroke: l.stroke.copyWith(width: value),
          );
        });
      },
    );
  }
}

class _CornerRadiusSlider extends StatelessWidget {
  final ShapeLayer layer;

  const _CornerRadiusSlider({required this.layer});

  @override
  Widget build(BuildContext context) {
    final layerController = Get.find<LayerController>();

    return SliderInput(
      label: 'Radius',
      value: layer.cornerRadius.uniformValue,
      min: 0,
      max: 100,
      divisions: 100,
      onChanged: (value) {
        layerController.updateLayer(layer.id, (l) {
          return (l as ShapeLayer).copyWith(
            cornerRadius: l.cornerRadius.withUniform(value),
          );
        });
      },
    );
  }
}

class _SidesSlider extends StatelessWidget {
  final ShapeLayer layer;

  const _SidesSlider({required this.layer});

  @override
  Widget build(BuildContext context) {
    final layerController = Get.find<LayerController>();

    return SliderInput(
      label: layer.shapeType == ShapeType.star ? 'Points' : 'Sides',
      value: layer.sides.toDouble(),
      min: 3,
      max: 12,
      divisions: 9,
      onChanged: (value) {
        layerController.updateLayer(layer.id, (l) {
          return (l as ShapeLayer).copyWith(
            shapeSpecific: l.shapeSpecific.copyWith(sides: value.round()),
          );
        });
      },
    );
  }
}

class _InnerRadiusSlider extends StatelessWidget {
  final ShapeLayer layer;

  const _InnerRadiusSlider({required this.layer});

  @override
  Widget build(BuildContext context) {
    final layerController = Get.find<LayerController>();

    return SliderInput(
      label: 'Inner Radius',
      value: layer.innerRadiusRatio,
      min: 0.1,
      max: 0.9,
      divisions: 16,
      onChanged: (value) {
        layerController.updateLayer(layer.id, (l) {
          return (l as ShapeLayer).copyWith(
            shapeSpecific: l.shapeSpecific.copyWith(innerRadiusRatio: value),
          );
        });
      },
    );
  }
}

class _OpacitySlider extends StatelessWidget {
  final ShapeLayer layer;

  const _OpacitySlider({required this.layer});

  @override
  Widget build(BuildContext context) {
    final layerController = Get.find<LayerController>();

    return SliderInput(
      label: 'Opacity',
      value: layer.opacity * 100,
      min: 0,
      max: 100,
      divisions: 100,
      suffix: '%',
      onChanged: (value) {
        layerController.setOpacity(layer.id, value / 100);
      },
    );
  }
}