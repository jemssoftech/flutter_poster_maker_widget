import 'dart:ui' show Offset, Rect;

import 'package:get/get.dart';

import '../../data/models/layers/layer_base.dart';
import '../../data/models/selection/selection_state.dart';
import 'layer_controller.dart';

/// Controller for selection state
class SelectionController extends GetxController {
  // ==================== Reactive State ====================

  /// Current selection state
  final Rx<SelectionState> _state = Rx<SelectionState>(const SelectionState());

  /// Whether shift key is held
  final RxBool isShiftHeld = false.obs;

  /// Whether selection is active
  final RxBool isActive = false.obs;

  // ==================== Getters ====================

  /// Get current state
  SelectionState get state => _state.value;

  /// Get selected layer IDs
  Set<String> get selectedIds => _state.value.selectedIds;

  /// Get primary selection ID
  String? get primaryId => _state.value.primaryId;

  /// Check if anything is selected
  bool get hasSelection => _state.value.hasSelection;

  /// Check if single item is selected
  bool get hasSingleSelection => _state.value.hasSingleSelection;

  /// Check if multiple items are selected
  bool get hasMultiSelection => _state.value.hasMultiSelection;

  /// Get selection count
  int get selectionCount => _state.value.selectionCount;

  /// Check if a specific layer is selected
  bool isSelected(String layerId) => _state.value.isSelected(layerId);

  /// Check if layer is primary selection
  bool isPrimary(String layerId) => _state.value.isPrimary(layerId);

  /// Get selected layers from LayerController
  List<LayerBase> get selectedLayers {
    if (!Get.isRegistered<LayerController>()) return [];

    final layerController = Get.find<LayerController>();
    return selectedIds
        .map((id) => layerController.getLayerById(id))
        .whereType<LayerBase>()
        .toList();
  }

  /// Get primary selected layer
  LayerBase? get primaryLayer {
    if (primaryId == null) return null;
    if (!Get.isRegistered<LayerController>()) return null;

    return Get.find<LayerController>().getLayerById(primaryId!);
  }

  // ==================== Selection Operations ====================

  /// Select a single layer (clears previous selection)
  void select(String layerId) {
    _state.value = _state.value.select(layerId);
    isActive.value = true;
  }

  /// Add layer to current selection
  void addToSelection(String layerId) {
    _state.value = _state.value.addToSelection(layerId);
  }

  /// Remove layer from selection
  void removeFromSelection(String layerId) {
    _state.value = _state.value.removeFromSelection(layerId);
    if (!hasSelection) {
      isActive.value = false;
    }
  }

  /// Toggle layer selection
  void toggleSelection(String layerId) {
    _state.value = _state.value.toggleSelection(layerId);
    isActive.value = hasSelection;
  }

  /// Select layer with shift-awareness
  void selectWithModifier(String layerId, {bool additive = false}) {
    if (additive || isShiftHeld.value) {
      toggleSelection(layerId);
    } else {
      select(layerId);
    }
  }

  /// Select multiple layers
  void selectMultiple(List<String> layerIds) {
    _state.value = SelectionState(
      selectedIds: Set<String>.from(layerIds),
      primaryId: layerIds.isNotEmpty ? layerIds.last : null,
    );
    isActive.value = layerIds.isNotEmpty;
  }

  /// Select all editable layers
  void selectAll() {
    if (!Get.isRegistered<LayerController>()) return;

    final layerController = Get.find<LayerController>();
    final editableIds = layerController.editableLayers.map((l) => l.id).toList();
    selectMultiple(editableIds);
  }

  /// Clear all selection
  void clearSelection() {
    _state.value = const SelectionState();
    isActive.value = false;
  }

  /// Set primary selection (without changing selection set)
  void setPrimary(String layerId) {
    if (!isSelected(layerId)) return;

    _state.value = _state.value.copyWith(primaryId: layerId);
  }

  // ==================== Rectangle Selection ====================

  /// Start rectangle selection
  void startRectSelection(Offset start) {
    _state.value = _state.value.startSelectionRect(start);
  }

  /// Update rectangle selection
  void updateRectSelection(Offset current) {
    _state.value = _state.value.updateSelectionRect(current);
  }

  /// Finish rectangle selection
  void finishRectSelection(List<String> layerIdsInRect) {
    _state.value = _state.value.finishSelectionRect();

    if (layerIdsInRect.isNotEmpty) {
      if (isShiftHeld.value) {
        // Add to existing selection
        final newIds = Set<String>.from(selectedIds)..addAll(layerIdsInRect);
        selectMultiple(newIds.toList());
      } else {
        // Replace selection
        selectMultiple(layerIdsInRect);
      }
    }
  }

  /// Get selection rectangle
  Rect? get selectionRect => _state.value.selectionRect;

  /// Check if drawing selection rect
  bool get isDrawingSelectionRect => _state.value.isDrawingSelectionRect;

  // ==================== Modifier Keys ====================

  /// Set shift key state
  void setShiftHeld(bool held) {
    isShiftHeld.value = held;
    _state.value = _state.value.copyWith(isShiftHeld: held);
  }

  // ==================== Cleanup ====================

  /// Handle layer deletion
  void onLayerDeleted(String layerId) {
    if (isSelected(layerId)) {
      removeFromSelection(layerId);
    }
  }

  /// Handle multiple layers deleted
  void onLayersDeleted(List<String> layerIds) {
    for (final id in layerIds) {
      onLayerDeleted(id);
    }
  }

  @override
  void onClose() {
    clearSelection();
    super.onClose();
  }
}