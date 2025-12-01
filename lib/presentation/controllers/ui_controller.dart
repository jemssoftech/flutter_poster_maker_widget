import 'package:get/get.dart';

import '../../core/constants/editor_constants.dart';

/// Types of property panels
enum PropertyPanelType {
  none,
  text,
  image,
  svg,
  shape,
  transform,
  effects,
  alignment,
  canvas,
  export,
}

/// Extension for PropertyPanelType
extension PropertyPanelTypeExtension on PropertyPanelType {
  /// Get display name
  String get displayName {
    switch (this) {
      case PropertyPanelType.none:
        return '';
      case PropertyPanelType.text:
        return 'Text Properties';
      case PropertyPanelType.image:
        return 'Image Properties';
      case PropertyPanelType.svg:
        return 'SVG Properties';
      case PropertyPanelType.shape:
        return 'Shape Properties';
      case PropertyPanelType.transform:
        return 'Transform';
      case PropertyPanelType.effects:
        return 'Effects';
      case PropertyPanelType.alignment:
        return 'Alignment';
      case PropertyPanelType.canvas:
        return 'Canvas Settings';
      case PropertyPanelType.export:
        return 'Export';
    }
  }
}

/// Assets panel tab types
enum AssetsPanelTab {
  images,
  stickers,
  shapes,
  fonts,
}

/// Controller for UI state (panels, dialogs, layout)
class UIController extends GetxController {
  // ==================== Sidebar State ====================

  /// Whether layers sidebar is open
  final RxBool isLayersSidebarOpen = true.obs;

  /// Whether assets sidebar is open
  final RxBool isAssetsSidebarOpen = true.obs;

  /// Layers sidebar width
  final RxDouble layersSidebarWidth = EditorConstants.layersSidebarWidth.obs;

  /// Assets sidebar width
  final RxDouble assetsSidebarWidth = EditorConstants.assetsSidebarWidth.obs;

  // ==================== Property Panel State ====================

  /// Whether property panel is open
  final RxBool isPropertyPanelOpen = false.obs;

  /// Current property panel type
  final Rx<PropertyPanelType> activePropertyPanel = PropertyPanelType.none.obs;

  /// Property panel height (as fraction of screen, 0.0 to 1.0)
  final RxDouble propertyPanelHeight = EditorConstants.propertyPanelDefaultHeight.obs;

  // ==================== Assets Panel State ====================

  /// Current assets panel tab
  final Rx<AssetsPanelTab> activeAssetsTab = AssetsPanelTab.images.obs;

  /// Assets search query
  final RxString assetsSearchQuery = ''.obs;

  // ==================== Canvas Overlays ====================

  /// Show grid overlay
  final RxBool showGrid = false.obs;

  /// Show rulers
  final RxBool showRulers = false.obs;

  /// Show guide lines
  final RxBool showGuides = true.obs;

  /// Show safe zone
  final RxBool showSafeZone = false.obs;

  // ==================== View State ====================

  /// Fullscreen mode
  final RxBool isFullscreen = false.obs;

  /// Dark mode
  final RxBool isDarkMode = true.obs;

  /// Show layer thumbnails
  final RxBool showLayerThumbnails = true.obs;

  // ==================== Dialog State ====================

  /// Currently open dialog
  final Rx<String?> openDialog = Rx<String?>(null);

  /// Loading overlay visible
  final RxBool isLoadingOverlayVisible = false.obs;

  /// Loading overlay message
  final RxString loadingMessage = ''.obs;

  // ==================== Responsive Breakpoints ====================

  /// Current screen width
  final RxDouble screenWidth = 0.0.obs;

  /// Is mobile layout
  bool get isMobile => screenWidth.value < 600;

  /// Is tablet layout
  bool get isTablet => screenWidth.value >= 600 && screenWidth.value < 1200;

  /// Is desktop layout
  bool get isDesktop => screenWidth.value >= 1200;

  // ==================== Sidebar Methods ====================

  /// Toggle layers sidebar
  void toggleLayersSidebar() {
    isLayersSidebarOpen.value = !isLayersSidebarOpen.value;
  }

  /// Open layers sidebar
  void openLayersSidebar() {
    isLayersSidebarOpen.value = true;
  }

  /// Close layers sidebar
  void closeLayersSidebar() {
    isLayersSidebarOpen.value = false;
  }

  /// Toggle assets sidebar
  void toggleAssetsSidebar() {
    isAssetsSidebarOpen.value = !isAssetsSidebarOpen.value;
  }

  /// Open assets sidebar
  void openAssetsSidebar() {
    isAssetsSidebarOpen.value = true;
  }

  /// Close assets sidebar
  void closeAssetsSidebar() {
    isAssetsSidebarOpen.value = false;
  }

  /// Set layers sidebar width
  void setLayersSidebarWidth(double width) {
    layersSidebarWidth.value = width.clamp(180.0, 400.0);
  }

  /// Set assets sidebar width
  void setAssetsSidebarWidth(double width) {
    assetsSidebarWidth.value = width.clamp(200.0, 450.0);
  }

  // ==================== Property Panel Methods ====================

  /// Open property panel with specific type
  void openPropertyPanel(PropertyPanelType type) {
    activePropertyPanel.value = type;
    isPropertyPanelOpen.value = true;
  }

  /// Close property panel
  void closePropertyPanel() {
    isPropertyPanelOpen.value = false;
    // Keep the panel type for animation purposes
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!isPropertyPanelOpen.value) {
        activePropertyPanel.value = PropertyPanelType.none;
      }
    });
  }

  /// Toggle property panel
  void togglePropertyPanel(PropertyPanelType type) {
    if (isPropertyPanelOpen.value && activePropertyPanel.value == type) {
      closePropertyPanel();
    } else {
      openPropertyPanel(type);
    }
  }

  /// Set property panel height
  void setPropertyPanelHeight(double height) {
    propertyPanelHeight.value = height.clamp(
      EditorConstants.propertyPanelMinHeight,
      EditorConstants.propertyPanelMaxHeight,
    );
  }

  /// Open property panel for layer type
  void openPanelForLayerType(String layerType) {
    switch (layerType) {
      case 'text':
        openPropertyPanel(PropertyPanelType.text);
        break;
      case 'image':
        openPropertyPanel(PropertyPanelType.image);
        break;
      case 'svg':
        openPropertyPanel(PropertyPanelType.svg);
        break;
      case 'shape':
        openPropertyPanel(PropertyPanelType.shape);
        break;
      default:
        openPropertyPanel(PropertyPanelType.transform);
    }
  }

  // ==================== Assets Panel Methods ====================

  /// Set active assets tab
  void setAssetsTab(AssetsPanelTab tab) {
    activeAssetsTab.value = tab;
  }

  /// Set assets search query
  void setAssetsSearchQuery(String query) {
    assetsSearchQuery.value = query;
  }

  /// Clear assets search
  void clearAssetsSearch() {
    assetsSearchQuery.value = '';
  }

  // ==================== Overlay Methods ====================

  /// Toggle grid
  void toggleGrid() {
    showGrid.value = !showGrid.value;
  }

  /// Toggle rulers
  void toggleRulers() {
    showRulers.value = !showRulers.value;
  }

  /// Toggle guides
  void toggleGuides() {
    showGuides.value = !showGuides.value;
  }

  /// Toggle safe zone
  void toggleSafeZone() {
    showSafeZone.value = !showSafeZone.value;
  }

  // ==================== View Methods ====================

  /// Toggle fullscreen
  void toggleFullscreen() {
    isFullscreen.value = !isFullscreen.value;

    if (isFullscreen.value) {
      closeLayersSidebar();
      closeAssetsSidebar();
      closePropertyPanel();
    }
  }

  /// Exit fullscreen
  void exitFullscreen() {
    if (isFullscreen.value) {
      isFullscreen.value = false;
    }
  }

  /// Toggle dark mode
  void toggleDarkMode() {
    isDarkMode.value = !isDarkMode.value;
  }

  /// Toggle layer thumbnails
  void toggleLayerThumbnails() {
    showLayerThumbnails.value = !showLayerThumbnails.value;
  }

  // ==================== Dialog Methods ====================

  /// Open a dialog by ID
  void openDialogById(String dialogId) {
    openDialog.value = dialogId;
  }

  /// Close current dialog
  void closeDialog() {
    openDialog.value = null;
  }

  /// Check if specific dialog is open
  bool isDialogOpen(String dialogId) {
    return openDialog.value == dialogId;
  }

  // ==================== Loading Overlay ====================

  /// Show loading overlay
  void showLoading([String message = 'Loading...']) {
    loadingMessage.value = message;
    isLoadingOverlayVisible.value = true;
  }

  /// Hide loading overlay
  void hideLoading() {
    isLoadingOverlayVisible.value = false;
    loadingMessage.value = '';
  }

  /// Update loading message
  void updateLoadingMessage(String message) {
    loadingMessage.value = message;
  }

  // ==================== Responsive Layout ====================

  /// Update screen width
  void updateScreenWidth(double width) {
    screenWidth.value = width;

    // Auto-adjust layout for mobile
    if (isMobile) {
      closeLayersSidebar();
      closeAssetsSidebar();
    }
  }

  /// Get appropriate sidebar mode based on screen size
  bool get shouldShowSidebars => !isMobile;

  /// Get appropriate panel mode based on screen size
  bool get shouldUseBottomSheet => isMobile || isTablet;

  // ==================== Keyboard Shortcuts Info ====================

  /// Show keyboard shortcuts dialog
  void showKeyboardShortcuts() {
    openDialogById('keyboard_shortcuts');
  }

  // ==================== Reset ====================

  /// Reset all UI state to defaults
  void resetUI() {
    isLayersSidebarOpen.value = true;
    isAssetsSidebarOpen.value = true;
    isPropertyPanelOpen.value = false;
    activePropertyPanel.value = PropertyPanelType.none;
    propertyPanelHeight.value = EditorConstants.propertyPanelDefaultHeight;
    showGrid.value = false;
    showRulers.value = false;
    showGuides.value = true;
    showSafeZone.value = false;
    isFullscreen.value = false;
    openDialog.value = null;
    isLoadingOverlayVisible.value = false;
  }

  @override
  void onClose() {
    resetUI();
    super.onClose();
  }
}