import 'dart:typed_data';

import 'package:get/get.dart';

import '../../data/models/export/export_config.dart';
import '../../data/models/poster_document.dart';
import 'poster_controller.dart';

/// Export state
enum ExportState {
  idle,
  preparing,
  rendering,
  encoding,
  complete,
  error,
}

/// Controller for export operations
class ExportController extends GetxController {
  // ==================== Reactive State ====================

  /// Current export state
  final Rx<ExportState> state = ExportState.idle.obs;

  /// Export progress (0.0 to 1.0)
  final RxDouble progress = 0.0.obs;

  /// Export status message
  final RxString statusMessage = ''.obs;

  /// Selected export format
  final Rx<ExportFormat> selectedFormat = ExportFormat.png.obs;

  /// Selected DPI
  final RxInt selectedDpi = 300.obs;

  /// Selected quality (for JPEG)
  final RxInt selectedQuality = 90.obs;

  /// Include background
  final RxBool includeBackground = true.obs;

  /// Include bleed area
  final RxBool includeBleed = false.obs;

  /// Current export config
  final Rx<ExportConfig> config = Rx<ExportConfig>(ExportConfig.defaultPng);

  /// Last export result
  final Rx<Uint8List?> lastExportResult = Rx<Uint8List?>(null);

  /// Last export error
  final Rx<String?> lastError = Rx<String?>(null);

  // ==================== Getters ====================

  /// Check if export is in progress
  bool get isExporting =>
      state.value != ExportState.idle &&
          state.value != ExportState.complete &&
          state.value != ExportState.error;

  /// Check if export is complete
  bool get isComplete => state.value == ExportState.complete;

  /// Check if export failed
  bool get hasError => state.value == ExportState.error;

  /// Get progress percentage
  int get progressPercentage => (progress.value * 100).round();

  /// Get current export config
  ExportConfig get currentConfig {
    return ExportConfig(
      format: selectedFormat.value,
      dpi: selectedDpi.value,
      quality: selectedQuality.value,
      includeBackground: includeBackground.value,
      includeBleed: includeBleed.value,
    );
  }

  // ==================== Configuration ====================

  /// Set export format
  void setFormat(ExportFormat format) {
    selectedFormat.value = format;
    _updateConfig();
  }

  /// Set export DPI
  void setDpi(int dpi) {
    selectedDpi.value = dpi.clamp(72, 600);
    _updateConfig();
  }

  /// Set export quality (for JPEG)
  void setQuality(int quality) {
    selectedQuality.value = quality.clamp(1, 100);
    _updateConfig();
  }

  /// Toggle background inclusion
  void toggleIncludeBackground() {
    includeBackground.value = !includeBackground.value;
    _updateConfig();
  }

  /// Toggle bleed inclusion
  void toggleIncludeBleed() {
    includeBleed.value = !includeBleed.value;
    _updateConfig();
  }

  /// Set full export config
  void setConfig(ExportConfig config) {
    this.config.value = config;
    selectedFormat.value = config.format;
    selectedDpi.value = config.dpi;
    selectedQuality.value = config.quality;
    includeBackground.value = config.includeBackground;
    includeBleed.value = config.includeBleed;
  }

  /// Use preset config
  void usePreset(ExportConfig preset) {
    setConfig(preset);
  }

  void _updateConfig() {
    config.value = currentConfig;
  }

  // ==================== Export Operations ====================

  /// Export to PNG
  Future<Uint8List?> exportToPng({int? dpi}) async {
    return _export(ExportFormat.png, dpi: dpi);
  }

  /// Export to JPEG
  Future<Uint8List?> exportToJpeg({int? dpi, int? quality}) async {
    if (quality != null) {
      selectedQuality.value = quality;
    }
    return _export(ExportFormat.jpeg, dpi: dpi);
  }

  /// Export to PDF
  Future<Uint8List?> exportToPdf({int? dpi}) async {
    return _export(ExportFormat.pdf, dpi: dpi);
  }

  /// Export to JSON
  Future<String?> exportToJson() async {
    if (!Get.isRegistered<PosterController>()) return null;

    final posterController = Get.find<PosterController>();
    return posterController.saveToJson(pretty: true);
  }

  /// Main export method
  Future<Uint8List?> _export(ExportFormat format, {int? dpi}) async {
    if (isExporting) return null;
    if (!Get.isRegistered<PosterController>()) return null;

    final posterController = Get.find<PosterController>();
    if (!posterController.hasDocument) return null;

    // Reset state
    state.value = ExportState.preparing;
    progress.value = 0.0;
    statusMessage.value = 'Preparing export...';
    lastError.value = null;
    lastExportResult.value = null;

    try {
      // Update format and DPI if provided
      selectedFormat.value = format;
      if (dpi != null) {
        selectedDpi.value = dpi;
      }
      _updateConfig();

      // Simulate export stages
      // In real implementation, this would render the canvas

      // Stage 1: Preparing
      await _updateProgress(0.1, 'Preparing canvas...');

      // Stage 2: Rendering layers
      state.value = ExportState.rendering;
      final document = posterController.document!;

      for (int i = 0; i < document.layers.length; i++) {
        final layerProgress = 0.1 + (0.7 * (i + 1) / document.layers.length);
        await _updateProgress(
          layerProgress,
          'Rendering layer ${i + 1} of ${document.layers.length}...',
        );
      }

      // Stage 3: Encoding
      state.value = ExportState.encoding;
      await _updateProgress(0.9, 'Encoding ${format.displayName}...');

      // Simulate final encoding
      await Future.delayed(const Duration(milliseconds: 300));

      // In real implementation, return actual bytes
      // For now, return empty placeholder
      final result = Uint8List(0);

      await _updateProgress(1.0, 'Export complete!');
      state.value = ExportState.complete;
      lastExportResult.value = result;

      return result;
    } catch (e) {
      state.value = ExportState.error;
      statusMessage.value = 'Export failed';
      lastError.value = e.toString();
      return null;
    }
  }

  Future<void> _updateProgress(double value, String message) async {
    progress.value = value;
    statusMessage.value = message;
    // Small delay to allow UI to update
    await Future.delayed(const Duration(milliseconds: 50));
  }

  /// Cancel current export
  void cancelExport() {
    if (isExporting) {
      state.value = ExportState.idle;
      progress.value = 0.0;
      statusMessage.value = 'Export cancelled';
    }
  }

  /// Reset export state
  void reset() {
    state.value = ExportState.idle;
    progress.value = 0.0;
    statusMessage.value = '';
    lastError.value = null;
    lastExportResult.value = null;
  }

  // ==================== Export Size Calculation ====================

  /// Calculate output dimensions
  Map<String, int> calculateOutputSize() {
    if (!Get.isRegistered<PosterController>()) {
      return {'width': 0, 'height': 0};
    }

    final posterController = Get.find<PosterController>();
    final canvasSize = posterController.canvasSize;

    final config = currentConfig;
    final width = config.calculateWidth(canvasSize.width);
    final height = config.calculateHeight(canvasSize.height);

    return {
      'width': width,
      'height': height,
    };
  }

  /// Get estimated file size
  String get estimatedFileSize {
    final dimensions = calculateOutputSize();
    final pixels = dimensions['width']! * dimensions['height']!;

    // Rough estimates
    int bytes;
    switch (selectedFormat.value) {
      case ExportFormat.png:
        bytes = (pixels * 4 * 0.5).round(); // Compressed
        break;
      case ExportFormat.jpeg:
        bytes = (pixels * 3 * (selectedQuality.value / 100) * 0.3).round();
        break;
      case ExportFormat.pdf:
        bytes = (pixels * 0.1).round(); // Vector, much smaller
        break;
      default:
        bytes = 0;
    }

    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  // ==================== Available Options ====================

  /// Available DPI options
  List<int> get dpiOptions => [72, 150, 300, 600];

  /// Available format options
  List<ExportFormat> get formatOptions => [
    ExportFormat.png,
    ExportFormat.jpeg,
    ExportFormat.pdf,
  ];

  /// Available quality presets
  Map<String, int> get qualityPresets => {
    'Low': 60,
    'Medium': 80,
    'High': 90,
    'Maximum': 100,
  };

  @override
  void onClose() {
    reset();
    super.onClose();
  }
}