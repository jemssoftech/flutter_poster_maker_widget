import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../../models/template_element.dart';
import '../../models/invoice_model.dart';

/// Main Editor Configuration - Like ProImageEditorConfigs
class InvoiceEditorConfigs {
  final CanvasConfig canvasConfig;
  final ToolbarConfig toolbarConfig;
  final LayerConfig layerConfig;
  final GridConfig gridConfig;
  final SnapConfig snapConfig;
  final ThemeConfig themeConfig;
  final ExportConfig exportConfig;
  final PlaceholderConfig placeholderConfig;

  const InvoiceEditorConfigs({
    this.canvasConfig = const CanvasConfig(),
    this.toolbarConfig = const ToolbarConfig(),
    this.layerConfig = const LayerConfig(),
    this.gridConfig = const GridConfig(),
    this.snapConfig = const SnapConfig(),
    this.themeConfig = const ThemeConfig(),
    this.exportConfig = const ExportConfig(),
    this.placeholderConfig = const PlaceholderConfig(),
  });

  InvoiceEditorConfigs copyWith({
    CanvasConfig? canvasConfig,
    ToolbarConfig? toolbarConfig,
    LayerConfig? layerConfig,
    GridConfig? gridConfig,
    SnapConfig? snapConfig,
    ThemeConfig? themeConfig,
    ExportConfig? exportConfig,
    PlaceholderConfig? placeholderConfig,
  }) {
    return InvoiceEditorConfigs(
      canvasConfig: canvasConfig ?? this.canvasConfig,
      toolbarConfig: toolbarConfig ?? this.toolbarConfig,
      layerConfig: layerConfig ?? this.layerConfig,
      gridConfig: gridConfig ?? this.gridConfig,
      snapConfig: snapConfig ?? this.snapConfig,
      themeConfig: themeConfig ?? this.themeConfig,
      exportConfig: exportConfig ?? this.exportConfig,
      placeholderConfig: placeholderConfig ?? this.placeholderConfig,
    );
  }
}

/// Canvas Configuration
class CanvasConfig {
  final Size defaultSize;
  final Color backgroundColor;
  final double minZoom;
  final double maxZoom;
  final bool showRulers;
  final bool showPageBorder;
  final EdgeInsets pagePadding;
  final PageSize pageSize;

  const CanvasConfig({
    this.defaultSize = const Size(595, 842), // A4
    this.backgroundColor = const Color(0xFFE0E0E0),
    this.minZoom = 0.25,
    this.maxZoom = 4.0,
    this.showRulers = false, // Default OFF per requirements
    this.showPageBorder = true,
    this.pagePadding = const EdgeInsets.all(40),
    this.pageSize = PageSize.a4,
  });
}

enum PageSize {
  a4(595, 842, 'A4'),
  a5(420, 595, 'A5'),
  letter(612, 792, 'Letter'),
  thermal58(164, 1000, 'POS 58mm'),
  thermal80(227, 1000, 'POS 80mm'),
  custom(0, 0, 'Custom');

  final double width;
  final double height;
  final String label;

  const PageSize(this.width, this.height, this.label);

  Size get size => Size(width, height);
}

/// Toolbar Configuration
class ToolbarConfig {
  final bool showMainToolbar;
  final bool showPropertiesPanel;
  final bool showLayersPanel;
  final ToolbarPosition toolbarPosition;
  final List<EditorTool> enabledTools;
  final double toolbarHeight;
  final double propertiesPanelWidth;
  final double layersPanelWidth;

  const ToolbarConfig({
    this.showMainToolbar = true,
    this.showPropertiesPanel = true,
    this.showLayersPanel = true,
    this.toolbarPosition = ToolbarPosition.top,
    this.enabledTools = EditorTool.values,
    this.toolbarHeight = 56,
    this.propertiesPanelWidth = 280,
    this.layersPanelWidth = 250,
  });
}

enum ToolbarPosition { top, bottom, left, right }

enum EditorTool {
  select,
  text,
  image,
  table,
  shape,
  background,
  qrCode,
  placeholder,
  signature,
  svg,
  productGrid,
}

/// Layer Configuration
class LayerConfig {
  final bool allowReorder;
  final bool allowLock;
  final bool allowHide;
  final bool allowGroup;
  final bool allowDuplicate;
  final double minLayerSize;
  final double defaultOpacity;

  const LayerConfig({
    this.allowReorder = true,
    this.allowLock = true,
    this.allowHide = true,
    this.allowGroup = true,
    this.allowDuplicate = true,
    this.minLayerSize = 20,
    this.defaultOpacity = 1.0,
  });
}

/// Grid Configuration
class GridConfig {
  final bool showGrid;
  final double gridSize;
  final Color gridColor;
  final double gridOpacity;
  final bool snapToGrid;

  const GridConfig({
    this.showGrid = false,
    this.gridSize = 10,
    this.gridColor = Colors.grey,
    this.gridOpacity = 0.3,
    this.snapToGrid = true,
  });
}

/// Snap Configuration
class SnapConfig {
  final bool enableSnap;
  final double snapThreshold;
  final bool snapToGuides;
  final bool snapToElements;
  final bool snapToCenter;
  final bool showSnapLines;
  final Color snapLineColor;

  const SnapConfig({
    this.enableSnap = true,
    this.snapThreshold = 8,
    this.snapToGuides = true,
    this.snapToElements = true,
    this.snapToCenter = true,
    this.showSnapLines = true,
    this.snapLineColor = Colors.pink,
  });
}

/// Theme Configuration
class ThemeConfig {
  final Color primaryColor;
  final Color accentColor;
  final Color selectionColor;
  final Color handleColor;
  final Brightness brightness;
  final double borderRadius;
  final EdgeInsets buttonPadding;

  const ThemeConfig({
    this.primaryColor = Colors.blue,
    this.accentColor = Colors.blueAccent,
    this.selectionColor = const Color(0xFF2196F3),
    this.handleColor = Colors.white,
    this.brightness = Brightness.light,
    this.borderRadius = 8,
    this.buttonPadding = const EdgeInsets.all(8),
  });
}

/// Export Configuration
class ExportConfig {
  final double exportScale;
  final bool includeBackground;
  final String defaultFormat;
  final int jpegQuality;

  const ExportConfig({
    this.exportScale = 2.0,
    this.includeBackground = true,
    this.defaultFormat = 'png',
    this.jpegQuality = 90,
  });
}

/// Placeholder Configuration - For Invoice Fields
class PlaceholderConfig {
  final Color placeholderColor;
  final Color placeholderBorderColor;
  final TextStyle placeholderTextStyle;
  final bool showPlaceholderHints;
  final Map<String, String> customPlaceholders;

  const PlaceholderConfig({
    this.placeholderColor = const Color(0xFFFFF3E0),
    this.placeholderBorderColor = const Color(0xFFFF9800),
    this.placeholderTextStyle = const TextStyle(
      color: Color(0xFFE65100),
      fontStyle: FontStyle.italic,
    ),
    this.showPlaceholderHints = true,
    this.customPlaceholders = const {},
  });
}


/// Editor Callbacks - Like ProImageEditorCallbacks
class InvoiceEditorCallbacks {
  /// Called when editing is complete
  final Future<void> Function(ExportResult result)? onExportComplete;

  /// Called when template is saved
  final Future<void> Function(Map<String, dynamic> templateJson)? onSaveTemplate;

  /// Called when invoice data is exported
  final Future<void> Function(Map<String, dynamic> invoiceJson)? onExportInvoice;

  /// Called when a layer is added
  final void Function(TemplateElement element)? onLayerAdded;

  /// Called when a layer is removed
  final void Function(String elementId)? onLayerRemoved;

  /// Called when a layer is modified
  final void Function(TemplateElement element)? onLayerModified;

  /// Called when selection changes
  final void Function(List<String> selectedIds)? onSelectionChanged;

  /// Called when undo/redo state changes
  final void Function(bool canUndo, bool canRedo)? onHistoryChanged;

  /// Called when zoom changes
  final void Function(double zoom)? onZoomChanged;

  /// Called before close - return false to prevent close
  final Future<bool> Function()? onCloseEditor;

  /// Called when error occurs
  final void Function(EditorError error)? onError;

  /// Called to load image
  final Future<Uint8List?> Function(String source)? onLoadImage;

  /// Called to pick image
  final Future<Uint8List?> Function()? onPickImage;

  const InvoiceEditorCallbacks({
    this.onExportComplete,
    this.onSaveTemplate,
    this.onExportInvoice,
    this.onLayerAdded,
    this.onLayerRemoved,
    this.onLayerModified,
    this.onSelectionChanged,
    this.onHistoryChanged,
    this.onZoomChanged,
    this.onCloseEditor,
    this.onError,
    this.onLoadImage,
    this.onPickImage,
  });
}

/// Export Result
class ExportResult {
  final Uint8List? imageBytes;
  final Map<String, dynamic> templateJson;
  final Map<String, dynamic>? filledInvoiceJson;
  final ExportFormat format;

  ExportResult({
    this.imageBytes,
    required this.templateJson,
    this.filledInvoiceJson,
    this.format = ExportFormat.png,
  });
}

enum ExportFormat { png, jpeg, pdf, json }

/// Editor Error
class EditorError {
  final String code;
  final String message;
  final dynamic details;

  EditorError({
    required this.code,
    required this.message,
    this.details,
  });

  @override
  String toString() => 'EditorError($code): $message';
}