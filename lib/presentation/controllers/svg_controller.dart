import 'package:flutter/material.dart' show Color;
import 'package:get/get.dart';

import '../../data/models/assets/svg_asset.dart';
import '../../data/models/svg/svg_element.dart';
import '../../data/models/svg/svg_element_override.dart';
import '../../data/models/layers/svg_layer.dart';
import 'layer_controller.dart';
import 'assets_controller.dart';

/// Controller for SVG element editing
class SvgController extends GetxController {
  // ==================== Reactive State ====================

  /// Currently active SVG layer ID
  final Rx<String?> activeLayerId = Rx<String?>(null);

  /// Currently selected element ID within the SVG
  final Rx<String?> selectedElementId = Rx<String?>(null);

  /// Element overrides for the active layer
  final RxMap<String, SvgElementOverride> elementOverrides =
      <String, SvgElementOverride>{}.obs;

  /// Expanded elements in the tree view
  final RxSet<String> expandedElements = <String>{}.obs;

  // ==================== Getters ====================

  /// Get active SVG layer
  SvgLayer? get activeLayer {
    if (activeLayerId.value == null) return null;
    if (!Get.isRegistered<LayerController>()) return null;

    final layer = Get.find<LayerController>().getLayerById(activeLayerId.value!);
    return layer is SvgLayer ? layer : null;
  }

  /// Get active SVG asset
  SvgAsset? get activeSvgAsset {
    final layer = activeLayer;
    if (layer == null) return null;
    if (!Get.isRegistered<AssetsController>()) return null;

    return Get.find<AssetsController>().getSvg(layer.assetId);
  }

  /// Get editable elements list
  List<SvgElement> get editableElements {
    final asset = activeSvgAsset;
    if (asset == null) return [];
    return asset.elements.values.where((e) => e.isEditable).toList();
  }

  /// Get selected element
  SvgElement? get selectedElement {
    if (selectedElementId.value == null) return null;
    return activeSvgAsset?.getElement(selectedElementId.value!);
  }

  /// Get override for selected element
  SvgElementOverride? get selectedElementOverride {
    if (selectedElementId.value == null) return null;
    return elementOverrides[selectedElementId.value!];
  }

  /// Check if has active SVG
  bool get hasActiveSvg => activeLayer != null;

  /// Check if has selected element
  bool get hasSelectedElement => selectedElement != null;

  // ==================== Activation ====================

  /// Set active SVG layer
  void setActiveSvg(String layerId) {
    final layerController = Get.find<LayerController>();
    final layer = layerController.getLayerById(layerId);

    if (layer is! SvgLayer) {
      clearActiveSvg();
      return;
    }

    activeLayerId.value = layerId;

    // Load existing overrides from layer
    elementOverrides.assignAll(layer.elementOverrides);
    selectedElementId.value = null;
  }

  /// Clear active SVG
  void clearActiveSvg() {
    activeLayerId.value = null;
    selectedElementId.value = null;
    elementOverrides.clear();
    expandedElements.clear();
  }

  // ==================== Element Selection ====================

  /// Select an element
  void selectElement(String elementId) {
    final asset = activeSvgAsset;
    if (asset == null) return;

    if (asset.elements.containsKey(elementId)) {
      selectedElementId.value = elementId;
    }
  }

  /// Clear element selection
  void clearElementSelection() {
    selectedElementId.value = null;
  }

  /// Toggle element expansion in tree view
  void toggleElementExpansion(String elementId) {
    if (expandedElements.contains(elementId)) {
      expandedElements.remove(elementId);
    } else {
      expandedElements.add(elementId);
    }
  }

  // ==================== Element Editing ====================

  /// Update element fill color
  void updateElementFill(String elementId, Color color) {
    _updateElementOverride(
      elementId,
          (override) => override.copyWith(fill: color),
    );
  }

  /// Update element stroke color
  void updateElementStroke(String elementId, Color color) {
    _updateElementOverride(
      elementId,
          (override) => override.copyWith(stroke: color),
    );
  }

  /// Update element stroke width
  void updateElementStrokeWidth(String elementId, double width) {
    _updateElementOverride(
      elementId,
          (override) => override.copyWith(strokeWidth: width),
    );
  }

  /// Update element opacity
  void updateElementOpacity(String elementId, double opacity) {
    _updateElementOverride(
      elementId,
          (override) => override.copyWith(opacity: opacity.clamp(0.0, 1.0)),
    );
  }

  /// Update element with custom override
  void updateElement(String elementId, SvgElementOverride override) {
    elementOverrides[elementId] = override;
    _syncToLayer();
  }

  /// Reset element to original
  void resetElement(String elementId) {
    elementOverrides.remove(elementId);
    _syncToLayer();
  }

  /// Reset all elements to original
  void resetAllElements() {
    elementOverrides.clear();
    _syncToLayer();
  }

  void _updateElementOverride(
      String elementId,
      SvgElementOverride Function(SvgElementOverride) updater,
      ) {
    final current = elementOverrides[elementId] ?? const SvgElementOverride();
    final updated = updater(current);

    if (updated.hasOverrides) {
      elementOverrides[elementId] = updated;
    } else {
      elementOverrides.remove(elementId);
    }

    _syncToLayer();
  }

  // ==================== Quick Actions ====================

  /// Apply fill color to all elements
  void applyFillToAll(Color color) {
    for (final element in editableElements) {
      if (element.hasFill) {
        updateElementFill(element.id, color);
      }
    }
  }

  /// Apply stroke color to all elements
  void applyStrokeToAll(Color color) {
    for (final element in editableElements) {
      if (element.hasStroke) {
        updateElementStroke(element.id, color);
      }
    }
  }

  /// Apply color scheme (primary and secondary colors)
  void applyColorScheme(Color primaryColor, Color secondaryColor) {
    final elements = editableElements;
    for (int i = 0; i < elements.length; i++) {
      final element = elements[i];
      final color = i % 2 == 0 ? primaryColor : secondaryColor;

      if (element.hasFill) {
        updateElementFill(element.id, color);
      } else if (element.hasStroke) {
        updateElementStroke(element.id, color);
      }
    }
  }

  // ==================== SVG Rendering ====================

  /// Get modified SVG data for rendering
  String? getModifiedSvgData() {
    final asset = activeSvgAsset;
    if (asset == null) return null;

    // In real implementation, modify the SVG XML with overrides
    // For now, return original
    return asset.data;
  }

  /// Build style string for an element
  String buildElementStyle(String elementId) {
    final override = elementOverrides[elementId];
    if (override == null) return '';

    final styles = <String>[];

    if (override.fill != null) {
      styles.add('fill: ${_colorToHex(override.fill!)}');
    }
    if (override.stroke != null) {
      styles.add('stroke: ${_colorToHex(override.stroke!)}');
    }
    if (override.strokeWidth != null) {
      styles.add('stroke-width: ${override.strokeWidth}');
    }
    if (override.opacity != null) {
      styles.add('opacity: ${override.opacity}');
    }

    return styles.join('; ');
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  // ==================== Sync ====================

  /// Sync overrides to layer
  void _syncToLayer() {
    if (activeLayerId.value == null) return;
    if (!Get.isRegistered<LayerController>()) return;

    final layerController = Get.find<LayerController>();
    layerController.updateLayer(activeLayerId.value!, (layer) {
      if (layer is SvgLayer) {
        return layer.copyWith(elementOverrides: Map.from(elementOverrides));
      }
      return layer;
    });
  }

  @override
  void onClose() {
    clearActiveSvg();
    super.onClose();
  }
}