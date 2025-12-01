import 'dart:ui' show Size; // Add this import for Flutter's Size

import '../../core/types/typedefs.dart';
import '../../core/utils/json_utils.dart';
import '../../core/utils/id_generator.dart';
import '../../core/constants/editor_constants.dart';
import '../../core/errors/editor_exception.dart';
import 'poster_metadata.dart';
import 'poster_canvas.dart';
import 'poster_settings.dart';
import 'assets/asset_manifest.dart';
import 'layers/layer_base.dart';
import 'layers/layer_factory.dart';

/// Complete poster document model
class PosterDocument {
  /// JSON schema URL
  final String schema;

  /// Schema version
  final String version;

  /// Document metadata
  final PosterMetadata metadata;

  /// Canvas configuration
  final PosterCanvas poster;

  /// Asset manifest
  final AssetManifest assets;

  /// Layers (ordered from bottom to top)
  final List<LayerBase> layers;

  /// Editor settings
  final PosterSettings settings;

  const PosterDocument({
    this.schema = EditorConstants.schemaUrl,
    this.version = EditorConstants.schemaVersion,
    required this.metadata,
    this.poster = const PosterCanvas(),
    this.assets = const AssetManifest(),
    this.layers = const [],
    this.settings = const PosterSettings(),
  });

  /// Create new empty document
  factory PosterDocument.create({
    String? name,
    double width = EditorConstants.defaultPosterWidth,
    double height = EditorConstants.defaultPosterHeight,
    String? author,
  }) {
    final id = IdGenerator.uuid();
    return PosterDocument(
      metadata: PosterMetadata.create(
        id: id,
        name: name ?? 'Untitled Poster',
        author: author,
      ),
      poster: PosterCanvas(width: width, height: height),
    );
  }

  /// Create from JSON string
  factory PosterDocument.fromJsonString(String jsonString) {
    try {
      final json = JsonUtils.deepClone(
        Map<String, dynamic>.from(
            (jsonString as dynamic) is String
            ? throw ArgumentError('Use dart:convert to parse JSON string first')
            : jsonString as Map<String, dynamic>,
      ),
    );
    return PosterDocument.fromJson(json);
    } catch (e) {
    throw JsonParseException(
    message: 'Failed to parse poster document: $e',
    );
    }
  }

  /// Create from JSON map
  factory PosterDocument.fromJson(JsonMap json) {
    try {
      return PosterDocument(
        schema: JsonUtils.getValue<String>(json, '\$schema') ??
            JsonUtils.getValue<String>(json, 'schema', EditorConstants.schemaUrl)!,
        version: JsonUtils.getValue<String>(json, 'version', EditorConstants.schemaVersion)!,
        metadata: PosterMetadata.fromJson(
          json['metadata'] as JsonMap? ?? _extractLegacyMetadata(json),
        ),
        poster: PosterCanvas.fromJson(json['poster'] as JsonMap?),
        assets: AssetManifest.fromJson(json['assets'] as JsonMap?),
        layers: LayerFactory.fromJsonList(json['layers'] as List<dynamic>?),
        settings: PosterSettings.fromJson(json['settings'] as JsonMap?),
      );
    } catch (e) {
      if (e is EditorException) rethrow;
      throw JsonParseException(
        message: 'Failed to parse poster document: $e',
      );
    }
  }

  /// Extract metadata from legacy format
  static JsonMap _extractLegacyMetadata(JsonMap json) {
    return {
      'id': json['id'] ?? IdGenerator.uuid(),
      'name': json['name'] ?? 'Untitled Poster',
      'created': json['created'] ?? DateTime.now().toIso8601String(),
      'modified': json['modified'] ?? DateTime.now().toIso8601String(),
    };
  }

  /// Convert to JSON map
  JsonMap toJson() => {
    '\$schema': schema,
    'version': version,
    'metadata': metadata.toJson(),
    'poster': poster.toJson(),
    'assets': assets.toJson(),
    'layers': LayerFactory.toJsonList(layers),
    'settings': settings.toJson(),
  };

  /// Get document ID
  String get id => metadata.id;

  /// Get document name
  String get name => metadata.name;

  /// Get canvas size (uses Flutter's Size from dart:ui)
  Size get size => Size(poster.width, poster.height);

  /// Get layer count
  int get layerCount => layers.length;

  /// Check if document is empty (no layers)
  bool get isEmpty => layers.isEmpty;

  /// Check if document has layers
  bool get hasLayers => layers.isNotEmpty;

  /// Get layer by ID
  LayerBase? getLayerById(String layerId) {
    for (final layer in layers) {
      if (layer.id == layerId) return layer;
    }
    return null;
  }

  /// Get layer index by ID
  int getLayerIndex(String layerId) {
    for (int i = 0; i < layers.length; i++) {
      if (layers[i].id == layerId) return i;
    }
    return -1;
  }

  /// Get visible layers
  List<LayerBase> get visibleLayers {
    return layers.where((layer) => layer.visible).toList();
  }

  /// Get unlocked layers
  List<LayerBase> get unlockedLayers {
    return layers.where((layer) => !layer.locked).toList();
  }

  /// Get editable layers (visible and unlocked)
  List<LayerBase> get editableLayers {
    return layers.where((layer) => layer.isEditable).toList();
  }

  /// Create copy with modifications
  PosterDocument copyWith({
    String? schema,
    String? version,
    PosterMetadata? metadata,
    PosterCanvas? poster,
    AssetManifest? assets,
    List<LayerBase>? layers,
    PosterSettings? settings,
  }) {
    return PosterDocument(
      schema: schema ?? this.schema,
      version: version ?? this.version,
      metadata: metadata ?? this.metadata,
      poster: poster ?? this.poster,
      assets: assets ?? this.assets,
      layers: layers ?? this.layers,
      settings: settings ?? this.settings,
    );
  }

  /// Create copy with touched metadata (updated modification time)
  PosterDocument touch() {
    return copyWith(metadata: metadata.touch());
  }

  /// Add layer at index (or end if index not specified)
  PosterDocument addLayer(LayerBase layer, [int? index]) {
    final newLayers = List<LayerBase>.from(layers);
    if (index != null && index >= 0 && index <= newLayers.length) {
      newLayers.insert(index, layer);
    } else {
      newLayers.add(layer);
    }
    return copyWith(layers: newLayers).touch();
  }

  /// Remove layer by ID
  PosterDocument removeLayer(String layerId) {
    final newLayers = layers.where((l) => l.id != layerId).toList();
    return copyWith(layers: newLayers).touch();
  }

  /// Update layer by ID
  PosterDocument updateLayer(String layerId, LayerBase Function(LayerBase) updater) {
    final newLayers = layers.map((layer) {
      if (layer.id == layerId) {
        return updater(layer);
      }
      return layer;
    }).toList();
    return copyWith(layers: newLayers).touch();
  }

  /// Reorder layer from oldIndex to newIndex
  PosterDocument reorderLayer(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= layers.length) return this;
    if (newIndex < 0 || newIndex >= layers.length) return this;
    if (oldIndex == newIndex) return this;

    final newLayers = List<LayerBase>.from(layers);
    final layer = newLayers.removeAt(oldIndex);
    newLayers.insert(newIndex, layer);
    return copyWith(layers: newLayers).touch();
  }

  /// Duplicate layer by ID
  PosterDocument duplicateLayer(String layerId) {
    final index = getLayerIndex(layerId);
    if (index < 0) return this;

    final original = layers[index];
    final duplicate = original.copyWith(
      id: IdGenerator.layerId(original.type),
      name: '${original.name} (Copy)',
    );

    return addLayer(duplicate, index + 1);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PosterDocument && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'PosterDocument($id, $name, ${layers.length} layers)';
}