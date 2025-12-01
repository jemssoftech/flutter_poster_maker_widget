import 'package:flutter/material.dart';
import '../../../core/types/typedefs.dart';
import '../layers/layer_base.dart';

/// Handle position for transform handles
enum HandlePosition {
  topLeft,
  topCenter,
  topRight,
  centerLeft,
  centerRight,
  bottomLeft,
  bottomCenter,
  bottomRight,
  rotation,
}

/// Extension for HandlePosition
extension HandlePositionExtension on HandlePosition {
  /// Check if this is a corner handle
  bool get isCorner {
    return this == HandlePosition.topLeft ||
        this == HandlePosition.topRight ||
        this == HandlePosition.bottomLeft ||
        this == HandlePosition.bottomRight;
  }

  /// Check if this is an edge handle
  bool get isEdge {
    return this == HandlePosition.topCenter ||
        this == HandlePosition.bottomCenter ||
        this == HandlePosition.centerLeft ||
        this == HandlePosition.centerRight;
  }

  /// Check if this affects width
  bool get affectsWidth {
    return this == HandlePosition.topLeft ||
        this == HandlePosition.topRight ||
        this == HandlePosition.bottomLeft ||
        this == HandlePosition.bottomRight ||
        this == HandlePosition.centerLeft ||
        this == HandlePosition.centerRight;
  }

  /// Check if this affects height
  bool get affectsHeight {
    return this == HandlePosition.topLeft ||
        this == HandlePosition.topRight ||
        this == HandlePosition.bottomLeft ||
        this == HandlePosition.bottomRight ||
        this == HandlePosition.topCenter ||
        this == HandlePosition.bottomCenter;
  }

  /// Get cursor for this handle
  MouseCursor get cursor {
    switch (this) {
      case HandlePosition.topLeft:
      case HandlePosition.bottomRight:
        return SystemMouseCursors.resizeUpLeftDownRight;
      case HandlePosition.topRight:
      case HandlePosition.bottomLeft:
        return SystemMouseCursors.resizeUpRightDownLeft;
      case HandlePosition.topCenter:
      case HandlePosition.bottomCenter:
        return SystemMouseCursors.resizeUpDown;
      case HandlePosition.centerLeft:
      case HandlePosition.centerRight:
        return SystemMouseCursors.resizeLeftRight;
      case HandlePosition.rotation:
        return SystemMouseCursors.click;
    }
  }

  /// Get position offset (0-1) relative to bounds
  Offset get relativePosition {
    switch (this) {
      case HandlePosition.topLeft:
        return const Offset(0, 0);
      case HandlePosition.topCenter:
        return const Offset(0.5, 0);
      case HandlePosition.topRight:
        return const Offset(1, 0);
      case HandlePosition.centerLeft:
        return const Offset(0, 0.5);
      case HandlePosition.centerRight:
        return const Offset(1, 0.5);
      case HandlePosition.bottomLeft:
        return const Offset(0, 1);
      case HandlePosition.bottomCenter:
        return const Offset(0.5, 1);
      case HandlePosition.bottomRight:
        return const Offset(1, 1);
      case HandlePosition.rotation:
        return const Offset(0.5, -0.2); // Above top center
    }
  }
}

/// Transform mode
enum TransformMode {
  none,
  move,
  resize,
  rotate,
}

/// Current selection state
class SelectionState {
  /// Set of selected layer IDs
  final Set<String> selectedIds;

  /// Primary selected layer (for property editing)
  final String? primaryId;

  /// Current transform mode
  final TransformMode transformMode;

  /// Active handle during transform
  final HandlePosition? activeHandle;

  /// Selection rectangle during drag selection
  final Rect? selectionRect;

  /// Whether shift key is held (for additive selection)
  final bool isShiftHeld;

  const SelectionState({
    this.selectedIds = const {},
    this.primaryId,
    this.transformMode = TransformMode.none,
    this.activeHandle,
    this.selectionRect,
    this.isShiftHeld = false,
  });

  /// Empty selection
  static const SelectionState empty = SelectionState();

  /// Check if anything is selected
  bool get hasSelection => selectedIds.isNotEmpty;

  /// Check if single item is selected
  bool get hasSingleSelection => selectedIds.length == 1;

  /// Check if multiple items are selected
  bool get hasMultiSelection => selectedIds.length > 1;

  /// Get number of selected items
  int get selectionCount => selectedIds.length;

  /// Check if a specific layer is selected
  bool isSelected(String layerId) => selectedIds.contains(layerId);

  /// Check if layer is primary selection
  bool isPrimary(String layerId) => primaryId == layerId;

  /// Check if currently transforming
  bool get isTransforming => transformMode != TransformMode.none;

  /// Check if currently drawing selection rect
  bool get isDrawingSelectionRect => selectionRect != null;

  /// Create copy with modifications
  SelectionState copyWith({
    Set<String>? selectedIds,
    String? primaryId,
    TransformMode? transformMode,
    HandlePosition? activeHandle,
    Rect? selectionRect,
    bool? isShiftHeld,
    bool clearPrimaryId = false,
    bool clearActiveHandle = false,
    bool clearSelectionRect = false,
  }) {
    return SelectionState(
      selectedIds: selectedIds ?? this.selectedIds,
      primaryId: clearPrimaryId ? null : (primaryId ?? this.primaryId),
      transformMode: transformMode ?? this.transformMode,
      activeHandle: clearActiveHandle ? null : (activeHandle ?? this.activeHandle),
      selectionRect: clearSelectionRect ? null : (selectionRect ?? this.selectionRect),
      isShiftHeld: isShiftHeld ?? this.isShiftHeld,
    );
  }

  /// Select a single layer
  SelectionState select(String layerId) {
    return copyWith(
      selectedIds: {layerId},
      primaryId: layerId,
      clearSelectionRect: true,
    );
  }

  /// Add layer to selection
  SelectionState addToSelection(String layerId) {
    final newIds = Set<String>.from(selectedIds)..add(layerId);
    return copyWith(
      selectedIds: newIds,
      primaryId: layerId,
    );
  }

  /// Remove layer from selection
  SelectionState removeFromSelection(String layerId) {
    final newIds = Set<String>.from(selectedIds)..remove(layerId);
    return copyWith(
      selectedIds: newIds,
      primaryId: newIds.isNotEmpty ? newIds.first : null,
      clearPrimaryId: newIds.isEmpty,
    );
  }

  /// Toggle layer selection
  SelectionState toggleSelection(String layerId) {
    if (isSelected(layerId)) {
      return removeFromSelection(layerId);
    } else {
      return addToSelection(layerId);
    }
  }

  /// Clear all selection
  SelectionState clear() {
    return const SelectionState();
  }

  /// Start transform
  SelectionState startTransform(TransformMode mode, [HandlePosition? handle]) {
    return copyWith(
      transformMode: mode,
      activeHandle: handle,
    );
  }

  /// End transform
  SelectionState endTransform() {
    return copyWith(
      transformMode: TransformMode.none,
      clearActiveHandle: true,
    );
  }

  /// Start selection rect
  SelectionState startSelectionRect(Offset start) {
    return copyWith(
      selectionRect: Rect.fromPoints(start, start),
    );
  }

  /// Update selection rect
  SelectionState updateSelectionRect(Offset current) {
    if (selectionRect == null) return this;
    return copyWith(
      selectionRect: Rect.fromPoints(selectionRect!.topLeft, current),
    );
  }

  /// Finish selection rect
  SelectionState finishSelectionRect() {
    return copyWith(clearSelectionRect: true);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SelectionState &&
        other.selectedIds.length == selectedIds.length &&
        other.selectedIds.containsAll(selectedIds) &&
        other.primaryId == primaryId &&
        other.transformMode == transformMode;
  }

  @override
  int get hashCode => Object.hash(
    selectedIds.length,
    primaryId,
    transformMode,
  );

  @override
  String toString() => 'SelectionState(${selectedIds.length} selected, primary: $primaryId)';
}