import 'dart:ui' show Offset;

import 'package:get/get.dart';

import '../../data/models/shapes/shape_type.dart';

/// Available editor tools
enum EditorTool {
  select,
  text,
  image,
  svg,
  shape,
  hand, // Pan tool
}

/// Extension for EditorTool
extension EditorToolExtension on EditorTool {
  /// Get display name
  String get displayName {
    switch (this) {
      case EditorTool.select:
        return 'Select';
      case EditorTool.text:
        return 'Text';
      case EditorTool.image:
        return 'Image';
      case EditorTool.svg:
        return 'Sticker';
      case EditorTool.shape:
        return 'Shape';
      case EditorTool.hand:
        return 'Pan';
    }
  }

  /// Get keyboard shortcut
  String get shortcut {
    switch (this) {
      case EditorTool.select:
        return 'V';
      case EditorTool.text:
        return 'T';
      case EditorTool.image:
        return 'I';
      case EditorTool.svg:
        return 'S';
      case EditorTool.shape:
        return 'U';
      case EditorTool.hand:
        return 'H';
    }
  }
}

/// Controller for active tool state
class ToolController extends GetxController {
  // ==================== Reactive State ====================

  /// Currently active tool
  final Rx<EditorTool> activeTool = EditorTool.select.obs;

  /// Previously active tool (for temporary tool switch)
  final Rx<EditorTool?> previousTool = Rx<EditorTool?>(null);

  /// Selected shape type (when shape tool is active)
  final Rx<ShapeType> selectedShapeType = ShapeType.rectangle.obs;

  /// Whether pan mode is temporarily active (space bar held)
  final RxBool isTemporaryPanMode = false.obs;

  // ==================== Getters ====================

  /// Check if select tool is active
  bool get isSelectTool => activeTool.value == EditorTool.select;

  /// Check if text tool is active
  bool get isTextTool => activeTool.value == EditorTool.text;

  /// Check if image tool is active
  bool get isImageTool => activeTool.value == EditorTool.image;

  /// Check if SVG tool is active
  bool get isSvgTool => activeTool.value == EditorTool.svg;

  /// Check if shape tool is active
  bool get isShapeTool => activeTool.value == EditorTool.shape;

  /// Check if hand/pan tool is active
  bool get isHandTool => activeTool.value == EditorTool.hand || isTemporaryPanMode.value;

  /// Check if any creation tool is active
  bool get isCreationTool {
    return isTextTool || isImageTool || isSvgTool || isShapeTool;
  }

  // ==================== Tool Selection ====================

  /// Select a tool
  void selectTool(EditorTool tool) {
    if (activeTool.value != tool) {
      previousTool.value = activeTool.value;
      activeTool.value = tool;
    }
  }

  /// Select tool by shortcut key
  void selectToolByShortcut(String key) {
    final upperKey = key.toUpperCase();
    for (final tool in EditorTool.values) {
      if (tool.shortcut == upperKey) {
        selectTool(tool);
        break;
      }
    }
  }

  /// Revert to previous tool
  void revertToPreviousTool() {
    if (previousTool.value != null) {
      activeTool.value = previousTool.value!;
      previousTool.value = null;
    }
  }

  /// Reset to select tool
  void resetTool() {
    selectTool(EditorTool.select);
  }

  // ==================== Shape Tool ====================

  /// Select shape type
  void selectShapeType(ShapeType type) {
    selectedShapeType.value = type;
    if (activeTool.value != EditorTool.shape) {
      selectTool(EditorTool.shape);
    }
  }

  // ==================== Temporary Pan Mode ====================

  /// Enter temporary pan mode (space bar held)
  void enterTemporaryPanMode() {
    if (!isTemporaryPanMode.value) {
      isTemporaryPanMode.value = true;
    }
  }

  /// Exit temporary pan mode
  void exitTemporaryPanMode() {
    if (isTemporaryPanMode.value) {
      isTemporaryPanMode.value = false;
    }
  }

  // ==================== Tool Actions ====================

  /// Called when user clicks on canvas with current tool
  void onCanvasTap(Offset position) {
    // Tool-specific actions would be handled here
    // or delegated to appropriate controllers
  }

  /// Called when user starts dragging on canvas
  void onCanvasDragStart(Offset position) {
    // Tool-specific actions
  }

  /// Called when user continues dragging on canvas
  void onCanvasDragUpdate(Offset position) {
    // Tool-specific actions
  }

  /// Called when user ends dragging on canvas
  void onCanvasDragEnd() {
    // Tool-specific actions
  }

  @override
  void onClose() {
    resetTool();
    super.onClose();
  }
}