import 'package:get/get.dart';

/// Font category enum
enum FontCategory {
  all,
  serif,
  sansSerif,
  display,
  handwriting,
  monospace,
}

/// Extension for FontCategory
extension FontCategoryExtension on FontCategory {
  String get displayName {
    switch (this) {
      case FontCategory.all:
        return 'All';
      case FontCategory.serif:
        return 'Serif';
      case FontCategory.sansSerif:
        return 'Sans Serif';
      case FontCategory.display:
        return 'Display';
      case FontCategory.handwriting:
        return 'Handwriting';
      case FontCategory.monospace:
        return 'Monospace';
    }
  }
}

/// Google Font family model
class GoogleFontFamily {
  final String family;
  final List<int> weights;
  final FontCategory category;
  final String? previewUrl;

  const GoogleFontFamily({
    required this.family,
    this.weights = const [400, 700],
    this.category = FontCategory.sansSerif,
    this.previewUrl,
  });
}

/// Controller for font management
class FontController extends GetxController {
  // ==================== Reactive State ====================

  /// Available Google Fonts
  final RxList<GoogleFontFamily> availableFonts = <GoogleFontFamily>[].obs;

  /// Loaded font families (cached)
  final RxSet<String> loadedFamilies = <String>{}.obs;

  /// Loading fonts
  final RxSet<String> loadingFonts = <String>{}.obs;

  /// Is loading font list
  final RxBool isLoadingFontList = false.obs;

  /// Search query
  final RxString searchQuery = ''.obs;

  /// Selected category filter
  final Rx<FontCategory> selectedCategory = FontCategory.all.obs;

  /// Recently used fonts
  final RxList<String> recentFonts = <String>[].obs;

  /// Favorite fonts
  final RxList<String> favoriteFonts = <String>[].obs;

  // ==================== Getters ====================

  /// Get filtered fonts
  List<GoogleFontFamily> get filteredFonts {
    var result = availableFonts.toList();

    // Filter by category
    if (selectedCategory.value != FontCategory.all) {
      result = result
          .where((f) => f.category == selectedCategory.value)
          .toList();
    }

    // Filter by search
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      result = result
          .where((f) => f.family.toLowerCase().contains(query))
          .toList();
    }

    return result;
  }

  /// Get recent font families
  List<GoogleFontFamily> get recentFontFamilies {
    return recentFonts
        .map((family) => availableFonts.firstWhereOrNull(
          (f) => f.family == family,
    ))
        .whereType<GoogleFontFamily>()
        .toList();
  }

  /// Get favorite font families
  List<GoogleFontFamily> get favoriteFontFamilies {
    return favoriteFonts
        .map((family) => availableFonts.firstWhereOrNull(
          (f) => f.family == family,
    ))
        .whereType<GoogleFontFamily>()
        .toList();
  }

  // ==================== Font Loading ====================

  /// Initialize and load font list
  @override
  void onInit() {
    super.onInit();
    loadFontList();
  }

  /// Load available fonts list
  Future<void> loadFontList() async {
    isLoadingFontList.value = true;

    try {
      // In real implementation, fetch from Google Fonts API
      // For now, use a static list of popular fonts
      availableFonts.assignAll(_getDefaultFonts());
    } finally {
      isLoadingFontList.value = false;
    }
  }

  /// Load a specific font family
  Future<bool> loadFont(String family, {int weight = 400}) async {
    final fontKey = '${family}_$weight';

    // Already loaded
    if (loadedFamilies.contains(fontKey)) {
      _addToRecent(family);
      return true;
    }

    // Already loading
    if (loadingFonts.contains(fontKey)) {
      return false;
    }

    loadingFonts.add(fontKey);

    try {
      // In real implementation, use google_fonts package
      // await GoogleFonts.getFont(family);

      // Simulate loading delay
      await Future.delayed(const Duration(milliseconds: 300));

      loadedFamilies.add(fontKey);
      _addToRecent(family);
      return true;
    } catch (e) {
      return false;
    } finally {
      loadingFonts.remove(fontKey);
    }
  }

  /// Check if font is loaded
  bool isFontLoaded(String family, {int weight = 400}) {
    return loadedFamilies.contains('${family}_$weight');
  }

  /// Check if font is loading
  bool isFontLoading(String family, {int weight = 400}) {
    return loadingFonts.contains('${family}_$weight');
  }

  /// Preload fonts used in document
  Future<void> preloadFontsForDocument(List<String> fontFamilies) async {
    for (final family in fontFamilies) {
      await loadFont(family);
    }
  }

  // ==================== Search & Filter ====================

  /// Set search query
  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  /// Clear search query
  void clearSearch() {
    searchQuery.value = '';
  }

  /// Set category filter
  void setCategory(FontCategory category) {
    selectedCategory.value = category;
  }

  // ==================== Recent & Favorites ====================

  void _addToRecent(String family) {
    recentFonts.remove(family);
    recentFonts.insert(0, family);

    // Keep only last 20
    if (recentFonts.length > 20) {
      recentFonts.removeRange(20, recentFonts.length);
    }
  }

  /// Toggle favorite status
  void toggleFavorite(String family) {
    if (favoriteFonts.contains(family)) {
      favoriteFonts.remove(family);
    } else {
      favoriteFonts.add(family);
    }
  }

  /// Check if font is favorite
  bool isFavorite(String family) {
    return favoriteFonts.contains(family);
  }

  // ==================== Font Info ====================

  /// Get font family info
  GoogleFontFamily? getFontFamily(String family) {
    return availableFonts.firstWhereOrNull((f) => f.family == family);
  }

  /// Get available weights for a font family
  List<int> getAvailableWeights(String family) {
    return getFontFamily(family)?.weights ?? [400, 700];
  }

  // ==================== Default Fonts ====================

  List<GoogleFontFamily> _getDefaultFonts() {
    return const [
      GoogleFontFamily(
        family: 'Roboto',
        weights: [100, 300, 400, 500, 700, 900],
        category: FontCategory.sansSerif,
      ),
      GoogleFontFamily(
        family: 'Open Sans',
        weights: [300, 400, 600, 700, 800],
        category: FontCategory.sansSerif,
      ),
      GoogleFontFamily(
        family: 'Lato',
        weights: [100, 300, 400, 700, 900],
        category: FontCategory.sansSerif,
      ),
      GoogleFontFamily(
        family: 'Montserrat',
        weights: [100, 200, 300, 400, 500, 600, 700, 800, 900],
        category: FontCategory.sansSerif,
      ),
      GoogleFontFamily(
        family: 'Poppins',
        weights: [100, 200, 300, 400, 500, 600, 700, 800, 900],
        category: FontCategory.sansSerif,
      ),
      GoogleFontFamily(
        family: 'Oswald',
        weights: [200, 300, 400, 500, 600, 700],
        category: FontCategory.sansSerif,
      ),
      GoogleFontFamily(
        family: 'Playfair Display',
        weights: [400, 500, 600, 700, 800, 900],
        category: FontCategory.serif,
      ),
      GoogleFontFamily(
        family: 'Merriweather',
        weights: [300, 400, 700, 900],
        category: FontCategory.serif,
      ),
      GoogleFontFamily(
        family: 'Lora',
        weights: [400, 500, 600, 700],
        category: FontCategory.serif,
      ),
      GoogleFontFamily(
        family: 'PT Serif',
        weights: [400, 700],
        category: FontCategory.serif,
      ),
      GoogleFontFamily(
        family: 'Dancing Script',
        weights: [400, 500, 600, 700],
        category: FontCategory.handwriting,
      ),
      GoogleFontFamily(
        family: 'Pacifico',
        weights: [400],
        category: FontCategory.handwriting,
      ),
      GoogleFontFamily(
        family: 'Satisfy',
        weights: [400],
        category: FontCategory.handwriting,
      ),
      GoogleFontFamily(
        family: 'Great Vibes',
        weights: [400],
        category: FontCategory.handwriting,
      ),
      GoogleFontFamily(
        family: 'Bebas Neue',
        weights: [400],
        category: FontCategory.display,
      ),
      GoogleFontFamily(
        family: 'Anton',
        weights: [400],
        category: FontCategory.display,
      ),
      GoogleFontFamily(
        family: 'Lobster',
        weights: [400],
        category: FontCategory.display,
      ),
      GoogleFontFamily(
        family: 'Permanent Marker',
        weights: [400],
        category: FontCategory.display,
      ),
      GoogleFontFamily(
        family: 'Fira Code',
        weights: [300, 400, 500, 600, 700],
        category: FontCategory.monospace,
      ),
      GoogleFontFamily(
        family: 'Source Code Pro',
        weights: [200, 300, 400, 500, 600, 700, 900],
        category: FontCategory.monospace,
      ),
      GoogleFontFamily(
        family: 'JetBrains Mono',
        weights: [100, 200, 300, 400, 500, 600, 700, 800],
        category: FontCategory.monospace,
      ),
    ];
  }

  @override
  void onClose() {
    availableFonts.clear();
    loadedFamilies.clear();
    loadingFonts.clear();
    recentFonts.clear();
    favoriteFonts.clear();
    super.onClose();
  }
}