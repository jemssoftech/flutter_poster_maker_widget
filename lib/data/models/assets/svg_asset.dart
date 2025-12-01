import '../../../core/types/typedefs.dart';
import '../../../core/utils/json_utils.dart';
import '../../../core/constants/editor_constants.dart';
import '../svg/svg_element.dart';
import 'asset_base.dart';

/// SVG asset model
class SvgAsset extends AssetBase {
  /// SVG source/pack ID (for builtin stickers)
  final String? packId;

  /// Raw SVG data string
  final String data;

  /// Editable elements within the SVG
  final Map<String, SvgElement> elements;

  /// SVG viewBox string
  final String? viewBox;

  /// Original width
  final double width;

  /// Original height
  final double height;

  const SvgAsset({
    required super.id,
    required super.name,
    required super.source,
    this.packId,
    required this.data,
    this.elements = const {},
    this.viewBox,
    this.width = 100,
    this.height = 100,
  });

  @override
  String get assetType => 'svg';

  /// Check if SVG is from builtin pack
  bool get isBuiltin => source == AssetSources.builtinPack;

  /// Check if SVG has editable elements
  bool get hasEditableElements => elements.isNotEmpty;

  /// Get list of editable element IDs
  List<String> get editableElementIds => elements.keys.toList();

  /// Get element by ID
  SvgElement? getElement(String elementId) => elements[elementId];

  /// Get aspect ratio
  double get aspectRatio => width / height;

  /// Create from JSON
  factory SvgAsset.fromJson(String id, JsonMap json) {
    final elementsJson = json['elements'] as Map<String, dynamic>? ?? {};
    final elements = <String, SvgElement>{};

    elementsJson.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        elements[key] = SvgElement.fromJson(key, value);
      }
    });

    return SvgAsset(
      id: id,
      name: JsonUtils.getValue<String>(json, 'name', 'Untitled')!,
      source: JsonUtils.getValue<String>(json, 'source', AssetSources.builtinPack)!,
      packId: JsonUtils.getValue<String>(json, 'pack_id'),
      data: JsonUtils.getValue<String>(json, 'data', '')!,
      elements: elements,
      viewBox: JsonUtils.getValue<String>(json, 'viewBox') ??
          JsonUtils.getValue<String>(json, 'view_box'),
      width: JsonUtils.getValue<double>(json, 'width', 100)!,
      height: JsonUtils.getValue<double>(json, 'height', 100)!,
    );
  }

  @override
  JsonMap toJson() => {
    'id': id,
    'name': name,
    'source': source,
    if (packId != null) 'pack_id': packId,
    'data': data,
    'elements': elements.map((key, value) => MapEntry(key, value.toJson())),
    if (viewBox != null) 'viewBox': viewBox,
    'width': width,
    'height': height,
  };

  /// Create copy with modifications
  SvgAsset copyWith({
    String? id,
    String? name,
    String? source,
    String? packId,
    String? data,
    Map<String, SvgElement>? elements,
    String? viewBox,
    double? width,
    double? height,
  }) {
    return SvgAsset(
      id: id ?? this.id,
      name: name ?? this.name,
      source: source ?? this.source,
      packId: packId ?? this.packId,
      data: data ?? this.data,
      elements: elements ?? this.elements,
      viewBox: viewBox ?? this.viewBox,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SvgAsset && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}