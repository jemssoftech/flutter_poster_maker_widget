import '../../../core/types/typedefs.dart';

/// Base class for all assets
abstract class AssetBase {
  /// Unique identifier
  final String id;

  /// Display name
  final String name;

  /// Source type (user_upload, url, builtin, etc.)
  final String source;

  const AssetBase({
    required this.id,
    required this.name,
    required this.source,
  });

  /// Convert to JSON
  JsonMap toJson();

  /// Get asset type identifier
  String get assetType;
}