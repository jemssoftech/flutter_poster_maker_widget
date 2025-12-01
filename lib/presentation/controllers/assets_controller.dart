import 'dart:typed_data';

import 'package:get/get.dart';

import '../../core/utils/id_generator.dart';
import '../../core/constants/editor_constants.dart';
import '../../data/models/assets/image_asset.dart';
import '../../data/models/assets/font_asset.dart';
import '../../data/models/assets/svg_asset.dart';
import '../../data/models/assets/asset_manifest.dart';
import '../../data/repositories/asset_repository.dart';
import 'poster_controller.dart';

/// Sticker pack model
class StickerPack {
  final String id;
  final String name;
  final String? thumbnailUrl;
  final List<SvgAsset> stickers;
  final bool isExpanded;

  const StickerPack({
    required this.id,
    required this.name,
    this.thumbnailUrl,
    this.stickers = const [],
    this.isExpanded = false,
  });

  StickerPack copyWith({
    String? id,
    String? name,
    String? thumbnailUrl,
    List<SvgAsset>? stickers,
    bool? isExpanded,
  }) {
    return StickerPack(
      id: id ?? this.id,
      name: name ?? this.name,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      stickers: stickers ?? this.stickers,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}

/// Controller for asset management
class AssetsController extends GetxController {
  final AssetRepository _repository;

  AssetsController({required AssetRepository repository})
      : _repository = repository;

  // ==================== Reactive State ====================

  /// Image assets
  final RxMap<String, ImageAsset> images = <String, ImageAsset>{}.obs;

  /// Font assets
  final RxMap<String, FontAsset> fonts = <String, FontAsset>{}.obs;

  /// SVG assets
  final RxMap<String, SvgAsset> svgs = <String, SvgAsset>{}.obs;

  /// Sticker packs
  final RxList<StickerPack> stickerPacks = <StickerPack>[].obs;

  /// Loading state
  final RxBool isLoading = false.obs;

  /// Upload progress (0.0 to 1.0)
  final RxDouble uploadProgress = 0.0.obs;

  /// Recent uploads (for quick access)
  final RxList<String> recentImageIds = <String>[].obs;

  /// Recently used fonts
  final RxList<String> recentFontIds = <String>[].obs;

  // ==================== Getters ====================

  /// Get all images as list
  List<ImageAsset> get imageList => images.values.toList();

  /// Get all fonts as list
  List<FontAsset> get fontList => fonts.values.toList();

  /// Get all SVGs as list
  List<SvgAsset> get svgList => svgs.values.toList();

  /// Get recent images
  List<ImageAsset> get recentImages {
    return recentImageIds
        .map((id) => images[id])
        .whereType<ImageAsset>()
        .toList();
  }

  /// Get recent fonts
  List<FontAsset> get recentFonts {
    return recentFontIds
        .map((id) => fonts[id])
        .whereType<FontAsset>()
        .toList();
  }

  /// Check if has images
  bool get hasImages => images.isNotEmpty;

  /// Check if has fonts
  bool get hasFonts => fonts.isNotEmpty;

  /// Check if has SVGs
  bool get hasSvgs => svgs.isNotEmpty;

  /// Total asset count
  int get totalAssetCount => images.length + fonts.length + svgs.length;

  // ==================== Asset Access ====================

  /// Get image by ID
  ImageAsset? getImage(String id) => images[id];

  /// Get font by ID
  FontAsset? getFont(String id) => fonts[id];

  /// Get SVG by ID
  SvgAsset? getSvg(String id) => svgs[id];

  /// Get any asset by ID
  dynamic getAsset(String id) {
    return images[id] ?? fonts[id] ?? svgs[id];
  }

  /// Check if asset exists
  bool hasAsset(String id) {
    return images.containsKey(id) ||
        fonts.containsKey(id) ||
        svgs.containsKey(id);
  }

  // ==================== Image Operations ====================

  /// Add image from bytes
  Future<ImageAsset?> addImageFromBytes(
      Uint8List bytes,
      String filename,
      ) async {
    if (bytes.length > EditorConstants.maxImageSizeBytes) {
      // Image too large
      return null;
    }

    isLoading.value = true;
    uploadProgress.value = 0.0;

    try {
      final asset = await _repository.loadImageFromBytes(bytes, filename);

      images[asset.id] = asset;
      _addToRecentImages(asset.id);
      _syncToDocument();

      uploadProgress.value = 1.0;
      return asset;
    } catch (e) {
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Add image from base64
  Future<ImageAsset?> addImageFromBase64(
      String base64Data,
      String filename,
      ) async {
    isLoading.value = true;

    try {
      final asset = await _repository.loadImageFromBase64(base64Data, filename);

      images[asset.id] = asset;
      _addToRecentImages(asset.id);
      _syncToDocument();

      return asset;
    } catch (e) {
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Remove image
  void removeImage(String id) {
    images.remove(id);
    recentImageIds.remove(id);
    _syncToDocument();
  }

  void _addToRecentImages(String id) {
    recentImageIds.remove(id);
    recentImageIds.insert(0, id);

    // Keep only last 10
    if (recentImageIds.length > 10) {
      recentImageIds.removeRange(10, recentImageIds.length);
    }
  }

  // ==================== SVG Operations ====================

  /// Add SVG from string
  Future<SvgAsset?> addSvgFromString(String svgData, String name) async {
    if (svgData.length > EditorConstants.maxSvgSizeBytes) {
      return null;
    }

    isLoading.value = true;

    try {
      final asset = await _repository.loadSvgFromString(svgData, name);

      svgs[asset.id] = asset;
      _syncToDocument();

      return asset;
    } catch (e) {
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Remove SVG
  void removeSvg(String id) {
    svgs.remove(id);
    _syncToDocument();
  }

  // ==================== Font Operations ====================

  /// Add font asset
  Future<FontAsset?> addFont(
      String family,
      int weight, {
        String source = 'google_fonts',
      }) async {
    try {
      final asset = await _repository.createFontAsset(family, weight, source);

      fonts[asset.id] = asset;
      _addToRecentFonts(asset.id);
      _syncToDocument();

      return asset;
    } catch (e) {
      return null;
    }
  }

  /// Remove font
  void removeFont(String id) {
    fonts.remove(id);
    recentFontIds.remove(id);
    _syncToDocument();
  }

  void _addToRecentFonts(String id) {
    recentFontIds.remove(id);
    recentFontIds.insert(0, id);

    // Keep only last 10
    if (recentFontIds.length > 10) {
      recentFontIds.removeRange(10, recentFontIds.length);
    }
  }

  /// Get font by family and weight
  FontAsset? getFontByFamilyWeight(String family, int weight) {
    final id = 'font_${family.toLowerCase()}_$weight';
    return fonts[id];
  }

  // ==================== Sticker Packs ====================

  /// Load sticker packs
  Future<void> loadStickerPacks() async {
    isLoading.value = true;

    try {
      // In real implementation, load from API or local assets
      // For now, create sample packs
      stickerPacks.assignAll([
        StickerPack(
          id: 'emoji_basic',
          name: 'Basic Emoji',
          stickers: [],
        ),
        StickerPack(
          id: 'shapes_basic',
          name: 'Basic Shapes',
          stickers: [],
        ),
        StickerPack(
          id: 'decorative',
          name: 'Decorative',
          stickers: [],
        ),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  /// Toggle sticker pack expansion
  void toggleStickerPack(String packId) {
    final index = stickerPacks.indexWhere((p) => p.id == packId);
    if (index < 0) return;

    stickerPacks[index] = stickerPacks[index].copyWith(
      isExpanded: !stickerPacks[index].isExpanded,
    );
  }

  /// Get sticker from pack
  SvgAsset? getStickerFromPack(String packId, String stickerId) {
    final pack = stickerPacks.firstWhereOrNull((p) => p.id == packId);
    return pack?.stickers.firstWhereOrNull((s) => s.id == stickerId);
  }

  // ==================== Bulk Operations ====================

  /// Load assets from document
  void loadFromManifest(AssetManifest manifest) {
    images.assignAll(manifest.images);
    fonts.assignAll(manifest.fonts);
    svgs.assignAll(manifest.svgs);
  }

  /// Get current manifest
  AssetManifest getManifest() {
    return AssetManifest(
      images: Map.from(images),
      fonts: Map.from(fonts),
      svgs: Map.from(svgs),
    );
  }

  /// Clear all assets
  void clearAll() {
    images.clear();
    fonts.clear();
    svgs.clear();
    recentImageIds.clear();
    recentFontIds.clear();
  }

  /// Remove unused assets (not referenced by any layer)
  void removeUnusedAssets(Set<String> usedAssetIds) {
    images.removeWhere((key, _) => !usedAssetIds.contains(key));
    fonts.removeWhere((key, _) => !usedAssetIds.contains(key));
    svgs.removeWhere((key, _) => !usedAssetIds.contains(key));
    _syncToDocument();
  }

  // ==================== Sync ====================

  /// Sync assets to PosterController
  void _syncToDocument() {
    if (Get.isRegistered<PosterController>()) {
      final posterController = Get.find<PosterController>();
      if (posterController.hasDocument) {
        posterController.updateDocument(
              (doc) => doc.copyWith(assets: getManifest()),
        );
      }
    }
  }

  @override
  void onClose() {
    clearAll();
    super.onClose();
  }
}