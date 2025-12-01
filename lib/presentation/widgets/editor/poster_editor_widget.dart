import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../presentation/controllers/poster_controller.dart';
import '../../../presentation/controllers/layer_controller.dart';
import '../../../presentation/controllers/selection_controller.dart';
import '../../../presentation/controllers/history_controller.dart';
import '../../../presentation/controllers/tool_controller.dart';
import '../../../presentation/controllers/ui_controller.dart';
import '../../../presentation/bindings/editor_binding.dart';
import 'editor_scaffold.dart';

/// Main Poster Editor Widget
/// This is the entry point for the poster editor
class PosterEditorWidget extends StatefulWidget {
  /// Initial JSON to load (optional)
  final String? initialJson;

  /// Callback when document is saved
  final void Function(String json)? onSave;

  /// Callback when export is requested
  final void Function(String format, dynamic data)? onExport;

  /// Whether to show the toolbar
  final bool showToolbar;

  /// Whether to show the layers sidebar
  final bool showLayersSidebar;

  /// Whether to show the assets sidebar
  final bool showAssetsSidebar;

  const PosterEditorWidget({
    super.key,
    this.initialJson,
    this.onSave,
    this.onExport,
    this.showToolbar = true,
    this.showLayersSidebar = true,
    this.showAssetsSidebar = true,
  });

  @override
  State<PosterEditorWidget> createState() => _PosterEditorWidgetState();
}

class _PosterEditorWidgetState extends State<PosterEditorWidget> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();

    // Initialize dependencies if not already done
    if (!Get.isRegistered<PosterController>()) {
      EditorBinding().dependencies();
    }

    // Load initial document if provided
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialJson != null) {
        _loadInitialDocument();
      } else {
        _createNewDocument();
      }
    });
  }

  void _loadInitialDocument() async {
    final posterController = Get.find<PosterController>();
    final layerController = Get.find<LayerController>();

    final success = await posterController.loadFromJson(widget.initialJson!);
    if (success && posterController.document != null) {
      layerController.loadFromDocument(posterController.document!.layers);
    }
  }

  void _createNewDocument() {
    final posterController = Get.find<PosterController>();
    posterController.createNew(
      name: 'New Poster',
      width: 1080,
      height: 1920,
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: EditorScaffold(
        showToolbar: widget.showToolbar,
        showLayersSidebar: widget.showLayersSidebar,
        showAssetsSidebar: widget.showAssetsSidebar,
        onSave: widget.onSave,
        onExport: widget.onExport,
      ),
    );
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final historyController = Get.find<HistoryController>();
    final selectionController = Get.find<SelectionController>();
    final toolController = Get.find<ToolController>();
    final layerController = Get.find<LayerController>();

    // Check for modifier keys
    final isCtrlOrCmd = HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed;
    final isShift = HardwareKeyboard.instance.isShiftPressed;

    // Update shift state for selection
    selectionController.setShiftHeld(isShift);

    // Ctrl/Cmd shortcuts
    if (isCtrlOrCmd) {
      switch (event.logicalKey) {
      // Undo
        case LogicalKeyboardKey.keyZ:
          if (isShift) {
            historyController.redo();
          } else {
            historyController.undo();
          }
          return KeyEventResult.handled;

      // Redo (Ctrl+Y)
        case LogicalKeyboardKey.keyY:
          historyController.redo();
          return KeyEventResult.handled;

      // Save
        case LogicalKeyboardKey.keyS:
          _handleSave();
          return KeyEventResult.handled;

      // Select All
        case LogicalKeyboardKey.keyA:
          selectionController.selectAll();
          return KeyEventResult.handled;

      // Copy
        case LogicalKeyboardKey.keyC:
          _handleCopy();
          return KeyEventResult.handled;

      // Paste
        case LogicalKeyboardKey.keyV:
          _handlePaste();
          return KeyEventResult.handled;

      // Duplicate
        case LogicalKeyboardKey.keyD:
          _handleDuplicate();
          return KeyEventResult.handled;
      }
    }

    // Non-modifier shortcuts
    switch (event.logicalKey) {
    // Delete selected layers
      case LogicalKeyboardKey.delete:
      case LogicalKeyboardKey.backspace:
        _handleDelete();
        return KeyEventResult.handled;

    // Escape - clear selection or cancel operation
      case LogicalKeyboardKey.escape:
        selectionController.clearSelection();
        toolController.resetTool();
        return KeyEventResult.handled;

    // Space - temporary pan mode
      case LogicalKeyboardKey.space:
        toolController.enterTemporaryPanMode();
        return KeyEventResult.handled;

    // Tool shortcuts
      case LogicalKeyboardKey.keyV:
        toolController.selectTool(EditorTool.select);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.keyT:
        toolController.selectTool(EditorTool.text);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.keyI:
        toolController.selectTool(EditorTool.image);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.keyS:
        toolController.selectTool(EditorTool.svg);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.keyU:
        toolController.selectTool(EditorTool.shape);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.keyH:
        toolController.selectTool(EditorTool.hand);
        return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _handleSave() async {
    final posterController = Get.find<PosterController>();
    final json = await posterController.saveToJson();
    if (json != null && widget.onSave != null) {
      widget.onSave!(json);
    }
  }

  void _handleCopy() {
    // TODO: Implement copy functionality
  }

  void _handlePaste() {
    // TODO: Implement paste functionality
  }

  void _handleDuplicate() {
    final selectionController = Get.find<SelectionController>();
    final layerController = Get.find<LayerController>();

    for (final layerId in selectionController.selectedIds) {
      layerController.duplicateLayer(layerId);
    }
  }

  void _handleDelete() {
    final selectionController = Get.find<SelectionController>();
    final layerController = Get.find<LayerController>();

    final idsToDelete = selectionController.selectedIds.toList();
    selectionController.clearSelection();
    layerController.removeLayers(idsToDelete);
  }
}