import '../../../core/types/typedefs.dart';
import '../../../core/utils/json_utils.dart';
import '../../../core/constants/editor_constants.dart';
import 'asset_base.dart';

/// Font asset model
class FontAsset extends AssetBase {
  /// Font family name
  final String family;

  /// Font weight (100-900)
  final int weight;

  /// Font style ('normal' or 'italic')
  final String style;

  /// Font URL (for remote loading)
  final String? url;

  /// Base64 encoded font data (for embedded fonts)
  final String? data;

  /// Character subset (e.g., 'latin', 'latin-ext')
  final String? subset;

  const FontAsset({
    required super.id,
    required super.name,
    required super.source,
    required this.family,
    this.weight = 400,
    this.style = 'normal',
    this.url,
    this.data,
    this.subset,
  });

  @override
  String get assetType => 'font';

  /// Check if font is from Google Fonts
  bool get isGoogleFont => source == AssetSources.googleFonts;

  /// Check if font is custom/embedded
  bool get isCustomFont => source == AssetSources.custom;

  /// Get font identifier (family + weight + style)
  String get fontIdentifier => '${family}_${weight}_$style';

  /// Check if font is bold (weight >= 600)
  bool get isBold => weight >= 600;

  /// Check if font is italic
  bool get isItalic => style == 'italic';

  /// Get weight name
  String get weightName {
    switch (weight) {
      case 100:
        return 'Thin';
      case 200:
        return 'Extra Light';
      case 300:
        return 'Light';
      case 400:
        return 'Regular';
      case 500:
        return 'Medium';
      case 600:
        return 'Semi Bold';
      case 700:
        return 'Bold';
      case 800:
        return 'Extra Bold';
      case 900:
        return 'Black';
      default:
        return 'Regular';
    }
  }

  /// Create from JSON
  factory FontAsset.fromJson(String id, JsonMap json) {
    return FontAsset(
      id: id,
      name: JsonUtils.getValue<String>(json, 'name') ??
          JsonUtils.getValue<String>(json, 'family', 'Unknown')!,
      source: JsonUtils.getValue<String>(json, 'source', AssetSources.googleFonts)!,
      family: JsonUtils.getValue<String>(json, 'family', 'Roboto')!,
      weight: JsonUtils.getValue<int>(json, 'weight', 400)!,
      style: JsonUtils.getValue<String>(json, 'style', 'normal')!,
      url: JsonUtils.getValue<String>(json, 'url'),
      data: JsonUtils.getValue<String>(json, 'data'),
      subset: JsonUtils.getValue<String>(json, 'subset'),
    );
  }

  @override
  JsonMap toJson() => {
    'id': id,
    'name': name,
    'source': source,
    'family': family,
    'weight': weight,
    'style': style,
    if (url != null) 'url': url,
    if (data != null) 'data': data,
    if (subset != null) 'subset': subset,
  };

  /// Create copy with modifications
  FontAsset copyWith({
    String? id,
    String? name,
    String? source,
    String? family,
    int? weight,
    String? style,
    String? url,
    String? data,
    String? subset,
  }) {
    return FontAsset(
      id: id ?? this.id,
      name: name ?? this.name,
      source: source ?? this.source,
      family: family ?? this.family,
      weight: weight ?? this.weight,
      style: style ?? this.style,
      url: url ?? this.url,
      data: data ?? this.data,
      subset: subset ?? this.subset,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FontAsset && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}