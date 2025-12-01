import '../../../core/types/typedefs.dart';
import 'image_asset.dart';
import 'font_asset.dart';
import 'svg_asset.dart';

/// Collection of all assets used in a poster
class AssetManifest {
  final Map<String, ImageAsset> images;
  final Map<String, FontAsset> fonts;
  final Map<String, SvgAsset> svgs;

  const AssetManifest({
    this.images = const {},
    this.fonts = const {},
    this.svgs = const {},
  });

  /// Empty manifest
  static const AssetManifest empty = AssetManifest();

  /// Total number of assets
  int get totalCount => images.length + fonts.length + svgs.length;

  /// Check if manifest is empty
  bool get isEmpty => totalCount == 0;

  /// Check if manifest has images
  bool get hasImages => images.isNotEmpty;

  /// Check if manifest has fonts
  bool get hasFonts => fonts.isNotEmpty;

  /// Check if manifest has SVGs
  bool get hasSvgs => svgs.isNotEmpty;

  /// Get image by ID
  ImageAsset? getImage(String id) => images[id];

  /// Get font by ID
  FontAsset? getFont(String id) => fonts[id];

  /// Get SVG by ID
  SvgAsset? getSvg(String id) => svgs[id];

  /// Get all font families used
  Set<String> get usedFontFamilies {
    return fonts.values.map((f) => f.family).toSet();
  }

  /// Create from JSON
  factory AssetManifest.fromJson(JsonMap? json) {
    if (json == null) return AssetManifest.empty;

    final imagesJson = json['images'] as Map<String, dynamic>? ?? {};
    final fontsJson = json['fonts'] as Map<String, dynamic>? ?? {};
    final svgsJson = json['svgs'] as Map<String, dynamic>? ?? {};

    return AssetManifest(
      images: imagesJson.map(
            (key, value) => MapEntry(key, ImageAsset.fromJson(key, value as JsonMap)),
      ),
      fonts: fontsJson.map(
            (key, value) => MapEntry(key, FontAsset.fromJson(key, value as JsonMap)),
      ),
      svgs: svgsJson.map(
            (key, value) => MapEntry(key, SvgAsset.fromJson(key, value as JsonMap)),
      ),
    );
  }

  /// Convert to JSON
  JsonMap toJson() => {
    'images': images.map((key, value) => MapEntry(key, value.toJson())),
    'fonts': fonts.map((key, value) => MapEntry(key, value.toJson())),
    'svgs': svgs.map((key, value) => MapEntry(key, value.toJson())),
  };

  /// Create copy with added image
  AssetManifest withImage(ImageAsset image) {
    return copyWith(images: {...images, image.id: image});
  }

  /// Create copy with added font
  AssetManifest withFont(FontAsset font) {
    return copyWith(fonts: {...fonts, font.id: font});
  }

  /// Create copy with added SVG
  AssetManifest withSvg(SvgAsset svg) {
    return copyWith(svgs: {...svgs, svg.id: svg});
  }

  /// Create copy with removed asset
  AssetManifest withoutAsset(String assetId) {
    return AssetManifest(
      images: Map.from(images)..remove(assetId),
      fonts: Map.from(fonts)..remove(assetId),
      svgs: Map.from(svgs)..remove(assetId),
    );
  }

  /// Create copy with modifications
  AssetManifest copyWith({
    Map<String, ImageAsset>? images,
    Map<String, FontAsset>? fonts,
    Map<String, SvgAsset>? svgs,
  }) {
    return AssetManifest(
      images: images ?? this.images,
      fonts: fonts ?? this.fonts,
      svgs: svgs ?? this.svgs,
    );
  }

  /// Merge with another manifest
  AssetManifest merge(AssetManifest other) {
    return AssetManifest(
      images: {...images, ...other.images},
      fonts: {...fonts, ...other.fonts},
      svgs: {...svgs, ...other.svgs},
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AssetManifest &&
        other.images.length == images.length &&
        other.fonts.length == fonts.length &&
        other.svgs.length == svgs.length;
  }

  @override
  int get hashCode => Object.hash(images.length, fonts.length, svgs.length);
}