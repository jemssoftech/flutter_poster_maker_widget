import 'package:get/get.dart';

import '../../core/utils/id_generator.dart';
import '../../core/constants/editor_constants.dart';
import '../../data/models/layers/layer_base.dart';
import '../../data/models/layers/image_layer.dart';
import '../../data/models/layers/text_layer.dart';
import '../../data/models/layers/svg_layer.dart';
import '../../data/models/layers/shape_layer.dart';
import '../../data/models/transform/layer_transform.dart';
import '../../data/models/shapes/shape_type.dart';
import 'poster_controller.dart';

/// Controller for layer management
class LayerController extends GetxController {
  // ==================== Reactive State ====================

  /// All layers (ordered bottom to top)
  final RxList<LayerBase> layers = <LayerBase>[].obs;

  // ==================== Getters ====================

  /// Number of layers
  int get layerCount => layers.length;

  /// Check if there are any layers
  bool get hasLayers => layers.isNotEmpty;

  /// Get visible layers
  List<LayerBase> get visibleLayers =>
      layers.where((l) => l.visible).toList();

  /// Get unlocked layers
  List<LayerBase> get unlockedLayers =>
      layers.where((l) => !l.locked).toList();

  /// Get editable layers (visible and unlocked)
  List<LayerBase> get editableLayers =>
      layers.where((l) => l.isEditable).toList();

  /// Get layers in render order (bottom to top)
  List<LayerBase> get renderOrder => layers.toList();

  /// Get layers in panel order (top to bottom for UI)
  List<LayerBase> get panelOrder => layers.reversed.toList();

  // ==================== Layer Access ====================

  /// Get layer by ID
  LayerBase? getLayerById(String layerId) {
    try {
      return layers.firstWhere((l) => l.id == layerId);
    } catch (_) {
      return null;
    }
  }

  /// Get layer index by ID
  int getLayerIndex(String layerId) {
    return layers.indexWhere((l) => l.id == layerId);
  }

  /// Check if layer exists
  bool hasLayer(String layerId) {
    return layers.any((l) => l.id == layerId);
  }

  // ==================== Layer CRUD ====================

  /// Add layer at specific index (or end if not specified)
  void addLayer(LayerBase layer, {int? index}) {
    if (layers.length >= EditorConstants.maxLayers) {
      return; // Max layers reached
    }

    if (index != null && index >= 0 && index <= layers.length) {
      layers.insert(index, layer);
    } else {
      layers.add(layer);
    }

    _syncToPosterController();
  }

  /// Remove layer by ID
  void removeLayer(String layerId) {
    layers.removeWhere((l) => l.id == layerId);
    _syncToPosterController();
  }

  /// Update layer by ID
  void updateLayer(String layerId, LayerBase Function(LayerBase) updater) {
    final index = getLayerIndex(layerId);
    if (index < 0) return;

    layers[index] = updater(layers[index]);
    _syncToPosterController();
  }

  /// Replace layer by ID
  void replaceLayer(String layerId, LayerBase newLayer) {
    final index = getLayerIndex(layerId);
    if (index < 0) return;

    layers[index] = newLayer;
    _syncToPosterController();
  }

  /// Duplicate layer by ID
  String? duplicateLayer(String layerId) {
    final index = getLayerIndex(layerId);
    if (index < 0) return null;

    final original = layers[index];
    final newId = IdGenerator.layerId(original.type);
    final duplicate = original.copyWith(
      id: newId,
      name: '${original.name} (Copy)',
    );

    layers.insert(index + 1, duplicate);
    _syncToPosterController();

    return newId;
  }

  // ==================== Layer Ordering ====================

  /// Reorder layer from old index to new index
  void reorderLayer(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= layers.length) return;
    if (newIndex < 0 || newIndex >= layers.length) return;
    if (oldIndex == newIndex) return;

    final layer = layers.removeAt(oldIndex);
    layers.insert(newIndex, layer);
    _syncToPosterController();
  }

  /// Bring layer to front (top)
  void bringToFront(String layerId) {
    final index = getLayerIndex(layerId);
    if (index < 0 || index == layers.length - 1) return;

    reorderLayer(index, layers.length - 1);
  }

  /// Send layer to back (bottom)
  void sendToBack(String layerId) {
    final index = getLayerIndex(layerId);
    if (index <= 0) return;

    reorderLayer(index, 0);
  }

  /// Bring layer forward one step
  void bringForward(String layerId) {
    final index = getLayerIndex(layerId);
    if (index < 0 || index == layers.length - 1) return;

    reorderLayer(index, index + 1);
  }

  /// Send layer backward one step
  void sendBackward(String layerId) {
    final index = getLayerIndex(layerId);
    if (index <= 0) return;

    reorderLayer(index, index - 1);
  }

  // ==================== Layer Properties ====================

  /// Toggle layer visibility
  void toggleVisibility(String layerId) {
    updateLayer(layerId, (layer) => layer.copyWith(visible: !layer.visible));
  }

  /// Set layer visibility
  void setVisibility(String layerId, bool visible) {
    updateLayer(layerId, (layer) => layer.copyWith(visible: visible));
  }

  /// Toggle layer lock
  void toggleLock(String layerId) {
    updateLayer(layerId, (layer) => layer.copyWith(locked: !layer.locked));
  }

  /// Set layer lock
  void setLock(String layerId, bool locked) {
    updateLayer(layerId, (layer) => layer.copyWith(locked: locked));
  }

  /// Rename layer
  void renameLayer(String layerId, String name) {
    updateLayer(layerId, (layer) => layer.copyWith(name: name));
  }

  /// Set layer opacity
  void setOpacity(String layerId, double opacity) {
    updateLayer(
      layerId,
          (layer) => layer.copyWith(opacity: opacity.clamp(0.0, 1.0)),
    );
  }

  /// Set layer blend mode
  void setBlendMode(String layerId, LayerBlendMode blendMode) {
    updateLayer(layerId, (layer) => layer.copyWith(blendMode: blendMode));
  }

  // ==================== Layer Transform ====================

  /// Update layer transform
  void updateTransform(String layerId, LayerTransform transform) {
    updateLayer(layerId, (layer) => layer.withTransform(transform));
  }

  // ==================== Layer Factory Methods ====================

  /// Add new text layer
  String addTextLayer({
    String text = 'New Text',
    String? name,
    LayerTransform? transform,
  }) {
    final id = IdGenerator.layerId(LayerTypes.text);
    final layer = TextLayer(
      id: id,
      name: name ?? 'Text',
      text: text,
      transform: transform ?? const LayerTransform(),
    );

    addLayer(layer);
    return id;
  }

  /// Add new image layer
  String addImageLayer({
    required String assetId,
    String? name,
    LayerTransform? transform,
  }) {
    final id = IdGenerator.layerId(LayerTypes.image);
    final layer = ImageLayer(
      id: id,
      name: name ?? 'Image',
      assetId: assetId,
      transform: transform ?? const LayerTransform(),
    );

    addLayer(layer);
    return id;
  }

  /// Add new SVG layer
  String addSvgLayer({
    required String assetId,
    String? name,
    LayerTransform? transform,
  }) {
    final id = IdGenerator.layerId(LayerTypes.svg);
    final layer = SvgLayer(
      id: id,
      name: name ?? 'Sticker',
      assetId: assetId,
      transform: transform ?? const LayerTransform(),
    );

    addLayer(layer);
    return id;
  }

  /// Add new shape layer
  String addShapeLayer({
    required ShapeType shapeType,
    String? name,
    LayerTransform? transform,
  }) {
    final id = IdGenerator.layerId(LayerTypes.shape);

    ShapeLayer layer;
    switch (shapeType) {
      case ShapeType.rectangle:
        layer = ShapeLayer.rectangle(
          id: id,
          name: name ?? 'Rectangle',
          transform: transform ?? const LayerTransform(),
        );
        break;
      case ShapeType.circle:
        layer = ShapeLayer.circle(
          id: id,
          name: name ?? 'Circle',
          transform: transform ?? const LayerTransform(),
        );
        break;
      case ShapeType.line:
        layer = ShapeLayer.line(
          id: id,
          name: name ?? 'Line',
          transform: transform ?? const LayerTransform(),
        );
        break;
      case ShapeType.star:
        layer = ShapeLayer.star(
          id: id,
          name: name ?? 'Star',
          transform: transform ?? const LayerTransform(),
        );
        break;
      case ShapeType.polygon:
        layer = ShapeLayer.polygon(
          id: id,
          name: name ?? 'Polygon',
          transform: transform ?? const LayerTransform(),
        );
        break;
      default:
        layer = ShapeLayer.rectangle(
          id: id,
          name: name ?? 'Shape',
          transform: transform ?? const LayerTransform(),
        );
    }

    addLayer(layer);
    return id;
  }

  // ==================== Bulk Operations ====================

  /// Clear all layers
  void clearAll() {
    layers.clear();
    _syncToPosterController();
  }

  /// Load layers from document
  void loadFromDocument(List<LayerBase> documentLayers) {
    layers.assignAll(documentLayers);
  }

  /// Remove multiple layers
  void removeLayers(List<String> layerIds) {
    layers.removeWhere((l) => layerIds.contains(l.id));
    _syncToPosterController();
  }

  // ==================== Sync ====================

  /// Sync layers to PosterController
  void _syncToPosterController() {
    if (Get.isRegistered<PosterController>()) {
      final posterController = Get.find<PosterController>();
      if (posterController.hasDocument) {
        posterController.updateDocument(
              (doc) => doc.copyWith(layers: layers.toList()),
        );
      }
    }
  }

  @override
  void onClose() {
    layers.clear();
    super.onClose();
  }
}