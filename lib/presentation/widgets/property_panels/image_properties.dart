import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/layers/image_layer.dart';
import '../../../presentation/controllers/layer_controller.dart';
import '../../../presentation/controllers/selection_controller.dart';
import '../shared/section_header.dart';
import '../shared/slider_input.dart';

/// Image properties panel
class ImagePropertiesPanel extends StatelessWidget {
  const ImagePropertiesPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final layerController = Get.find<LayerController>();
    final selectionController = Get.find<SelectionController>();

    return Obx(() {
      final primaryId = selectionController.primaryId;
      if (primaryId == null) {
        return const Center(
          child: Text(
            'Select an image layer',
            style: TextStyle(color: Colors.white54),
          ),
        );
      }

      final layer = layerController.getLayerById(primaryId);
      if (layer is! ImageLayer) {
        return const Center(
          child: Text(
            'Selected layer is not an image layer',
            style: TextStyle(color: Colors.white54),
          ),
        );
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fit mode
            const SectionHeader(title: 'Fit Mode'),
            _FitModeSelector(layer: layer),
            const SizedBox(height: 24),

            // Filters
            const SectionHeader(title: 'Filters'),
            _BrightnessSlider(layer: layer),
            const SizedBox(height: 12),
            _ContrastSlider(layer: layer),
            const SizedBox(height: 12),
            _SaturationSlider(layer: layer),
            const SizedBox(height: 24),

            // Corner radius
            const SectionHeader(title: 'Corner Radius'),
            _CornerRadiusSlider(layer: layer),
            const SizedBox(height: 24),

            // Actions
            const SectionHeader(title: 'Actions'),
            _ImageActions(layer: layer),
          ],
        ),
      );
    });
  }
}

class _FitModeSelector extends StatelessWidget {
  final ImageLayer layer;

  const _FitModeSelector({required this.layer});

  @override
  Widget build(BuildContext context) {
    final layerController = Get.find<LayerController>();

    return Row(
      children: [
        _FitButton(
          icon: Icons.fit_screen,
          label: 'Contain',
          isSelected: layer.fit == ImageFit.contain,
          onTap: () => _setFit(layerController, ImageFit.contain),
        ),
        const SizedBox(width: 8),
        _FitButton(
          icon: Icons.crop,
          label: 'Cover',
          isSelected: layer.fit == ImageFit.cover,
          onTap: () => _setFit(layerController, ImageFit.cover),
        ),
        const SizedBox(width: 8),
        _FitButton(
          icon: Icons.fullscreen,
          label: 'Fill',
          isSelected: layer.fit == ImageFit.fill,
          onTap: () => _setFit(layerController, ImageFit.fill),
        ),
      ],
    );
  }

  void _setFit(LayerController controller, ImageFit fit) {
    controller.updateLayer(layer.id, (l) {
      return (l as ImageLayer).copyWith(fit: fit);
    });
  }
}

class _FitButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FitButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF0080FF).withOpacity(0.2)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF0080FF)
                  : Colors.white.withOpacity(0.1),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? const Color(0xFF0080FF) : Colors.white70,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected ? const Color(0xFF0080FF) : Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrightnessSlider extends StatelessWidget {
  final ImageLayer layer;

  const _BrightnessSlider({required this.layer});

  @override
  Widget build(BuildContext context) {
    final layerController = Get.find<LayerController>();

    return SliderInput(
      label: 'Brightness',
      value: layer.filters.brightness,
      min: 0.0,
      max: 2.0,
      divisions: 40,
      onChanged: (value) {
        layerController.updateLayer(layer.id, (l) {
          return (l as ImageLayer).copyWith(
            filters: l.filters.copyWith(brightness: value),
          );
        });
      },
    );
  }
}

class _ContrastSlider extends StatelessWidget {
  final ImageLayer layer;

  const _ContrastSlider({required this.layer});

  @override
  Widget build(BuildContext context) {
    final layerController = Get.find<LayerController>();

    return SliderInput(
      label: 'Contrast',
      value: layer.filters.contrast,
      min: 0.0,
      max: 2.0,
      divisions: 40,
      onChanged: (value) {
        layerController.updateLayer(layer.id, (l) {
          return (l as ImageLayer).copyWith(
            filters: l.filters.copyWith(contrast: value),
          );
        });
      },
    );
  }
}

class _SaturationSlider extends StatelessWidget {
  final ImageLayer layer;

  const _SaturationSlider({required this.layer});

  @override
  Widget build(BuildContext context) {
    final layerController = Get.find<LayerController>();

    return SliderInput(
      label: 'Saturation',
      value: layer.filters.saturation,
      min: 0.0,
      max: 2.0,
      divisions: 40,
      onChanged: (value) {
        layerController.updateLayer(layer.id, (l) {
          return (l as ImageLayer).copyWith(
            filters: l.filters.copyWith(saturation: value),
          );
        });
      },
    );
  }
}

class _CornerRadiusSlider extends StatelessWidget {
  final ImageLayer layer;

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
          return (l as ImageLayer).copyWith(
            cornerRadius: l.cornerRadius.withUniform(value),
          );
        });
      },
    );
  }
}

class _ImageActions extends StatelessWidget {
  final ImageLayer layer;

  const _ImageActions({required this.layer});

  @override
  Widget build(BuildContext context) {
    final layerController = Get.find<LayerController>();

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // Reset filters
              layerController.updateLayer(layer.id, (l) {
                return (l as ImageLayer).copyWith(
                  filters: const ImageFilters(),
                );
              });
            },
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Reset Filters'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white70,
              side: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // Replace image
              Get.snackbar(
                'Replace Image',
                'Feature coming soon',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: const Color(0xFF2a2a2a),
                colorText: Colors.white,
              );
            },
            icon: const Icon(Icons.swap_horiz, size: 18),
            label: const Text('Replace'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white70,
              side: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
          ),
        ),
      ],
    );
  }
}