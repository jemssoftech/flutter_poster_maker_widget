import 'package:flutter/material.dart';
import '../../../core/types/typedefs.dart';
import '../layers/layer_base.dart';
import '../transform/layer_transform.dart';

/// Represents a multi-selection of layers with combined bounds
class MultiSelection {
  /// Selected layer IDs
  final List<String> layerIds;

  /// Combined bounding box of all selected layers
  final Rect? combinedBounds;

  /// Center point of combined bounds
  final Offset? center;

  /// Initial transforms at start of group operation
  final Map<String, LayerTransform> initialTransforms;

  const MultiSelection({
    this.layerIds = const [],
    this.combinedBounds,
    this.center,
    this.initialTransforms = const {},
  });

  /// Empty multi-selection
  static const MultiSelection empty = MultiSelection();

  /// Check if selection is empty
  bool get isEmpty => layerIds.isEmpty;

  /// Check if selection has items
  bool get isNotEmpty => layerIds.isNotEmpty;

  /// Get selection count
  int get count => layerIds.length;

  /// Check if layer is in selection
  bool contains(String layerId) => layerIds.contains(layerId);

  /// Create from list of layers
  factory MultiSelection.fromLayers(
      List<LayerBase> layers,
      Size posterSize,
      ) {
    if (layers.isEmpty) return MultiSelection.empty;

    final layerIds = layers.map((l) => l.id).toList();
    final initialTransforms = <String, LayerTransform>{};

    Rect? combined;

    for (final layer in layers) {
      initialTransforms[layer.id] = layer.transform;

      final bounds = layer.transform.bounds(posterSize);
      if (bounds != null) {
        combined = combined?.expandToInclude(bounds) ?? bounds;
      }
    }

    return MultiSelection(
      layerIds: layerIds,
      combinedBounds: combined,
      center: combined?.center,
      initialTransforms: initialTransforms,
    );
  }

  /// Get initial transform for a layer
  LayerTransform? getInitialTransform(String layerId) {
    return initialTransforms[layerId];
  }

  /// Calculate relative position of layer within combined bounds
  Offset? getRelativePosition(String layerId, Size posterSize) {
    if (combinedBounds == null) return null;

    final transform = initialTransforms[layerId];
    if (transform == null) return null;

    final layerPos = transform.absolutePosition(posterSize);
    return Offset(
      (layerPos.dx - combinedBounds!.left) / combinedBounds!.width,
      (layerPos.dy - combinedBounds!.top) / combinedBounds!.height,
    );
  }

  /// Create copy with modifications
  MultiSelection copyWith({
    List<String>? layerIds,
    Rect? combinedBounds,
    Offset? center,
    Map<String, LayerTransform>? initialTransforms,
  }) {
    return MultiSelection(
      layerIds: layerIds ?? this.layerIds,
      combinedBounds: combinedBounds ?? this.combinedBounds,
      center: center ?? this.center,
      initialTransforms: initialTransforms ?? this.initialTransforms,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MultiSelection &&
        other.layerIds.length == layerIds.length &&
        other.layerIds.every((id) => layerIds.contains(id));
  }

  @override
  int get hashCode => Object.hashAll(layerIds);
}