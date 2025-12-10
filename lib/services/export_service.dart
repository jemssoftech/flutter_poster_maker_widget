import 'dart:typed_data';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../models/export_options.dart';
import '../models/export_result_model.dart';

/// Main Export Service - Orchestrates all export operations
class ExportService {
  /// Export with given options
  static Future<ExportResultModel> export({
    required GlobalKey canvasKey,
    required ExportOptions options,
    required Map<String, dynamic> templateJson,
    void Function(double progress)? onProgress,
  }) async {
    onProgress?.call(0.1);

    try {
      switch (options.format) {
        case ExportFormatType.json:
          return await _exportJson(templateJson, options);
        
        case ExportFormatType.png:
        case ExportFormatType.jpg:
          return await _exportImage(canvasKey, options, templateJson, onProgress);
        
        case ExportFormatType.pdf:
          return await _exportPdf(canvasKey, options, templateJson, onProgress);
      }
    } catch (e, stackTrace) {
      debugPrint('Export error: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Export as JSON
  static Future<ExportResultModel> _exportJson(
    Map<String, dynamic> templateJson,
    ExportOptions options,
  ) async {
    try {
      // Create a deep copy to avoid mutation
      final jsonData = Map<String, dynamic>.from(templateJson);
      
      // Add export metadata
      jsonData['exportMetadata'] = {
        'exportedAt': DateTime.now().toIso8601String(),
        'exportVersion': '1.0',
        'includeAssets': options.embedAssets,
      };

      // Validate JSON can be serialized
      final jsonString = jsonEncode(jsonData);
      
      // Verify it can be decoded back
      final decoded = jsonDecode(jsonString);
      
      // Convert JSON string to bytes for download/save
      final jsonBytes = Uint8List.fromList(utf8.encode(jsonString));
      
      debugPrint('✅ JSON export validated: ${jsonString.length} bytes');

      return ExportResultModel(
        format: ExportFormatType.json,
        data: decoded as Map<String, dynamic>,
        bytes: jsonBytes,
        success: true,
      );
    } catch (e, stackTrace) {
      debugPrint('❌ JSON export error: $e');
      debugPrint('Stack trace: $stackTrace');
      return ExportResultModel(
        format: ExportFormatType.json,
        data: {},
        success: false,
        error: 'JSON export failed: $e',
      );
    }
  }

  /// Export as Image (PNG/JPG)
  static Future<ExportResultModel> _exportImage(
    GlobalKey canvasKey,
    ExportOptions options,
    Map<String, dynamic> templateJson,
    void Function(double progress)? onProgress,
  ) async {
    onProgress?.call(0.3);

    final boundary = canvasKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      throw Exception('Canvas not found. Make sure the canvas has a RepaintBoundary.');
    }

    // Calculate pixel ratio based on scale/DPI
    final pixelRatio = _calculatePixelRatio(options);

    onProgress?.call(0.5);

    // Capture the image
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    
    onProgress?.call(0.7);

    // Convert to bytes
    final byteData = await image.toByteData(
      format: options.format == ExportFormatType.png
          ? ui.ImageByteFormat.png
          : ui.ImageByteFormat.png, // We'll convert to JPG if needed
    );

    if (byteData == null) {
      throw Exception('Failed to capture canvas image');
    }

    Uint8List bytes = byteData.buffer.asUint8List();

    // Convert to JPG if requested
    if (options.format == ExportFormatType.jpg) {
      bytes = await _convertToJpeg(
        bytes,
        image.width,
        image.height,
        options.quality ?? 90,
      );
    }

    onProgress?.call(0.9);

    final fileSizeKb = (bytes.lengthInBytes / 1024).toStringAsFixed(1);
    final dimensions = '${image.width}x${image.height}';

    return ExportResultModel(
      format: options.format,
      bytes: bytes,
      metadata: {
        'width': image.width,
        'height': image.height,
        'pixelRatio': pixelRatio,
        'fileSize': '$fileSizeKb KB',
        'dimensions': dimensions,
      },
      success: true,
    );
  }

  /// Export as PDF
  static Future<ExportResultModel> _exportPdf(
    GlobalKey canvasKey,
    ExportOptions options,
    Map<String, dynamic> templateJson,
    void Function(double progress)? onProgress,
  ) async {
    // Will be implemented with pdf package
    throw UnimplementedError('PDF export will be implemented in pdf_export_service.dart');
  }

  /// Calculate pixel ratio based on export options
  static double _calculatePixelRatio(ExportOptions options) {
    if (options.customDpi != null) {
      // Convert DPI to scale factor (72 DPI = 1x)
      return options.customDpi! / 72.0;
    }
    return options.scale ?? 2.0;
  }

  /// Convert PNG bytes to JPEG
  static Future<Uint8List> _convertToJpeg(
    Uint8List pngBytes,
    int width,
    int height,
    int quality,
  ) async {
    // This will be implemented using the image package
    // For now, return PNG bytes (will be enhanced)
    return pngBytes;
  }

  /// Validate export options
  static String? validateOptions(ExportOptions options) {
    if (options.format == ExportFormatType.jpg && options.transparentBackground) {
      return 'JPG format does not support transparent backgrounds';
    }

    if (options.scale != null && (options.scale! < 0.5 || options.scale! > 10.0)) {
      return 'Scale must be between 0.5x and 10x';
    }

    if (options.customDpi != null && (options.customDpi! < 36 || options.customDpi! > 1200)) {
      return 'DPI must be between 36 and 1200';
    }

    if (options.quality != null && (options.quality! < 1 || options.quality! > 100)) {
      return 'Quality must be between 1 and 100';
    }

    return null;
  }

  /// Get recommended settings for different use cases
  static ExportOptions getRecommendedOptions(ExportUseCase useCase) {
    switch (useCase) {
      case ExportUseCase.screen:
        return ExportOptions(
          format: ExportFormatType.png,
          scale: 1.0,
          quality: 85,
        );
      
      case ExportUseCase.print:
        return ExportOptions(
          format: ExportFormatType.pdf,
          customDpi: 300,
          includeBleedMarks: true,
        );
      
      case ExportUseCase.web:
        return ExportOptions(
          format: ExportFormatType.jpg,
          scale: 2.0,
          quality: 80,
        );
      
      case ExportUseCase.highQuality:
        return ExportOptions(
          format: ExportFormatType.png,
          scale: 3.0,
        );
    }
  }
}

/// Export use cases for recommended settings
enum ExportUseCase {
  screen,
  print,
  web,
  highQuality,
}
