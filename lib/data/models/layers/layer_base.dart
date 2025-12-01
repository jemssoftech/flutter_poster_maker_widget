import 'package:flutter/material.dart';
import '../../../core/types/typedefs.dart';
import '../../../core/utils/json_utils.dart';
import '../../../core/constants/editor_constants.dart';
import '../transform/layer_transform.dart';
import '../effects/layer_effects.dart';

/// Blend mode enum
enum LayerBlendMode {
  normal,
  multiply,
  screen,
  overlay,
  darken,
  lighten,
  colorDodge,
  colorBurn,
  hardLight,
  softLight,
  difference,
  exclusion,
  hue,
  saturation,
  color,
  luminosity,
}

/// Extension for LayerBlendMode
extension LayerBlendModeExtension on LayerBlendMode {
  /// Convert to Flutter BlendMode
  BlendMode toFlutterBlendMode() {
    switch (this) {
      case LayerBlendMode.normal:
        return BlendMode.srcOver;
      case LayerBlendMode.multiply:
        return BlendMode.multiply;
      case LayerBlendMode.screen:
        return BlendMode.screen;
      case LayerBlendMode.overlay:
        return BlendMode.overlay;
      case LayerBlendMode.darken:
        return BlendMode.darken;
      case LayerBlendMode.lighten:
        return BlendMode.lighten;
      case LayerBlendMode.colorDodge:
        return BlendMode.colorDodge;
      case LayerBlendMode.colorBurn:
        return BlendMode.colorBurn;
      case LayerBlendMode.hardLight:
        return BlendMode.hardLight;
      case LayerBlendMode.softLight:
        return BlendMode.softLight;
      case LayerBlendMode.difference:
        return BlendMode.difference;
      case LayerBlendMode.exclusion:
        return BlendMode.exclusion;
      case LayerBlendMode.hue:
        return BlendMode.hue;
      case LayerBlendMode.saturation:
        return BlendMode.saturation;
      case LayerBlendMode.color:
        return BlendMode.color;
      case LayerBlendMode.luminosity:
        return BlendMode.luminosity;
    }
  }

  /// Convert to JSON string
  String toJsonString() {
    return name.replaceAllMapped(
      RegExp(r'[A-Z]'),
          (match) => '_${match.group(0)!.toLowerCase()}',
    );
  }

  /// Parse from JSON string
  static LayerBlendMode fromString(String? value) {
    if (value == null) return LayerBlendMode.normal;

    final normalized = value.replaceAllMapped(
      RegExp(r'_([a-z])'),
          (match) => match.group(1)!.toUpperCase(),
    );

    for (final mode in LayerBlendMode.values) {
      if (mode.name == normalized) return mode;
    }
    return LayerBlendMode.normal;
  }
}

/// Abstract base class for all layer types
abstract class LayerBase {
  /// Unique identifier
  final String id;

  /// Layer type identifier
  final String type;

  /// Display name
  final String name;

  /// Visibility
  final bool visible;

  /// Lock state
  final bool locked;

  /// Opacity (0.0 to 1.0)
  final double opacity;

  /// Blend mode
  final LayerBlendMode blendMode;

  /// Transform properties
  final LayerTransform transform;

  /// Layer effects
  final LayerEffects effects;

  const LayerBase({
    required this.id,
    required this.type,
    required this.name,
    this.visible = true,
    this.locked = false,
    this.opacity = 1.0,
    this.blendMode = LayerBlendMode.normal,
    this.transform = const LayerTransform(),
    this.effects = const LayerEffects(),
  });

  /// Convert to JSON
  JsonMap toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'visible': visible,
      'locked': locked,
      'opacity': opacity,
      'blend_mode': blendMode.toJsonString(),
      'transform': transform.toJson(),
      'effects': effects.toJson(),
      'props': propsToJson(),
    };
  }

  /// Convert layer-specific props to JSON
  JsonMap propsToJson();

  /// Create copy with modifications
  LayerBase copyWith({
    String? id,
    String? name,
    bool? visible,
    bool? locked,
    double? opacity,
    LayerBlendMode? blendMode,
    LayerTransform? transform,
    LayerEffects? effects,
  });

  /// Create copy with updated transform
  LayerBase withTransform(LayerTransform transform);

  /// Create copy with updated effects
  LayerBase withEffects(LayerEffects effects);

  /// Check if layer is editable (not locked and visible)
  bool get isEditable => !locked && visible;

  /// Check if layer has effects
  bool get hasEffects => effects.hasEffects;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LayerBase && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => '$type Layer($id, $name)';
}

/// Parse base layer properties from JSON
mixin LayerJsonParser {
  static String parseId(JsonMap json) {
    return JsonUtils.getRequired<String>(json, 'id', 'layer');
  }

  static String parseType(JsonMap json) {
    return JsonUtils.getRequired<String>(json, 'type', 'layer');
  }

  static String parseName(JsonMap json, String defaultName) {
    return JsonUtils.getValue<String>(json, 'name', defaultName)!;
  }

  static bool parseVisible(JsonMap json) {
    return JsonUtils.getValue<bool>(json, 'visible', true)!;
  }

  static bool parseLocked(JsonMap json) {
    return JsonUtils.getValue<bool>(json, 'locked', false)!;
  }

  static double parseOpacity(JsonMap json) {
    return JsonUtils.getValue<double>(json, 'opacity', 1.0)!.clamp(0.0, 1.0);
  }

  static LayerBlendMode parseBlendMode(JsonMap json) {
    return LayerBlendModeExtension.fromString(
      JsonUtils.getValue<String>(json, 'blend_mode'),
    );
  }

  static LayerTransform parseTransform(JsonMap json) {
    return LayerTransform.fromJson(json['transform'] as JsonMap?);
  }

  static LayerEffects parseEffects(JsonMap json) {
    return LayerEffects.fromJson(json['effects'] as JsonMap?);
  }

  static JsonMap parseProps(JsonMap json) {
    return json['props'] as JsonMap? ?? {};
  }
}