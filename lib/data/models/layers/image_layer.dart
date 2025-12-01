import 'package:flutter/material.dart';
import '../../../core/types/typedefs.dart';
import '../../../core/utils/json_utils.dart';
import '../../../core/constants/editor_constants.dart';
import '../transform/layer_transform.dart';
import '../effects/layer_effects.dart';
import '../shapes/corner_radius.dart';
import 'layer_base.dart';

/// Image fit mode
enum ImageFit {
  contain,
  cover,
  fill,
  fitWidth,
  fitHeight,
  none,
}

/// Extension for ImageFit
extension ImageFitExtension on ImageFit {
  /// Convert to Flutter BoxFit
  BoxFit toBoxFit() {
    switch (this) {
      case ImageFit.contain:
        return BoxFit.contain;
      case ImageFit.cover:
        return BoxFit.cover;
      case ImageFit.fill:
        return BoxFit.fill;
      case ImageFit.fitWidth:
        return BoxFit.fitWidth;
      case ImageFit.fitHeight:
        return BoxFit.fitHeight;
      case ImageFit.none:
        return BoxFit.none;
    }
  }

  /// Parse from string
  static ImageFit fromString(String? value) {
    if (value == null) return ImageFit.cover;

    for (final fit in ImageFit.values) {
      if (fit.name == value) return fit;
    }
    return ImageFit.cover;
  }
}

/// Image crop settings
class ImageCrop {
  final bool enabled;
  final double x;
  final double y;
  final double width;
  final double height;

  const ImageCrop({
    this.enabled = false,
    this.x = 0,
    this.y = 0,
    this.width = 1,
    this.height = 1,
  });

  /// No crop
  static const ImageCrop none = ImageCrop();

  /// Create from JSON
  factory ImageCrop.fromJson(JsonMap? json) {
    if (json == null) return ImageCrop.none;

    return ImageCrop(
      enabled: JsonUtils.getValue<bool>(json, 'enabled', false)!,
      x: JsonUtils.getValue<double>(json, 'x', 0)!,
      y: JsonUtils.getValue<double>(json, 'y', 0)!,
      width: JsonUtils.getValue<double>(json, 'width', 1)!,
      height: JsonUtils.getValue<double>(json, 'height', 1)!,
    );
  }

  /// Convert to JSON
  JsonMap toJson() => {
    'enabled': enabled,
    'x': x,
    'y': y,
    'width': width,
    'height': height,
  };

  /// Get crop rect (normalized 0-1)
  Rect get rect => Rect.fromLTWH(x, y, width, height);

  /// Create copy with modifications
  ImageCrop copyWith({
    bool? enabled,
    double? x,
    double? y,
    double? width,
    double? height,
  }) {
    return ImageCrop(
      enabled: enabled ?? this.enabled,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }
}

/// Image filter settings
class ImageFilters {
  final double brightness;
  final double contrast;
  final double saturation;
  final double hueRotation;
  final double grayscale;
  final double sepia;
  final double invert;

  const ImageFilters({
    this.brightness = 1.0,
    this.contrast = 1.0,
    this.saturation = 1.0,
    this.hueRotation = 0,
    this.grayscale = 0,
    this.sepia = 0,
    this.invert = 0,
  });

  /// Default filters (no changes)
  static const ImageFilters none = ImageFilters();

  /// Check if any filters are applied
  bool get hasFilters {
    return brightness != 1.0 ||
        contrast != 1.0 ||
        saturation != 1.0 ||
        hueRotation != 0 ||
        grayscale != 0 ||
        sepia != 0 ||
        invert != 0;
  }

  /// Create from JSON
  factory ImageFilters.fromJson(JsonMap? json) {
    if (json == null) return ImageFilters.none;

    return ImageFilters(
      brightness: JsonUtils.getValue<double>(json, 'brightness', 1.0)!,
      contrast: JsonUtils.getValue<double>(json, 'contrast', 1.0)!,
      saturation: JsonUtils.getValue<double>(json, 'saturation', 1.0)!,
      hueRotation: JsonUtils.getValue<double>(json, 'hue_rotation', 0)!,
      grayscale: JsonUtils.getValue<double>(json, 'grayscale', 0)!,
      sepia: JsonUtils.getValue<double>(json, 'sepia', 0)!,
      invert: JsonUtils.getValue<double>(json, 'invert', 0)!,
    );
  }

  /// Convert to JSON
  JsonMap toJson() => {
    'brightness': brightness,
    'contrast': contrast,
    'saturation': saturation,
    'hue_rotation': hueRotation,
    'grayscale': grayscale,
    'sepia': sepia,
    'invert': invert,
  };

  /// Build color filter matrix
  ColorFilter? toColorFilter() {
    if (!hasFilters) return null;

    // Simplified - would need proper matrix calculation for full implementation
    return ColorFilter.matrix(<double>[
      contrast * brightness, 0, 0, 0, 0,
      0, contrast * brightness, 0, 0, 0,
      0, 0, contrast * brightness, 0, 0,
      0, 0, 0, 1, 0,
    ]);
  }

  /// Create copy with modifications
  ImageFilters copyWith({
    double? brightness,
    double? contrast,
    double? saturation,
    double? hueRotation,
    double? grayscale,
    double? sepia,
    double? invert,
  }) {
    return ImageFilters(
      brightness: brightness ?? this.brightness,
      contrast: contrast ?? this.contrast,
      saturation: saturation ?? this.saturation,
      hueRotation: hueRotation ?? this.hueRotation,
      grayscale: grayscale ?? this.grayscale,
      sepia: sepia ?? this.sepia,
      invert: invert ?? this.invert,
    );
  }
}

/// Image layer
class ImageLayer extends LayerBase {
  /// Asset ID reference
  final String assetId;

  /// Image fit mode
  final ImageFit fit;

  /// Content alignment within bounds
  final Offset alignment;

  /// Crop settings
  final ImageCrop crop;

  /// Image filters
  final ImageFilters filters;

  /// Corner radius
  final CornerRadius cornerRadius;

  const ImageLayer({
    required super.id,
    required super.name,
    super.visible,
    super.locked,
    super.opacity,
    super.blendMode,
    super.transform,
    super.effects,
    required this.assetId,
    this.fit = ImageFit.cover,
    this.alignment = const Offset(0.5, 0.5),
    this.crop = const ImageCrop(),
    this.filters = const ImageFilters(),
    this.cornerRadius = const CornerRadius(),
  }) : super(type: LayerTypes.image);

  /// Create from JSON
  factory ImageLayer.fromJson(JsonMap json) {
    final props = LayerJsonParser.parseProps(json);

    return ImageLayer(
      id: LayerJsonParser.parseId(json),
      name: LayerJsonParser.parseName(json, 'Image'),
      visible: LayerJsonParser.parseVisible(json),
      locked: LayerJsonParser.parseLocked(json),
      opacity: LayerJsonParser.parseOpacity(json),
      blendMode: LayerJsonParser.parseBlendMode(json),
      transform: LayerJsonParser.parseTransform(json),
      effects: LayerJsonParser.parseEffects(json),
      assetId: JsonUtils.getRequired<String>(props, 'asset_id', 'image layer props'),
      fit: ImageFitExtension.fromString(JsonUtils.getValue<String>(props, 'fit')),
      alignment: JsonUtils.parseOffset(
        props['alignment'] as JsonMap?,
        const Offset(0.5, 0.5),
      )!,
      crop: ImageCrop.fromJson(props['crop'] as JsonMap?),
      filters: ImageFilters.fromJson(props['filters'] as JsonMap?),
      cornerRadius: CornerRadius.fromJson(props['corner_radius'] as JsonMap?),
    );
  }

  @override
  JsonMap propsToJson() => {
    'asset_id': assetId,
    'fit': fit.name,
    'alignment': JsonUtils.offsetToJson(alignment),
    'crop': crop.toJson(),
    'filters': filters.toJson(),
    'corner_radius': cornerRadius.toJson(),
  };

  @override
  ImageLayer copyWith({
    String? id,
    String? name,
    bool? visible,
    bool? locked,
    double? opacity,
    LayerBlendMode? blendMode,
    LayerTransform? transform,
    LayerEffects? effects,
    String? assetId,
    ImageFit? fit,
    Offset? alignment,
    ImageCrop? crop,
    ImageFilters? filters,
    CornerRadius? cornerRadius,
  }) {
    return ImageLayer(
      id: id ?? this.id,
      name: name ?? this.name,
      visible: visible ?? this.visible,
      locked: locked ?? this.locked,
      opacity: opacity ?? this.opacity,
      blendMode: blendMode ?? this.blendMode,
      transform: transform ?? this.transform,
      effects: effects ?? this.effects,
      assetId: assetId ?? this.assetId,
      fit: fit ?? this.fit,
      alignment: alignment ?? this.alignment,
      crop: crop ?? this.crop,
      filters: filters ?? this.filters,
      cornerRadius: cornerRadius ?? this.cornerRadius,
    );
  }

  @override
  ImageLayer withTransform(LayerTransform transform) {
    return copyWith(transform: transform);
  }

  @override
  ImageLayer withEffects(LayerEffects effects) {
    return copyWith(effects: effects);
  }
}