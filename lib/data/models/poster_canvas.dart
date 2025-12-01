import 'dart:ui' show Size; // Add this import

import 'package:flutter/material.dart';
import '../../core/types/typedefs.dart';
import '../../core/utils/json_utils.dart';
import '../../core/constants/editor_constants.dart';
import 'poster_background.dart';

/// Canvas bleed settings (for print)
class CanvasBleed {
  final bool enabled;
  final double size;

  const CanvasBleed({
    this.enabled = false,
    this.size = 0,
  });

  /// No bleed
  static const CanvasBleed none = CanvasBleed();

  /// Standard print bleed (3mm ≈ 9px at 72dpi)
  static const CanvasBleed standard = CanvasBleed(enabled: true, size: 9);

  /// Create from JSON
  factory CanvasBleed.fromJson(JsonMap? json) {
    if (json == null) return CanvasBleed.none;

    return CanvasBleed(
      enabled: JsonUtils.getValue<bool>(json, 'enabled', false)!,
      size: JsonUtils.getValue<double>(json, 'size', 0)!,
    );
  }

  /// Convert to JSON
  JsonMap toJson() => {
    'enabled': enabled,
    'size': size,
  };

  /// Create copy with modifications
  CanvasBleed copyWith({
    bool? enabled,
    double? size,
  }) {
    return CanvasBleed(
      enabled: enabled ?? this.enabled,
      size: size ?? this.size,
    );
  }
}

/// Canvas guides configuration
class CanvasGuides {
  /// Vertical guide positions (0.0 to 1.0)
  final List<double> columns;

  /// Horizontal guide positions (0.0 to 1.0)
  final List<double> rows;

  /// Custom guide positions (absolute pixels)
  final List<GuidePosition> custom;

  const CanvasGuides({
    this.columns = const [],
    this.rows = const [],
    this.custom = const [],
  });

  /// Empty guides
  static const CanvasGuides empty = CanvasGuides();

  /// Default margin guides (10% from edges)
  static const CanvasGuides defaultMargins = CanvasGuides(
    columns: [0.1, 0.9],
    rows: [0.1, 0.9],
  );

  /// Create from JSON
  factory CanvasGuides.fromJson(JsonMap? json) {
    if (json == null) return CanvasGuides.empty;

    return CanvasGuides(
      columns: (json['columns'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList() ??
          [],
      rows: (json['rows'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList() ??
          [],
      custom: (json['custom'] as List<dynamic>?)
          ?.map((e) => GuidePosition.fromJson(e as JsonMap))
          .toList() ??
          [],
    );
  }

  /// Convert to JSON
  JsonMap toJson() => {
    'columns': columns,
    'rows': rows,
    'custom': custom.map((g) => g.toJson()).toList(),
  };

  /// Check if guides exist
  bool get hasGuides => columns.isNotEmpty || rows.isNotEmpty || custom.isNotEmpty;

  /// Create copy with modifications
  CanvasGuides copyWith({
    List<double>? columns,
    List<double>? rows,
    List<GuidePosition>? custom,
  }) {
    return CanvasGuides(
      columns: columns ?? this.columns,
      rows: rows ?? this.rows,
      custom: custom ?? this.custom,
    );
  }
}

/// Custom guide position
class GuidePosition {
  final double position;
  final bool isVertical;
  final String? label;

  const GuidePosition({
    required this.position,
    required this.isVertical,
    this.label,
  });

  /// Create from JSON
  factory GuidePosition.fromJson(JsonMap json) {
    return GuidePosition(
      position: JsonUtils.getValue<double>(json, 'position', 0)!,
      isVertical: JsonUtils.getValue<bool>(json, 'is_vertical', true)!,
      label: JsonUtils.getValue<String>(json, 'label'),
    );
  }

  /// Convert to JSON
  JsonMap toJson() => {
    'position': position,
    'is_vertical': isVertical,
    if (label != null) 'label': label,
  };
}

/// Poster canvas configuration (dimensions, background)
class PosterCanvas {
  /// Canvas width in pixels
  final double width;

  /// Canvas height in pixels
  final double height;

  /// Unit type (always 'px' for now)
  final String unit;

  /// Background configuration
  final PosterBackground background;

  /// Bleed settings
  final CanvasBleed bleed;

  /// Guide lines
  final CanvasGuides guides;

  const PosterCanvas({
    this.width = EditorConstants.defaultPosterWidth,
    this.height = EditorConstants.defaultPosterHeight,
    this.unit = 'px',
    this.background = const PosterBackground.solid(),
    this.bleed = const CanvasBleed(),
    this.guides = const CanvasGuides(),
  });

  /// Default canvas (1080x1920 Instagram story)
  static const PosterCanvas defaultCanvas = PosterCanvas();

  /// Square canvas (1080x1080)
  static const PosterCanvas square = PosterCanvas(
    width: 1080,
    height: 1080,
  );

  /// Landscape canvas (1920x1080)
  static const PosterCanvas landscape = PosterCanvas(
    width: 1920,
    height: 1080,
  );

  /// A4 portrait at 300dpi (2480x3508)
  static const PosterCanvas a4Portrait = PosterCanvas(
    width: 2480,
    height: 3508,
  );

  /// Create from JSON
  factory PosterCanvas.fromJson(JsonMap? json) {
    if (json == null) return PosterCanvas.defaultCanvas;

    return PosterCanvas(
      width: JsonUtils.getValue<double>(json, 'width', EditorConstants.defaultPosterWidth)!,
      height: JsonUtils.getValue<double>(json, 'height', EditorConstants.defaultPosterHeight)!,
      unit: JsonUtils.getValue<String>(json, 'unit', 'px')!,
      background: PosterBackground.fromJson(json['background'] as JsonMap?),
      bleed: CanvasBleed.fromJson(json['bleed'] as JsonMap?),
      guides: CanvasGuides.fromJson(json['guides'] as JsonMap?),
    );
  }

  /// Convert to JSON
  JsonMap toJson() => {
    'width': width,
    'height': height,
    'unit': unit,
    'background': background.toJson(),
    'bleed': bleed.toJson(),
    'guides': guides.toJson(),
  };

  /// Get size as Size object
  Size get size => Size(width, height);

  /// Get aspect ratio
  double get aspectRatio => width / height;

  /// Check if portrait orientation
  bool get isPortrait => height > width;

  /// Check if landscape orientation
  bool get isLandscape => width > height;

  /// Check if square
  bool get isSquare => width == height;

  /// Get total width including bleed
  double get totalWidth => bleed.enabled ? width + (bleed.size * 2) : width;

  /// Get total height including bleed
  double get totalHeight => bleed.enabled ? height + (bleed.size * 2) : height;

  /// Get total size including bleed
  Size get totalSize => Size(totalWidth, totalHeight);

  /// Create copy with modifications
  PosterCanvas copyWith({
    double? width,
    double? height,
    String? unit,
    PosterBackground? background,
    CanvasBleed? bleed,
    CanvasGuides? guides,
  }) {
    return PosterCanvas(
      width: width ?? this.width,
      height: height ?? this.height,
      unit: unit ?? this.unit,
      background: background ?? this.background,
      bleed: bleed ?? this.bleed,
      guides: guides ?? this.guides,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PosterCanvas &&
        other.width == width &&
        other.height == height &&
        other.background == background;
  }

  @override
  int get hashCode => Object.hash(width, height, background);

  @override
  String toString() => 'PosterCanvas(${width}x$height)';
}