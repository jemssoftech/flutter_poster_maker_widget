import '../../../core/types/typedefs.dart';
import '../../../core/utils/json_utils.dart';
import '../../../core/constants/editor_constants.dart';
import '../transform/layer_transform.dart';
import '../effects/layer_effects.dart';
import '../svg/svg_element_override.dart';
import 'layer_base.dart';

/// SVG layer
class SvgLayer extends LayerBase {
  /// Asset ID reference
  final String assetId;

  /// Whether to preserve original aspect ratio
  final bool preserveAspectRatio;

  /// Element overrides (color changes, etc.)
  final Map<String, SvgElementOverride> elementOverrides;

  /// Global color replacement (replaces all colors with this)
  final String? globalColorReplace;

  /// Allow individual element selection
  final bool allowElementSelection;

  const SvgLayer({
    required super.id,
    required super.name,
    super.visible,
    super.locked,
    super.opacity,
    super.blendMode,
    super.transform,
    super.effects,
    required this.assetId,
    this.preserveAspectRatio = true,
    this.elementOverrides = const {},
    this.globalColorReplace,
    this.allowElementSelection = true,
  }) : super(type: LayerTypes.svg);

  /// Check if any element overrides exist
  bool get hasOverrides => elementOverrides.isNotEmpty;

  /// Get override for specific element
  SvgElementOverride? getElementOverride(String elementId) {
    return elementOverrides[elementId];
  }

  /// Create from JSON
  factory SvgLayer.fromJson(JsonMap json) {
    final props = LayerJsonParser.parseProps(json);

    final overridesJson = props['element_overrides'] as Map<String, dynamic>? ?? {};
    final elementOverrides = <String, SvgElementOverride>{};

    overridesJson.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        elementOverrides[key] = SvgElementOverride.fromJson(value);
      }
    });

    return SvgLayer(
      id: LayerJsonParser.parseId(json),
      name: LayerJsonParser.parseName(json, 'SVG'),
      visible: LayerJsonParser.parseVisible(json),
      locked: LayerJsonParser.parseLocked(json),
      opacity: LayerJsonParser.parseOpacity(json),
      blendMode: LayerJsonParser.parseBlendMode(json),
      transform: LayerJsonParser.parseTransform(json),
      effects: LayerJsonParser.parseEffects(json),
      assetId: JsonUtils.getRequired<String>(props, 'asset_id', 'svg layer props'),
      preserveAspectRatio: JsonUtils.getValue<bool>(props, 'preserve_aspect_ratio', true)!,
      elementOverrides: elementOverrides,
      globalColorReplace: JsonUtils.getValue<String>(props, 'global_color_replace'),
      allowElementSelection: JsonUtils.getValue<bool>(props, 'allow_element_selection', true)!,
    );
  }

  @override
  JsonMap propsToJson() => {
    'asset_id': assetId,
    'preserve_aspect_ratio': preserveAspectRatio,
    'element_overrides': elementOverrides.map(
          (key, value) => MapEntry(key, value.toJson()),
    ),
    if (globalColorReplace != null) 'global_color_replace': globalColorReplace,
    'allow_element_selection': allowElementSelection,
  };

  @override
  SvgLayer copyWith({
    String? id,
    String? name,
    bool? visible,
    bool? locked,
    double? opacity,
    LayerBlendMode? blendMode,
    LayerTransform? transform,
    LayerEffects? effects,
    String? assetId,
    bool? preserveAspectRatio,
    Map<String, SvgElementOverride>? elementOverrides,
    String? globalColorReplace,
    bool? allowElementSelection,
    bool clearGlobalColorReplace = false,
  }) {
    return SvgLayer(
      id: id ?? this.id,
      name: name ?? this.name,
      visible: visible ?? this.visible,
      locked: locked ?? this.locked,
      opacity: opacity ?? this.opacity,
      blendMode: blendMode ?? this.blendMode,
      transform: transform ?? this.transform,
      effects: effects ?? this.effects,
      assetId: assetId ?? this.assetId,
      preserveAspectRatio: preserveAspectRatio ?? this.preserveAspectRatio,
      elementOverrides: elementOverrides ?? this.elementOverrides,
      globalColorReplace: clearGlobalColorReplace
          ? null
          : (globalColorReplace ?? this.globalColorReplace),
      allowElementSelection: allowElementSelection ?? this.allowElementSelection,
    );
  }

  /// Create copy with updated element override
  SvgLayer withElementOverride(String elementId, SvgElementOverride override) {
    final newOverrides = Map<String, SvgElementOverride>.from(elementOverrides);
    if (override.hasOverrides) {
      newOverrides[elementId] = override;
    } else {
      newOverrides.remove(elementId);
    }
    return copyWith(elementOverrides: newOverrides);
  }

  /// Create copy with cleared element override
  SvgLayer withoutElementOverride(String elementId) {
    final newOverrides = Map<String, SvgElementOverride>.from(elementOverrides);
    newOverrides.remove(elementId);
    return copyWith(elementOverrides: newOverrides);
  }

  /// Create copy with all overrides cleared
  SvgLayer withClearedOverrides() {
    return copyWith(elementOverrides: {});
  }

  @override
  SvgLayer withTransform(LayerTransform transform) {
    return copyWith(transform: transform);
  }

  @override
  SvgLayer withEffects(LayerEffects effects) {
    return copyWith(effects: effects);
  }
}