import 'package:get/get.dart';

import '../../data/repositories/poster_repository.dart';
import '../../data/repositories/asset_repository.dart';
import '../../domain/services/undo_redo_service.dart';
import '../../domain/services/alignment_service.dart';
import '../../domain/services/transform_service.dart';
import '../../domain/services/clipboard_service.dart';
import '../controllers/poster_controller.dart';
import '../controllers/layer_controller.dart';
import '../controllers/selection_controller.dart';
import '../controllers/transform_controller.dart';
import '../controllers/canvas_controller.dart';
import '../controllers/tool_controller.dart';
import '../controllers/ui_controller.dart';
import '../controllers/assets_controller.dart';
import '../controllers/font_controller.dart';
import '../controllers/svg_controller.dart';
import '../controllers/history_controller.dart';
import '../controllers/export_controller.dart';

/// Main binding for the Poster Editor
/// Initializes all dependencies and controllers
class EditorBinding extends Bindings {
  @override
  void dependencies() {
    // ==================== Services ====================

    // Undo/Redo Service
    Get.lazyPut<UndoRedoService>(
          () => UndoRedoService(maxHistorySize: 50),
      fenix: true,
    );

    // Alignment Service
    Get.lazyPut<AlignmentService>(
          () => AlignmentService(),
      fenix: true,
    );

    // Transform Service
    Get.lazyPut<TransformService>(
          () => TransformService(),
      fenix: true,
    );

    // Clipboard Service
    Get.lazyPut<ClipboardService>(
          () => ClipboardService(),
      fenix: true,
    );

    // ==================== Repositories ====================

    // Poster Repository
    Get.lazyPut<PosterRepository>(
          () => PosterRepositoryImpl(),
      fenix: true,
    );

    // Asset Repository
    Get.lazyPut<AssetRepository>(
          () => AssetRepositoryImpl(),
      fenix: true,
    );

    // ==================== Controllers ====================

    // Poster Controller (main document state)
    Get.put<PosterController>(
      PosterController(repository: Get.find<PosterRepository>()),
      permanent: true,
    );

    // Layer Controller
    Get.put<LayerController>(
      LayerController(),
      permanent: true,
    );

    // Selection Controller
    Get.put<SelectionController>(
      SelectionController(),
      permanent: true,
    );

    // Canvas Controller
    Get.put<CanvasController>(
      CanvasController(),
      permanent: true,
    );

    // Tool Controller
    Get.put<ToolController>(
      ToolController(),
      permanent: true,
    );

    // UI Controller
    Get.put<UIController>(
      UIController(),
      permanent: true,
    );

    // Transform Controller
    Get.put<TransformController>(
      TransformController(
        transformService: Get.find<TransformService>(),
        alignmentService: Get.find<AlignmentService>(),
      ),
      permanent: true,
    );

    // Assets Controller
    Get.put<AssetsController>(
      AssetsController(repository: Get.find<AssetRepository>()),
      permanent: true,
    );

    // Font Controller
    Get.put<FontController>(
      FontController(),
      permanent: true,
    );

    // SVG Controller
    Get.put<SvgController>(
      SvgController(),
      permanent: true,
    );

    // History Controller
    Get.put<HistoryController>(
      HistoryController(undoRedoService: Get.find<UndoRedoService>()),
      permanent: true,
    );

    // Export Controller
    Get.put<ExportController>(
      ExportController(),
      permanent: true,
    );
  }
}