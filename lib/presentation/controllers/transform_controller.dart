import 'dart:ui' show Offset, Size;

import 'package:get/get.dart';

import '../../data/models/transform/layer_transform.dart';
import '../../data/models/selection/selection_state.dart';
import '../../domain/services/transform_service.dart';
import '../../domain/services/alignment_service.dart';
import 'layer_controller.dart';
import 'selection_controller.dart';
import 'canvas_controller.dart';

/// Controller for transform operations
class TransformController extends GetxController {
  final TransformService _transformService;
  final AlignmentService _alignmentService;

  TransformController({
    required TransformService transformService,
    required AlignmentService alignmentService,
  })  : _transformService = transformService,
        _alignmentService = alignmentService;

  // ==================== Reactive State ====================

  /// Current transform mode
  final Rx<TransformMode> mode = Rx<TransformMode>(TransformMode.none);

  /// Active handle during transform
  final Rx<HandlePosition?> activeHandle = Rx<HandlePosition?>(null);

  /// Whether currently transforming
  final RxBool isTransforming = false.obs;

  /// Preview transform (during drag)
  final Rx<LayerTransform?> previewTransform = Rx<LayerTransform?>(null);

  /// Snap guides to display
  final RxList<SnapGuide> snapGuides = <SnapGuide>[].obs;

  // ==================== Internal State ====================

  /// Layer ID being transformed
  String? _activeLayerId;

  /// Initial transform when operation started
  LayerTransform? _initialTransform;

  /// Drag start position
  Offset? _dragStart;

  /// Initial canvas position at drag start
  Offset? _initialPosition;

  // ==================== Getters ====================

  /// Get active layer ID
  String? get activeLayerId => _activeLayerId;

  /// Check if in move mode
  bool get isMoving => mode.value == TransformMode.move;

  /// Check if in resize mode
  bool get isResizing => mode.value == TransformMode.resize;

  /// Check if in rotate mode
  bool get isRotating => mode.value == TransformMode.rotate;

  // ==================== Move Operations ====================

  /// Start move operation
  void startMove(String layerId, Offset position) {
    final layerController = Get.find<LayerController>();
    final layer = layerController.getLayerById(layerId);
    if (layer == null || layer.locked) return;

    _activeLayerId = layerId;
    _initialTransform = layer.transform;
    _dragStart = position;

    mode.value = TransformMode.move;
    isTransforming.value = true;
  }

  /// Update move operation
  void updateMove(Offset position) {
    if (!isMoving || _activeLayerId == null || _initialTransform == null) return;

    final canvasController = Get.find<CanvasController>();
    final canvasSize = canvasController.canvasSize;

    // Calculate delta in canvas coordinates
    final delta = position - _dragStart!;

    // Calculate new transform
    var newTransform = _transformService.calculateMove(
      current: _initialTransform!,
      delta: delta,
      canvasSize: canvasSize,
    );

    // Apply snapping
    final layerController = Get.find<LayerController>();
    final otherBounds = layerController.layers
        .where((l) => l.id != _activeLayerId)
        .map((l) => _transformService.calculateBounds(
      transform: l.transform,
      canvasSize: canvasSize,
    ))
        .toList();

    final layerSize = Size(
      (newTransform.width ?? 0.5) * canvasSize.width,
      (newTransform.height ?? 0.5) * canvasSize.height,
    );

    final snapResult = _alignmentService.calculateSnap(
      position: Offset(
        newTransform.x * canvasSize.width,
        newTransform.y * canvasSize.height,
      ),
      layerSize: layerSize,
      canvasSize: canvasSize,
      otherLayerBounds: otherBounds,
    );

    if (snapResult.didSnap) {
      newTransform = newTransform.copyWith(
        x: snapResult.position.dx / canvasSize.width,
        y: snapResult.position.dy / canvasSize.height,
      );
      snapGuides.assignAll(snapResult.guides);
    } else {
      snapGuides.clear();
    }

    previewTransform.value = newTransform;
  }

  /// End move operation
  void endMove() {
    if (!isMoving || _activeLayerId == null) {
      _resetState();
      return;
    }

    if (previewTransform.value != null) {
      final layerController = Get.find<LayerController>();
      layerController.updateTransform(_activeLayerId!, previewTransform.value!);
    }

    _resetState();
  }

  // ==================== Resize Operations ====================

  /// Start resize operation
  void startResize(String layerId, HandlePosition handle, Offset position) {
    final layerController = Get.find<LayerController>();
    final layer = layerController.getLayerById(layerId);
    if (layer == null || layer.locked) return;

    _activeLayerId = layerId;
    _initialTransform = layer.transform;
    _dragStart = position;
    activeHandle.value = handle;

    mode.value = TransformMode.resize;
    isTransforming.value = true;
  }

  /// Update resize operation
  void updateResize(Offset position, {bool maintainAspectRatio = true}) {
    if (!isResizing || _activeLayerId == null || _initialTransform == null) return;
    if (activeHandle.value == null) return;

    final canvasController = Get.find<CanvasController>();
    final canvasSize = canvasController.canvasSize;
    final delta = position - _dragStart!;

    final newTransform = _transformService.calculateResize(
      current: _initialTransform!,
      handle: activeHandle.value!,
      delta: delta,
      canvasSize: canvasSize,
      originalSize: Size(
        (_initialTransform!.width ?? 0.5) * canvasSize.width,
        (_initialTransform!.height ?? 0.5) * canvasSize.height,
      ),
      maintainAspectRatio: maintainAspectRatio,
    );

    previewTransform.value = newTransform;
  }

  /// End resize operation
  void endResize() {
    if (!isResizing || _activeLayerId == null) {
      _resetState();
      return;
    }

    if (previewTransform.value != null) {
      final layerController = Get.find<LayerController>();
      layerController.updateTransform(_activeLayerId!, previewTransform.value!);
    }

    _resetState();
  }

  // ==================== Rotate Operations ====================

  /// Start rotate operation
  void startRotate(String layerId, Offset position) {
    final layerController = Get.find<LayerController>();
    final layer = layerController.getLayerById(layerId);
    if (layer == null || layer.locked) return;

    _activeLayerId = layerId;
    _initialTransform = layer.transform;
    _dragStart = position;

    // Calculate layer center for rotation
    final canvasController = Get.find<CanvasController>();
    final canvasSize = canvasController.canvasSize;
    _initialPosition = Offset(
      layer.transform.x * canvasSize.width,
      layer.transform.y * canvasSize.height,
    );

    mode.value = TransformMode.rotate;
    isTransforming.value = true;
    activeHandle.value = HandlePosition.rotation;
  }

  /// Update rotate operation
  void updateRotate(Offset position, {bool snap = false}) {
    if (!isRotating || _activeLayerId == null || _initialTransform == null) return;
    if (_initialPosition == null) return;

    final newTransform = _transformService.calculateRotation(
      current: _initialTransform!,
      center: _initialPosition!,
      startPosition: _dragStart!,
      currentPosition: position,
      snapToAngles: snap,
    );

    previewTransform.value = newTransform;
  }

  /// End rotate operation
  void endRotate() {
    if (!isRotating || _activeLayerId == null) {
      _resetState();
      return;
    }

    if (previewTransform.value != null) {
      final layerController = Get.find<LayerController>();
      layerController.updateTransform(_activeLayerId!, previewTransform.value!);
    }

    _resetState();
  }

  // ==================== Common Operations ====================

  /// Cancel current transform operation
  void cancelTransform() {
    _resetState();
  }

  /// Apply preview transform immediately
  void applyTransform() {
    if (_activeLayerId == null || previewTransform.value == null) return;

    final layerController = Get.find<LayerController>();
    layerController.updateTransform(_activeLayerId!, previewTransform.value!);

    _resetState();
  }

  /// Reset internal state
  void _resetState() {
    _activeLayerId = null;
    _initialTransform = null;
    _dragStart = null;
    _initialPosition = null;

    mode.value = TransformMode.none;
    activeHandle.value = null;
    isTransforming.value = false;
    previewTransform.value = null;
    snapGuides.clear();
  }

  // ==================== Quick Transforms ====================

  /// Flip layer horizontally
  void flipHorizontal(String layerId) {
    final layerController = Get.find<LayerController>();
    layerController.updateLayer(layerId, (layer) {
      return layer.withTransform(
        layer.transform.copyWith(
          flipHorizontal: !layer.transform.flipHorizontal,
        ),
      );
    });
  }

  /// Flip layer vertically
  void flipVertical(String layerId) {
    final layerController = Get.find<LayerController>();
    layerController.updateLayer(layerId, (layer) {
      return layer.withTransform(
        layer.transform.copyWith(
          flipVertical: !layer.transform.flipVertical,
        ),
      );
    });
  }

  /// Reset layer rotation
  void resetRotation(String layerId) {
    final layerController = Get.find<LayerController>();
    layerController.updateLayer(layerId, (layer) {
      return layer.withTransform(
        layer.transform.copyWith(rotation: 0),
      );
    });
  }

  /// Reset layer scale
  void resetScale(String layerId) {
    final layerController = Get.find<LayerController>();
    layerController.updateLayer(layerId, (layer) {
      return layer.withTransform(
        layer.transform.copyWith(scaleX: 1.0, scaleY: 1.0),
      );
    });
  }

  @override
  void onClose() {
    _resetState();
    super.onClose();
  }
}