import '../../core/types/typedefs.dart';
import '../../core/utils/json_utils.dart';

/// Editor settings for a poster
class PosterSettings {
  /// Enable snap to grid
  final bool snapToGrid;

  /// Grid size in pixels
  final int gridSize;

  /// Enable snap to objects
  final bool snapToObjects;

  /// Show guide lines
  final bool showGuides;

  /// Lock aspect ratio when resizing
  final bool lockAspectRatio;

  /// Snap threshold in pixels
  final double snapThreshold;

  /// Enable smart guides
  final bool smartGuides;

  /// Show rulers
  final bool showRulers;

  const PosterSettings({
    this.snapToGrid = true,
    this.gridSize = 10,
    this.snapToObjects = true,
    this.showGuides = true,
    this.lockAspectRatio = true,
    this.snapThreshold = 5.0,
    this.smartGuides = true,
    this.showRulers = false,
  });

  /// Default settings
  static const PosterSettings defaults = PosterSettings();

  /// Create from JSON
  factory PosterSettings.fromJson(JsonMap? json) {
    if (json == null) return PosterSettings.defaults;

    return PosterSettings(
      snapToGrid: JsonUtils.getValue<bool>(json, 'snap_to_grid', true)!,
      gridSize: JsonUtils.getValue<int>(json, 'grid_size', 10)!,
      snapToObjects: JsonUtils.getValue<bool>(json, 'snap_to_objects', true)!,
      showGuides: JsonUtils.getValue<bool>(json, 'show_guides', true)!,
      lockAspectRatio: JsonUtils.getValue<bool>(json, 'lock_aspect_ratio', true)!,
      snapThreshold: JsonUtils.getValue<double>(json, 'snap_threshold', 5.0)!,
      smartGuides: JsonUtils.getValue<bool>(json, 'smart_guides', true)!,
      showRulers: JsonUtils.getValue<bool>(json, 'show_rulers', false)!,
    );
  }

  /// Convert to JSON
  JsonMap toJson() => {
    'snap_to_grid': snapToGrid,
    'grid_size': gridSize,
    'snap_to_objects': snapToObjects,
    'show_guides': showGuides,
    'lock_aspect_ratio': lockAspectRatio,
    'snap_threshold': snapThreshold,
    'smart_guides': smartGuides,
    'show_rulers': showRulers,
  };

  /// Create copy with modifications
  PosterSettings copyWith({
    bool? snapToGrid,
    int? gridSize,
    bool? snapToObjects,
    bool? showGuides,
    bool? lockAspectRatio,
    double? snapThreshold,
    bool? smartGuides,
    bool? showRulers,
  }) {
    return PosterSettings(
      snapToGrid: snapToGrid ?? this.snapToGrid,
      gridSize: gridSize ?? this.gridSize,
      snapToObjects: snapToObjects ?? this.snapToObjects,
      showGuides: showGuides ?? this.showGuides,
      lockAspectRatio: lockAspectRatio ?? this.lockAspectRatio,
      snapThreshold: snapThreshold ?? this.snapThreshold,
      smartGuides: smartGuides ?? this.smartGuides,
      showRulers: showRulers ?? this.showRulers,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PosterSettings &&
        other.snapToGrid == snapToGrid &&
        other.gridSize == gridSize &&
        other.snapToObjects == snapToObjects &&
        other.showGuides == showGuides &&
        other.lockAspectRatio == lockAspectRatio;
  }

  @override
  int get hashCode => Object.hash(
    snapToGrid, gridSize, snapToObjects, showGuides, lockAspectRatio,
  );
}