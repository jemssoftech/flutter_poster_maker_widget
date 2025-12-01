import '../../../core/types/typedefs.dart';
import '../../../core/utils/json_utils.dart';
import '../../../core/constants/editor_constants.dart';
import 'asset_base.dart';

/// Image asset model
class ImageAsset extends AssetBase {
  /// Base64 encoded image data (for embedded assets)
  final String? data;

  /// External URL (for remote assets)
  final String? url;

  /// Image width in pixels
  final int width;

  /// Image height in pixels
  final int height;

  /// File size in bytes
  final int? sizeBytes;

  /// MIME type (image/jpeg, image/png, etc.)
  final String mimeType;

  /// Thumbnail as base64 (for previews)
  final String? thumbnail;

  /// Content hash for deduplication
  final String? hash;

  const ImageAsset({
    required super.id,
    required super.name,
    required super.source,
    this.data,
    this.url,
    required this.width,
    required this.height,
    this.sizeBytes,
    this.mimeType = 'image/png',
    this.thumbnail,
    this.hash,
  });

  @override
  String get assetType => 'image';

  /// Check if asset is embedded (base64 data)
  bool get isEmbedded => data != null && data!.isNotEmpty;

  /// Check if asset is remote (URL)
  bool get isRemote => url != null && url!.isNotEmpty;

  /// Get aspect ratio
  double get aspectRatio => width / height;

  /// Check if image is landscape
  bool get isLandscape => width > height;

  /// Check if image is portrait
  bool get isPortrait => height > width;

  /// Check if image is square
  bool get isSquare => width == height;

  /// Create from JSON
  factory ImageAsset.fromJson(String id, JsonMap json) {
    return ImageAsset(
      id: id,
      name: JsonUtils.getValue<String>(json, 'name', 'Untitled')!,
      source: JsonUtils.getValue<String>(json, 'source', AssetSources.userUpload)!,
      data: JsonUtils.getValue<String>(json, 'data'),
      url: JsonUtils.getValue<String>(json, 'url'),
      width: JsonUtils.getValue<int>(json, 'width', 0)!,
      height: JsonUtils.getValue<int>(json, 'height', 0)!,
      sizeBytes: JsonUtils.getValue<int>(json, 'size_bytes'),
      mimeType: JsonUtils.getValue<String>(json, 'mime_type', 'image/png')!,
      thumbnail: JsonUtils.getValue<String>(json, 'thumbnail'),
      hash: JsonUtils.getValue<String>(json, 'hash'),
    );
  }

  @override
  JsonMap toJson() => {
    'id': id,
    'name': name,
    'source': source,
    if (data != null) 'data': data,
    if (url != null) 'url': url,
    'width': width,
    'height': height,
    if (sizeBytes != null) 'size_bytes': sizeBytes,
    'mime_type': mimeType,
    if (thumbnail != null) 'thumbnail': thumbnail,
    if (hash != null) 'hash': hash,
  };

  /// Create copy with modifications
  ImageAsset copyWith({
    String? id,
    String? name,
    String? source,
    String? data,
    String? url,
    int? width,
    int? height,
    int? sizeBytes,
    String? mimeType,
    String? thumbnail,
    String? hash,
  }) {
    return ImageAsset(
      id: id ?? this.id,
      name: name ?? this.name,
      source: source ?? this.source,
      data: data ?? this.data,
      url: url ?? this.url,
      width: width ?? this.width,
      height: height ?? this.height,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      mimeType: mimeType ?? this.mimeType,
      thumbnail: thumbnail ?? this.thumbnail,
      hash: hash ?? this.hash,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ImageAsset && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}