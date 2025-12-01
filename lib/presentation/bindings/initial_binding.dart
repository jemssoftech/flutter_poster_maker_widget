import 'package:get/get.dart';
import 'package:flutter_poster_maker_widget/poster_editor.dart';
import 'editor_binding.dart';

/// Initial binding that sets up core dependencies
/// Use this when the app starts or when navigating to editor
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize all editor dependencies
    EditorBinding().dependencies();
  }
}

/// Utility class for manual initialization
class EditorDependencies {
  static bool _initialized = false;

  /// Initialize all editor dependencies manually
  static void init() {
    if (_initialized) return;

    InitialBinding().dependencies();
    _initialized = true;
  }

  /// Check if dependencies are initialized
  static bool get isInitialized => _initialized;

  /// Reset all controllers (useful for testing)
  static void reset() {
    if (!_initialized) return;

    // Delete all controllers in reverse order
    Get.delete<ExportController>(force: true);
    Get.delete<HistoryController>(force: true);
    Get.delete<SvgController>(force: true);
    Get.delete<FontController>(force: true);
    Get.delete<AssetsController>(force: true);
    Get.delete<TransformController>(force: true);
    Get.delete<UIController>(force: true);
    Get.delete<ToolController>(force: true);
    Get.delete<CanvasController>(force: true);
    Get.delete<SelectionController>(force: true);
    Get.delete<LayerController>(force: true);
    Get.delete<PosterController>(force: true);

    _initialized = false;
  }

  /// Reinitialize (reset and init)
  static void reinitialize() {
    reset();
    init();
  }
}