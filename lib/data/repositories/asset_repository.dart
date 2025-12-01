import 'dart:typed_data';

import '../../core/types/typedefs.dart';
import '../../core/utils/id_generator.dart';
import '../models/assets/image_asset.dart';
import '../models/assets/font_asset.dart';
import '../models/assets/svg_asset.dart';

/// Repository for asset operations
abstract class AssetRepository {
  /// Load image from bytes
  Future<ImageAsset> loadImageFromBytes(Uint8List bytes, String filename);

  /// Load image from base64
  Future<ImageAsset> loadImageFromBase64(String base64Data, String filename);

  /// Load SVG from string
  Future<SvgAsset> loadSvgFromString(String svgData, String name);

  /// Create font asset reference
  Future<FontAsset> createFontAsset(String family, int weight, String source);
}

/// Implementation of AssetRepository
class AssetRepositoryImpl implements AssetRepository {
  @override
  Future<ImageAsset> loadImageFromBytes(Uint8List bytes, String filename) async {
    // In a real implementation, you would:
    // 1. Decode the image to get dimensions
    // 2. Generate a thumbnail
    // 3. Calculate hash for deduplication

    final id = IdGenerator.assetId('img');
    final base64 = 'data:image/png;base64,${_bytesToBase64(bytes)}';

    return ImageAsset(
      id: id,
      name: filename,
      source: 'user_upload',
      data: base64,
      width: 0, // Would be decoded from image
      height: 0, // Would be decoded from image
      sizeBytes: bytes.length,
      mimeType: _getMimeType(filename),
    );
  }

  @override
  Future<ImageAsset> loadImageFromBase64(String base64Data, String filename) async {
    final id = IdGenerator.assetId('img');

    return ImageAsset(
      id: id,
      name: filename,
      source: 'user_upload',
      data: base64Data,
      width: 0,
      height: 0,
      mimeType: _getMimeType(filename),
    );
  }

  @override
  Future<SvgAsset> loadSvgFromString(String svgData, String name) async {
    final id = IdGenerator.assetId('svg');

    // In a real implementation, you would parse the SVG
    // to extract editable elements

    return SvgAsset(
      id: id,
      name: name,
      source: 'user_upload',
      data: svgData,
      elements: {}, // Would be parsed from SVG
    );
  }

  @override
  Future<FontAsset> createFontAsset(String family, int weight, String source) async {
    final id = 'font_${family.toLowerCase()}_$weight';

    return FontAsset(
      id: id,
      name: family,
      source: source,
      family: family,
      weight: weight,
    );
  }

  String _bytesToBase64(Uint8List bytes) {
    // Simple base64 encoding - in production use dart:convert
    return bytes.toString(); // Placeholder
  }

  String _getMimeType(String filename) {
    final ext = filename.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'svg':
        return 'image/svg+xml';
      default:
        return 'application/octet-stream';
    }
  }
}