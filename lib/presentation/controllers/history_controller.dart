import 'package:get/get.dart';

import '../../core/types/typedefs.dart';
import '../../data/models/history/editor_command.dart';
import '../../domain/services/undo_redo_service.dart';

/// Controller for undo/redo functionality
class HistoryController extends GetxController {
  final UndoRedoService _undoRedoService;

  HistoryController({required UndoRedoService undoRedoService})
      : _undoRedoService = undoRedoService;

  // ==================== Reactive State ====================

  /// Whether can undo
  final RxBool canUndo = false.obs;

  /// Whether can redo
  final RxBool canRedo = false.obs;

  /// Undo action name
  final RxString undoActionName = ''.obs;

  /// Redo action name
  final RxString redoActionName = ''.obs;

  /// History length
  final RxInt historyLength = 0.obs;

  /// Is currently batching
  final RxBool isBatching = false.obs;

  // ==================== Initialization ====================

  @override
  void onInit() {
    super.onInit();
    _updateState();
  }

  // ==================== Public API ====================

  /// Execute and record a command
  void execute(EditorCommand command) {
    _undoRedoService.push(command);
    _updateState();
  }

  /// Record a command that was already executed
  void record(EditorCommand command) {
    _undoRedoService.pushExecuted(command);
    _updateState();
  }

  /// Undo last action
  bool undo() {
    if (!canUndo.value) return false;

    final success = _undoRedoService.undo();
    _updateState();
    return success;
  }

  /// Redo last undone action
  bool redo() {
    if (!canRedo.value) return false;

    final success = _undoRedoService.redo();
    _updateState();
    return success;
  }

  /// Clear all history
  void clear() {
    _undoRedoService.clear();
    _updateState();
  }

  // ==================== Batching ====================

  /// Begin batch operation
  void beginBatch(String name) {
    _undoRedoService.beginBatch(name);
    isBatching.value = true;
  }

  /// End batch operation
  void endBatch() {
    _undoRedoService.endBatch();
    isBatching.value = false;
    _updateState();
  }

  /// Cancel batch operation
  void cancelBatch() {
    _undoRedoService.cancelBatch();
    isBatching.value = false;
    _updateState();
  }

  /// Execute multiple commands as a single batch
  void executeBatch(String name, List<EditorCommand> commands) {
    _undoRedoService.executeAsBatch(name, commands);
    _updateState();
  }

  // ==================== Convenience Methods ====================

  /// Record a layer property change
  void recordLayerChange({
    required String layerId,
    required String propertyName,
    required dynamic oldValue,
    required dynamic newValue,
    required void Function(String, String, dynamic) applyChange,
  }) {
    final command = LayerPropertyCommand(
      layerId: layerId,
      propertyName: propertyName,
      oldValue: oldValue,
      newValue: newValue,
      applyChange: applyChange,
    );
    record(command);
  }

  /// Record layer addition
  void recordLayerAdd({
    required JsonMap layerJson,
    required int index,
    required void Function(JsonMap, int) addLayer,
    required void Function(String) removeLayer,
  }) {
    final command = AddLayerCommand(
      layerJson: layerJson,
      index: index,
      addLayer: addLayer,
      removeLayer: removeLayer,
    );
    record(command);
  }

  /// Record layer removal
  void recordLayerRemove({
    required String layerId,
    required JsonMap layerJson,
    required int index,
    required void Function(String) removeLayer,
    required void Function(JsonMap, int) addLayer,
  }) {
    final command = RemoveLayerCommand(
      layerId: layerId,
      layerJson: layerJson,
      index: index,
      removeLayer: removeLayer,
      addLayer: addLayer,
    );
    record(command);
  }

  /// Record layer reorder
  void recordLayerReorder({
    required int oldIndex,
    required int newIndex,
    required void Function(int, int) reorderLayer,
  }) {
    final command = ReorderLayerCommand(
      oldIndex: oldIndex,
      newIndex: newIndex,
      reorderLayer: reorderLayer,
    );
    record(command);
  }

  /// Record transform change
  void recordTransformChange({
    required String layerId,
    required JsonMap oldTransform,
    required JsonMap newTransform,
    required void Function(String, JsonMap) applyTransform,
  }) {
    final command = TransformCommand(
      layerId: layerId,
      oldTransform: oldTransform,
      newTransform: newTransform,
      applyTransform: applyTransform,
    );
    record(command);
  }

  // ==================== State Update ====================

  void _updateState() {
    canUndo.value = _undoRedoService.canUndo;
    canRedo.value = _undoRedoService.canRedo;
    undoActionName.value = _undoRedoService.undoActionName ?? '';
    redoActionName.value = _undoRedoService.redoActionName ?? '';
    historyLength.value = _undoRedoService.historyLength;
    isBatching.value = _undoRedoService.isBatching;
  }

  @override
  void onClose() {
    clear();
    super.onClose();
  }
}