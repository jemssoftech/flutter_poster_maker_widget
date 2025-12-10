import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart' hide TableCell;
import 'package:uuid/uuid.dart';
import '../models/background.elements.model.dart';
import '../models/svg_element.dart';
import '../models/template_element.dart' hide PageSize;
import '../models/invoice_model.dart';
import '../models/document_metadata.dart';
import '../models/page_model.dart';
import '../services/competitor_adapter_service.dart';
import '../utils/coordinate_transform.dart';
import '../widgets/signature_layer.dart';
import 'editor_configs.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
/// Main Editor Controller - Like ProImageEditorController
class InvoiceEditorController extends ChangeNotifier {
  final GlobalKey canvasKey = GlobalKey();
  // Configuration
  final InvoiceEditorConfigs configs;
  final InvoiceEditorCallbacks callbacks;

  // ==================== MULTI-PAGE SUPPORT ====================
  
  // Pages (new multi-page architecture)
  final List<PageModel> _pages = [];
  List<PageModel> get pages => List.unmodifiable(_pages);
  
  // Active page index
  int _activePageIndex = 0;
  int get activePageIndex => _activePageIndex;
  
  // Active page (with safety check and auto-recovery)
  PageModel get activePage {
    // FAILSAFE: If pages list is somehow empty, create a default page immediately
    if (_pages.isEmpty) {
      debugPrint('⚠️ CRITICAL: Pages list was empty, auto-recovering with blank page');
      _pages.add(PageModel.blank(name: 'Page 1'));
      _activePageIndex = 0;
    }
    
    // FAILSAFE: Ensure active page index is valid
    if (_activePageIndex >= _pages.length || _activePageIndex < 0) {
      debugPrint('⚠️ WARNING: Invalid activePageIndex=$_activePageIndex, resetting to 0');
      _activePageIndex = 0;
    }
    
    return _pages[_activePageIndex];
  }
  
  // Elements (backward compatible - returns active page's elements)
  List<TemplateElement> get elements {
    if (_pages.isEmpty) return [];
    return List.unmodifiable(activePage.elements);
  }

  // Selection
  final Set<String> _selectedIds = {};
  Set<String> get selectedIds => Set.unmodifiable(_selectedIds);
  List<TemplateElement> get selectedElements {
    if (_pages.isEmpty) return [];
    return activePage.elements.where((e) => _selectedIds.contains(e.id)).toList();
  }

  // History
  final List<EditorState> _undoStack = [];
  final List<EditorState> _redoStack = [];
  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;
  
  // Transaction state for batching operations (e.g., dragging)
  bool _isInTransaction = false;

  // Zoom & Pan
  double _zoom = 1.0;
  double get zoom => _zoom;
  Offset _panOffset = Offset.zero;
  Offset get panOffset => _panOffset;

  // Current Tool
  EditorTool _currentTool = EditorTool.select;
  EditorTool get currentTool => _currentTool;

  // Multi-Select Mode (for touch devices)
  bool _isMultiSelectMode = false;
  bool get isMultiSelectMode => _isMultiSelectMode;

  // Rulers & Grid state (per-document)
  bool _showRulers = false; // Default OFF per requirements
  bool get showRulers => _showRulers;
  
  bool _showGrid = false; // Default OFF per requirements
  bool get showGrid => _showGrid;
  
  bool _snapToGrid = false;
  bool get snapToGrid => _snapToGrid;

  // Active invoice data (for preview/fill)
  InvoiceDocument? _invoiceData;
  InvoiceDocument? get invoiceData => _invoiceData;

  // Template metadata
  String templateName = 'Untitled Template';
  String templateVersion = '1.0';
  PageSize pageSize = PageSize.a4;

  // Document coordinate system
  late DocumentMetadata _documentMetadata;
  DocumentMetadata get documentMetadata => _documentMetadata;

  // UUID generator
  final _uuid = const Uuid();

  InvoiceEditorController({
    required this.configs,
    required this.callbacks,
  }) {
    pageSize = configs.canvasConfig.pageSize;
    _documentMetadata = DocumentMetadata(
      width: pageSize.width,
      height: pageSize.height,
    );
    
    // Initialize UI states from configs
    _showRulers = configs.canvasConfig.showRulers;
    _showGrid = configs.gridConfig.showGrid;
    _snapToGrid = configs.gridConfig.snapToGrid;
    
    // Initialize with one blank page
    _pages.add(PageModel.blank(name: 'Page 1'));
  }

  /// Get coordinate transformer for current viewport
  CoordinateTransform getCoordinateTransform(Size viewportSize) {
    return CoordinateTransform(
      documentSize: _documentMetadata.size,
      viewportSize: viewportSize,
      zoom: _zoom,
      panOffset: _panOffset,
      fitMode: FitMode.contain,
    );
  }

  List<TemplateElement>? _clipboard;

  /// Copy selected elements
  void copySelected() {
    if (_selectedIds.isEmpty) return;
    _clipboard = selectedElements.map((e) => e.clone()).toList();
  }

  /// Cut selected elements
  void cutSelected() {
    copySelected();
    removeSelected();
  }

  /// Paste elements
  void paste({Offset? position}) {
    if (_clipboard == null || _clipboard!.isEmpty) return;

    _saveState();
    clearSelection();

    final offset = position ?? const Offset(20, 20);

    for (final element in _clipboard!) {
      final newElement = element.clone();
      newElement.position += offset;
      activePage.elements.add(newElement);
      _selectedIds.add(newElement.id);
      callbacks.onLayerAdded?.call(newElement);
    }

    notifyListeners();
  }

  SignatureElement addSignature({
    Offset? position,
    Size? size,
    String? placeholderKey,
  }) {
    // Use responsive sizing if not specified
    final defaultSize = size ?? _getResponsiveElementSize(
      widthPercent: 0.25,
      heightPercent: 0.08,
      minWidth: 100,
      maxWidth: 300,
    );
    
    // Center element at click position (already in document coordinates)
    final centeredPosition = position != null
        ? Offset(
            position.dx - defaultSize.width / 2,
            position.dy - defaultSize.height / 2,
          )
        : _getDefaultElementPosition(defaultSize);
    
    final element = SignatureElement(
      id: _uuid.v4(),
      name: 'Signature ${activePage.elements.length + 1}',
      position: centeredPosition,
      size: defaultSize,
      placeholderKey: placeholderKey,
    );
    addElement(element);
    selectElement(element.id);
    return element;
  }

  Future<Uint8List?> captureCanvas({
    double pixelRatio = 2.0, // Quality (1.0 = 72dpi, 2.0 = 144dpi, etc.)
    ui.ImageByteFormat format = ui.ImageByteFormat.png,
  }) async {
    try {
      // Ensure dummy data is loaded for export if no real data
      ensureInvoiceDataForExport();
      
      final boundary = canvasKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      // Capture image
      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: format);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error capturing canvas: $e');
      return null;
    }
  }

  void loadCompetitorJson(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString);

      // 1. Convert using Adapter (Ye safe format return karega)
      final myFormatData = CompetitorAdapterService.convertToMyAppFormat(decoded);

      // 2. Load into your existing variables
      // Maan lijiye aapka function hai loadTemplate(Map data)
      importTemplate(myFormatData);

      print("✅ Successfully imported using Best Effort strategy");

    } catch (e) {
      print("❌ Error importing: $e");
    }
  }
  void importSmartJson(Map<String, dynamic> finalTemplateData) {
    try {
      if (finalTemplateData.isEmpty) return;



      // 🕵️ DETECTION LOGIC
      // Competitor JSON में हमेशा 'data' -> 'posterBackendObject' होता है
      bool isCompetitor = finalTemplateData.containsKey('data') &&
          finalTemplateData['data'] is Map &&
          finalTemplateData['data'].containsKey('posterBackendObject');

      if (isCompetitor) {
        debugPrint("🚀 Mode: Competitor JSON Detected! Converting...");
        // Use Adapter to convert
        finalTemplateData = CompetitorAdapterService.convertToMyAppFormat(finalTemplateData);

      } else {
        // Assume it's our own format (Native)
        debugPrint("🏠 Mode: Native JSON Detected. Loading directly...");
      }

      // ✅ Final Step: Load into Editor
      importTemplate(finalTemplateData);

      debugPrint("✅ Import completed successfully!");

    } catch (e, stack) {
      debugPrint("❌ Import Failed: $e");
      debugPrint(stack.toString());
      // Optional: callbacks.onError?.call("Invalid File Format");
    }
  }
  /// Export as PDF (embeds high-res image)
  Future<Uint8List> exportAsPdf({double quality = 2.0}) async {
    // Ensure dummy data is loaded for export if no real data
    ensureInvoiceDataForExport();
    
    final pdf = pw.Document();

    // Capture canvas as PNG image
    final imageBytes = await captureCanvas(pixelRatio: quality);
    if (imageBytes == null) throw Exception('Failed to capture canvas');

    final image = pw.MemoryImage(imageBytes);

    // Add page matching the canvas size
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
            pageSize.width * PdfPageFormat.point,
            pageSize.height * PdfPageFormat.point
        ),
        margin: pw.EdgeInsets.zero, // Full bleed
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Image(image, fit: pw.BoxFit.contain),
          );
        },
      ),
    );

    return await pdf.save();
  }
  // ==================== ELEMENT MANAGEMENT ====================

  /// Add or replace background (on active page)
  BackgroundElement setBackground({
    String? imageUrl,
    Uint8List? imageBytes,
    String? presetId,
  }) {
    // Remove existing background from active page
    activePage.removeBackground();

    final pageSize = configs.canvasConfig.pageSize.size;

    final element = BackgroundElement(
      id: _uuid.v4(),
      name: 'Background',
      position: Offset.zero,
      size: pageSize,
      isLocked: true, // Always locked
      isVisible: true,
      zIndex: -1000, // Always at bottom
      imageUrl: imageUrl,
      imageBytes: imageBytes,
      presetId: presetId,
    );

    activePage.setBackground(element);
    callbacks.onLayerAdded?.call(element);
    notifyListeners();

    return element;
  }

  /// Remove background (from active page)
  void removeBackground() {
    final bgElement = activePage.elements.firstWhere(
          (e) => e is BackgroundElement,
      orElse: () => throw Exception('No background found'),
    );
    removeElement(bgElement.id);
  }

  /// Check if active page has background
  bool get hasBackground => activePage.hasBackground;

  /// Get background element from active page
  BackgroundElement? get backgroundElement => activePage.backgroundElement;
  SvgElement addSvgFromPreset(SvgPreset preset, {Offset? position, Size? size}) {
    final element = SvgElement.fromPreset(
      preset,
      id: _uuid.v4(),
      position: position ?? const Offset(100, 100),
      size: size ?? const Size(100, 100),
    );

    addElement(element);
    selectElement(element.id);
    return element;
  }
  Future<void> addSvgFromUrl(String url) async {
    try {
      // 1. Fetch SVG string from URL
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        String svgContent = response.body;

        // 2. Create Element
        // We calculate a good default size, defaulting to 100x100 if parsing fails
        final defaultSize = _getResponsiveElementSize(
            widthPercent: 0.15,
            heightPercent: 0.15,
            minWidth: 50,
            maxWidth: 300
        );

        final element = SvgElement(
          id: _uuid.v4(),
          name: 'Element ${activePage.elements.length + 1}',
          position: _getDefaultElementPosition(defaultSize),
          size: defaultSize,
          svgString: svgContent,
          // Basic color parsing can be added here if needed
        );

        // 3. Add to Canvas
        addElement(element);
        selectElement(element.id);
      }
    } catch (e) {
      debugPrint("Error adding SVG from URL: $e");
    }
  }
  /// Add custom SVG element
  SvgElement addCustomSvg({
    required String svgString,
    Offset? position,
    Size? size,
    String name = 'Custom SVG',
  }) {
    final element = SvgElement(
      id: _uuid.v4(),
      name: name,
      position: position ?? const Offset(100, 100),
      size: size ?? const Size(100, 100),
      svgString: svgString,
    );

    addElement(element);
    selectElement(element.id);
    return element;
  }
  /// Add shape with type (includes lines now)
  ShapeElement addShape({
    ShapeType shapeType = ShapeType.rectangle,
    Offset? position,
    Size? size,
    Color? fillColor,
    Color? strokeColor,
  }) {
    // Use responsive sizing if not specified
    final defaultSize = size ?? (shapeType.isLine 
        ? _getResponsiveElementSize(
            widthPercent: 0.3,
            heightPercent: 0.02,
            minWidth: 100,
            maxWidth: 400,
          )
        : _getResponsiveElementSize(
            widthPercent: 0.15,
            heightPercent: 0.15,
            minWidth: 50,
            maxWidth: 300,
          ));
    
    // Center element at click position
    final centeredPosition = position != null
        ? Offset(
            position.dx - defaultSize.width / 2,
            position.dy - defaultSize.height / 2,
          )
        : _getDefaultElementPosition(defaultSize);

    final element = ShapeElement(
      id: _uuid.v4(),
      name: '${shapeType.displayName} ${activePage.elements.length + 1}',
      position: centeredPosition,
      size: defaultSize,
      shapeType: shapeType,
      fillColor: shapeType.isLine ? Colors.transparent : (fillColor ?? Colors.transparent),
      strokeColor: strokeColor ?? Colors.black,
      strokeWidth: shapeType.isLine ? 2 : 1,
    );

    addElement(element);
    selectElement(element.id);
    return element;
  }
  /// Add new element (to active page)
  void addElement(TemplateElement element) {
    _saveState();
    element.zIndex = activePage.elements.length;
    activePage.elements.add(element);
    callbacks.onLayerAdded?.call(element);
    notifyListeners();
  }

  /// Remove element (from active page)
  void removeElement(String id) {
    _saveState();
    activePage.elements.removeWhere((e) => e.id == id);
    _selectedIds.remove(id);
    callbacks.onLayerRemoved?.call(id);
    notifyListeners();
  }

  /// Remove selected elements (from active page)
  void removeSelected() {
    _saveState();
    for (final id in _selectedIds) {
      activePage.elements.removeWhere((e) => e.id == id);
      callbacks.onLayerRemoved?.call(id);
    }
    _selectedIds.clear();
    notifyListeners();
  }

  /// Update element (on active page)
  void updateElement(TemplateElement element, {bool saveState = true}) {
    if (saveState && !_isInTransaction) {
      _saveState();
    }
    final index = activePage.elements.indexWhere((e) => e.id == element.id);
    if (index != -1) {
      activePage.elements[index] = element;
      callbacks.onLayerModified?.call(element);
      notifyListeners();
    }
  }

  /// Duplicate element (on active page)
  void duplicateElement(String id) {
    final element = activePage.elements.firstWhere(
          (e) => e.id == id,
      orElse: () => throw Exception('Element not found'),
    );
    final clone = element.clone();
    addElement(clone);
    selectElement(clone.id);
  }

  /// Duplicate selected elements
  void duplicateSelected() {
    final toAdd = <TemplateElement>[];
    for (final id in _selectedIds) {
      final element = activePage.elements.firstWhere((e) => e.id == id);
      toAdd.add(element.clone());
    }
    clearSelection();
    for (final element in toAdd) {
      addElement(element);
      _selectedIds.add(element.id);
    }
    notifyListeners();
  }

  // ==================== SELECTION ====================

  /// Select element
  void selectElement(String id, {bool addToSelection = false}) {
    debugPrint('🎯 selectElement: id=$id, addToSelection=$addToSelection, multiSelectMode=$_isMultiSelectMode');
    
    // Auto-detect Shift key for multi-selection (desktop)
    final shiftPressed = HardwareKeyboard.instance.isShiftPressed;
    
    // Multi-select behavior:
    // 1. If multi-select mode is ON: Toggle selection (add/remove)
    // 2. If Shift is pressed (desktop): Toggle selection (add/remove)
    // 3. If addToSelection is true: Add to selection
    // 4. Otherwise: Replace selection (clear others)
    if (_isMultiSelectMode) {
      debugPrint('   Multi-select mode: Toggling selection');
      if (_selectedIds.contains(id)) {
        debugPrint('   Removing from selection');
        _selectedIds.remove(id);
      } else {
        debugPrint('   Adding to selection');
        _selectedIds.add(id);
      }
    } else {
      // Desktop behavior with Shift key or explicit addToSelection
      final shouldAddToSelection = addToSelection || shiftPressed;
      
      if (!shouldAddToSelection) {
        debugPrint('   Clearing previous selection');
        _selectedIds.clear();
      }
      
      // Toggle if Shift is pressed and element is already selected
      if (shiftPressed && _selectedIds.contains(id)) {
        debugPrint('   Toggling off (Shift pressed)');
        _selectedIds.remove(id);
      } else {
        debugPrint('   Adding to selection');
        _selectedIds.add(id);
      }
    }
    
    debugPrint('   Selected IDs: $_selectedIds');
    callbacks.onSelectionChanged?.call(_selectedIds.toList());
    notifyListeners();
  }

  /// Toggle multi-select mode (for touch devices)
  void toggleMultiSelectMode() {
    _isMultiSelectMode = !_isMultiSelectMode;
    debugPrint('🔄 Multi-select mode: ${_isMultiSelectMode ? "ON" : "OFF"}');
    notifyListeners();
  }

  /// Deselect element
  void deselectElement(String id) {
    _selectedIds.remove(id);
    callbacks.onSelectionChanged?.call(_selectedIds.toList());
    notifyListeners();
  }

  /// Toggle selection
  void toggleSelection(String id) {
    if (_selectedIds.contains(id)) {
      deselectElement(id);
    } else {
      selectElement(id, addToSelection: true);
    }
  }

  /// Clear selection
  void clearSelection() {
    debugPrint('🧹 clearSelection: ${_selectedIds.length} items cleared');
    _selectedIds.clear();
    callbacks.onSelectionChanged?.call([]);
    notifyListeners();
  }

  /// Select all (on active page)
  void selectAll() {
    _selectedIds.clear();
    _selectedIds.addAll(activePage.elements.map((e) => e.id));
    callbacks.onSelectionChanged?.call(_selectedIds.toList());
    notifyListeners();
  }

  /// Select element at point
  TemplateElement? getElementAtPoint(Offset point) {
    debugPrint('🔍 getElementAtPoint: checking point=$point');
    
    // Check from top to bottom (highest zIndex first)
    // Exclude background elements from selection
    final sorted = [...activePage.elements]
      ..sort((a, b) => b.zIndex.compareTo(a.zIndex));
    
    debugPrint('   Checking ${sorted.length} elements (top to bottom)');
    
    for (final element in sorted) {
      // Skip background elements - they should not be selectable by clicking
      if (element.type == ElementType.background) {
        debugPrint('   ⏩ Skipping background element');
        continue;
      }
      
      if (element.isLocked) {
        debugPrint('   🔒 Skipping locked: ${element.name}');
        continue;
      }
      
      if (!element.isVisible) {
        debugPrint('   👻 Skipping hidden: ${element.name}');
        continue;
      }
      
      if (element.containsPoint(point)) {
        debugPrint('   ✅ Hit: ${element.name} at ${element.position}');
        return element;
      } else {
        debugPrint('   ❌ Miss: ${element.name} (bounds: ${element.position} to ${element.position + Offset(element.size.width, element.size.height)})');
      }
    }
    
    debugPrint('   No element found at point');
    return null;
  }

  // ==================== TRANSFORM ====================

  /// Move selected elements
  void moveSelected(Offset delta) {
    for (final id in _selectedIds) {
      final index = activePage.elements.indexWhere((e) => e.id == id);
      if (index != -1 && !activePage.elements[index].isLocked) {
        activePage.elements[index].position += delta;
      }
    }
    notifyListeners();
  }

  /// Resize selected element
  void resizeSelected(Size delta, Alignment anchor) {
    if (_selectedIds.length != 1) return;

    final element = selectedElements.first;
    if (element.isLocked) return;

    element.size = Size(
      (element.size.width + delta.width).clamp(configs.layerConfig.minLayerSize, double.infinity),
      (element.size.height + delta.height).clamp(configs.layerConfig.minLayerSize, double.infinity),
    );
    notifyListeners();
  }

  /// Rotate selected element
  void rotateSelected(double angle) {
    for (final id in _selectedIds) {
      final index = activePage.elements.indexWhere((e) => e.id == id);
      if (index != -1 && !activePage.elements[index].isLocked) {
        activePage.elements[index].rotation += angle;
      }
    }
    notifyListeners();
  }

  ItemTableElement addItemTable({
    Offset? position,
    Size? size,
    ItemTablePreset preset = ItemTablePreset.classic,
  }) {
    // Use responsive table sizing - 70% of document width, min 50%, max 90%
    final defaultSize = size ?? _getResponsiveTableSize();
    
    // Center element at click position
    final centeredPosition = position != null
        ? Offset(
            position.dx - defaultSize.width / 2,
            position.dy - defaultSize.height / 2,
          )
        : _getDefaultElementPosition(defaultSize);
    
    final element = ItemTableElement(
      id: _uuid.v4(),
      name: 'Items Table ${activePage.elements.length + 1}',
      position: centeredPosition,
      size: defaultSize,
      preset: preset,
    );
    element.applyPreset(preset);
    addElement(element);
    selectElement(element.id);
    return element;
  }


  // ==================== Z-INDEX ====================

  /// Bring to front
  void bringToFront(String id) {
    _saveState();
    final maxZ = activePage.elements.map((e) => e.zIndex).reduce((a, b) => a > b ? a : b);
    final element = activePage.elements.firstWhere((e) => e.id == id);
    element.zIndex = maxZ + 1;
    _normalizeZIndex();
    notifyListeners();
  }

  /// Send to back
  void sendToBack(String id) {
    _saveState();
    final element = activePage.elements.firstWhere((e) => e.id == id);
    element.zIndex = -1;
    _normalizeZIndex();
    notifyListeners();
  }

  /// Bring forward
  void bringForward(String id) {
    _saveState();
    final element = activePage.elements.firstWhere((e) => e.id == id);
    final nextElement = activePage.elements.cast<TemplateElement?>().firstWhere(
          (e) => e!.zIndex == element.zIndex + 1,
      orElse: () => null,
    );
    if (nextElement != null) {
      nextElement.zIndex--;
      element.zIndex++;
    }
    notifyListeners();
  }

  /// Send backward
  void sendBackward(String id) {
    _saveState();
    final element = activePage.elements.firstWhere((e) => e.id == id);
    final prevElement = activePage.elements.cast<TemplateElement?>().firstWhere(
          (e) => e!.zIndex == element.zIndex - 1,
      orElse: () => null,
    );
    if (prevElement != null) {
      prevElement.zIndex++;
      element.zIndex--;
    }
    notifyListeners();
  }

  void _normalizeZIndex() {
    activePage.elements.sort((a, b) => a.zIndex.compareTo(b.zIndex));
    for (int i = 0; i < activePage.elements.length; i++) {
      activePage.elements[i].zIndex = i;
    }
  }

  // ==================== HISTORY ====================

  /// Begin a transaction (prevents saving state until committed)
  void beginTransaction() {
    if (!_isInTransaction) {
      _saveState();
      _isInTransaction = true;
    }
  }

  /// Commit a transaction (allows saving state again)
  void commitTransaction() {
    _isInTransaction = false;
  }

  /// Cancel a transaction and rollback to previous state
  void cancelTransaction() {
    if (_isInTransaction && canUndo) {
      _isInTransaction = false;
      undo();
    } else {
      _isInTransaction = false;
    }
  }

  void _saveState() {
    if (_isInTransaction) return; // Don't save during transaction
    
    final state = EditorState(
      pages: _pages.map((p) => p.toJson()).toList(),
      activePageIndex: _activePageIndex,
      selectedIds: _selectedIds.toList(),
    );
    _undoStack.add(state);
    _redoStack.clear();

    // Limit history size
    if (_undoStack.length > 50) {
      _undoStack.removeAt(0);
    }

    callbacks.onHistoryChanged?.call(canUndo, canRedo);
  }

  /// Undo
  void undo() {
    if (!canUndo) return;

    final currentState = EditorState(
      pages: _pages.map((p) => p.toJson()).toList(),
      activePageIndex: _activePageIndex,
      selectedIds: _selectedIds.toList(),
    );
    _redoStack.add(currentState);

    final prevState = _undoStack.removeLast();
    _restoreState(prevState);

    callbacks.onHistoryChanged?.call(canUndo, canRedo);
    notifyListeners();
  }

  /// Redo
  void redo() {
    if (!canRedo) return;

    final currentState = EditorState(
      pages: _pages.map((p) => p.toJson()).toList(),
      activePageIndex: _activePageIndex,
      selectedIds: _selectedIds.toList(),
    );
    _undoStack.add(currentState);

    final nextState = _redoStack.removeLast();
    _restoreState(nextState);

    callbacks.onHistoryChanged?.call(canUndo, canRedo);
    notifyListeners();
  }

  void _restoreState(EditorState state) {
    _pages.clear();
    _pages.addAll(
      state.pages.map((json) => PageModel.fromJson(json)),
    );
    _activePageIndex = state.activePageIndex;
    _selectedIds.clear();
    _selectedIds.addAll(state.selectedIds);
  }

  // ==================== ZOOM & PAN ====================

  /// Set zoom
  void zoomIn() => setZoom(_zoom * 1.05);

  /// Zoom out - Slower (10% decrement)
  void zoomOut() => setZoom(_zoom / 1.05);

  /// Set zoom with limits
  void setZoom(double zoom) {
    _zoom = zoom.clamp(0.25, 3.0); // Max 300% instead of 400%
    callbacks.onZoomChanged?.call(_zoom);
    notifyListeners();
  }
  /// Zoom to fit
  void zoomToFit(Size viewportSize) {
    final pageSize = configs.canvasConfig.pageSize.size;
    final scaleX = viewportSize.width / pageSize.width;
    final scaleY = viewportSize.height / pageSize.height;
    setZoom((scaleX < scaleY ? scaleX : scaleY) * 0.9);
  }

  /// Set pan offset
  void setPanOffset(Offset offset) {
    _panOffset = offset;
    notifyListeners();
  }

  // ==================== TOOL ====================

  /// Set current tool
  void setTool(EditorTool tool) {
    _currentTool = tool;
    notifyListeners();
  }

  // ==================== RULERS & GRID ====================

  /// Toggle rulers visibility
  void toggleRulers() {
    _showRulers = !_showRulers;
    notifyListeners();
  }

  /// Toggle grid visibility
  void toggleGrid() {
    _showGrid = !_showGrid;
    notifyListeners();
  }

  /// Toggle snap to grid
  void toggleSnapToGrid() {
    _snapToGrid = !_snapToGrid;
    notifyListeners();
  }

  /// Set rulers visibility
  void setShowRulers(bool show) {
    _showRulers = show;
    notifyListeners();
  }

  /// Set grid visibility
  void setShowGrid(bool show) {
    _showGrid = show;
    notifyListeners();
  }

  // ==================== ELEMENT FACTORIES ====================

  /// Add text element
  TextElement addText({
    String text = 'Text',
    Offset? position,
    TextStyle? style,
  }) {
    // Use responsive sizing
    final defaultSize = _getResponsiveElementSize(
      widthPercent: 0.25,
      heightPercent: 0.06,
      minWidth: 80,
      maxWidth: 400,
    );
    
    // Center element at click position
    final centeredPosition = position != null
        ? Offset(
            position.dx - defaultSize.width / 2,
            position.dy - defaultSize.height / 2,
          )
        : _getDefaultElementPosition(defaultSize);
    
    final element = TextElement(
      id: _uuid.v4(),
      name: 'Text ${activePage.elements.length + 1}',
      position: centeredPosition,
      size: defaultSize,
      text: text,
      fontSize: style?.fontSize ?? 14,
      fontStyle: style?.fontStyle ?? FontStyle.normal,
      fontWeight: style?.fontWeight ?? FontWeight.normal,
    );
    addElement(element);
    selectElement(element.id);
    return element;
  }

  /// Add placeholder element
  TextElement addPlaceholder({
    required String placeholderKey,
    String? displayName,
    Offset? position,
  }) {
    // Use responsive sizing
    final defaultSize = _getResponsiveElementSize(
      widthPercent: 0.25,
      heightPercent: 0.06,
      minWidth: 80,
      maxWidth: 400,
    );
    
    // Center element at click position
    final centeredPosition = position != null
        ? Offset(
            position.dx - defaultSize.width / 2,
            position.dy - defaultSize.height / 2,
          )
        : _getDefaultElementPosition(defaultSize);
    
    final element = TextElement(
      id: _uuid.v4(),
      name: displayName ?? placeholderKey,
      position: centeredPosition,
      size: defaultSize,
      text: '{{${placeholderKey.split('.').last}}}', // Initial visual text
      placeholderKey: placeholderKey,
      defaultValue: '{{$placeholderKey}}',
      displayFormat: '{value}',
      textColor: const Color(0xFFE65100), // Default placeholder color (Orange)
    );
    addElement(element);
    selectElement(element.id);
    return element;
  }

  /// Add image element
  ImageElement addImage({
    Uint8List? bytes,
    String? url,
    Offset? position,
    Size? size,
  }) {
    // Use responsive sizing (square aspect ratio by default)
    final defaultSize = size ?? _getResponsiveElementSize(
      widthPercent: 0.25,
      heightPercent: 0.25,
      minWidth: 100,
      maxWidth: 400,
    );
    
    // Center element at click position
    final centeredPosition = position != null
        ? Offset(
            position.dx - defaultSize.width / 2,
            position.dy - defaultSize.height / 2,
          )
        : _getDefaultElementPosition(defaultSize);
    
    final element = ImageElement(
      id: _uuid.v4(),
      name: 'Image ${activePage.elements.length + 1}',
      position: centeredPosition,
      size: defaultSize,
      imageBytes: bytes,
      imageUrl: url,
    );
    addElement(element);
    selectElement(element.id);
    return element;
  }

  /// Add table element
  TableElement addTable({
    int rows = 4,
    int columns = 4,
    Offset? position,
    Size? size,
    String? dataSourceKey,
  }) {
    final cells = List.generate(
      rows,
          (r) => List.generate(columns, (c) => TableCell()),
    );
    
    // Use responsive sizing based on document width and cell count
    final cellWidth = _documentMetadata.width * 0.15;
    final cellHeight = _documentMetadata.height * 0.04;
    final defaultSize = size ?? Size(
      (columns * cellWidth).clamp(_documentMetadata.width * 0.4, _documentMetadata.width * 0.9),
      (rows * cellHeight).clamp(_documentMetadata.height * 0.15, _documentMetadata.height * 0.6),
    );
    
    // Center element at click position
    final centeredPosition = position != null
        ? Offset(
            position.dx - defaultSize.width / 2,
            position.dy - defaultSize.height / 2,
          )
        : _getDefaultElementPosition(defaultSize);

    final element = TableElement(
      id: _uuid.v4(),
      name: 'Table ${activePage.elements.length + 1}',
      position: centeredPosition,
      size: defaultSize,
      rows: rows,
      columns: columns,
      cells: cells,
      dataSourceKey: dataSourceKey,
    );
    addElement(element);
    selectElement(element.id);
    return element;
  }


  /// Add QR code element
  QrElement addQrCode({
    String data = 'https://example.com',
    String? placeholderKey,
    Offset? position,
    double? size,
  }) {
    // Use responsive sizing (square QR code)
    final qrSize = size ?? _documentMetadata.width * 0.15;
    final clampedSize = qrSize.clamp(
      _documentMetadata.width * 0.1,
      _documentMetadata.width * 0.3,
    );
    
    // Center element at click position
    final centeredPosition = position != null
        ? Offset(
            position.dx - clampedSize / 2,
            position.dy - clampedSize / 2,
          )
        : _getDefaultElementPosition(Size(clampedSize, clampedSize));
    
    final element = QrElement(
      id: _uuid.v4(),
      name: 'QR Code ${activePage.elements.length + 1}',
      position: centeredPosition,
      size: Size(clampedSize, clampedSize),
    );
    addElement(element);
    selectElement(element.id);
    return element;
  }

  /// Add Product Grid element
  ProductGridElement addProductGrid({
    Offset? position,
    Size? size,
  }) {
    // Use responsive sizing - large grid for catalog/menu
    final defaultSize = size ?? _getResponsiveElementSize(
      widthPercent: 0.85,  // 85% of page width
      heightPercent: 0.70, // 70% of page height
      minWidth: 400,
      maxWidth: _documentMetadata.width * 0.95,
    );
    
    // Center element at click position
    final centeredPosition = position != null
        ? Offset(
            position.dx - defaultSize.width / 2,
            position.dy - defaultSize.height / 2,
          )
        : _getDefaultElementPosition(defaultSize);
    
    final element = ProductGridElement(
      id: _uuid.v4(),
      name: 'Product Grid ${activePage.elements.length + 1}',
      position: centeredPosition,
      size: defaultSize,
      crossAxisCount: 2,
      childAspectRatio: 1.0,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      cardTemplate: [],
      showCategoryHeader: false,
      categoryHeaderTemplate: null,
      backgroundColor: Colors.transparent,
      padding: 10,
    );
    addElement(element);
    selectElement(element.id);
    return element;
  }

  // ==================== GROUP ====================

  /// Group selected elements
  void groupSelected() {
    if (_selectedIds.length < 2) return;

    _saveState();

    final selectedElements = this.selectedElements;

    // Calculate group bounds
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (final element in selectedElements) {
      minX = minX < element.position.dx ? minX : element.position.dx;
      minY = minY < element.position.dy ? minY : element.position.dy;
      maxX = maxX > (element.position.dx + element.size.width)
          ? maxX
          : (element.position.dx + element.size.width);
      maxY = maxY > (element.position.dy + element.size.height)
          ? maxY
          : (element.position.dy + element.size.height);
    }

    // Adjust children positions to be relative to group
    for (final element in selectedElements) {
      element.position = Offset(
        element.position.dx - minX,
        element.position.dy - minY,
      );
      activePage.elements.remove(element);
    }

    final group = GroupElement(
      id: _uuid.v4(),
      name: 'Group ${activePage.elements.length + 1}',
      position: Offset(minX, minY),
      size: Size(maxX - minX, maxY - minY),
      children: selectedElements,
    );

    activePage.elements.add(group);
    _selectedIds.clear();
    _selectedIds.add(group.id);

    notifyListeners();
  }

  /// Ungroup selected group
  void ungroupSelected() {
    if (_selectedIds.length != 1) return;

    final element = selectedElements.first;
    if (element is! GroupElement) return;

    _saveState();

    activePage.elements.remove(element);
    _selectedIds.clear();

    for (final child in element.children) {
      child.position = Offset(
        child.position.dx + element.position.dx,
        child.position.dy + element.position.dy,
      );
      activePage.elements.add(child);
      _selectedIds.add(child.id);
    }

    notifyListeners();
  }

  // ==================== LOCK/VISIBILITY ====================

  /// Toggle lock on element
  void toggleLock(String id) {
    final element = activePage.elements.firstWhere((e) => e.id == id);
    element.isLocked = !element.isLocked;
    notifyListeners();
  }

  /// Toggle visibility on element
  void toggleVisibility(String id) {
    final element = activePage.elements.firstWhere((e) => e.id == id);
    element.isVisible = !element.isVisible;
    notifyListeners();
  }

  // ==================== INVOICE DATA ====================

  /// Load invoice data for preview/fill mode
  void loadInvoiceData(InvoiceDocument invoice) {
    _invoiceData = invoice;
    notifyListeners();
  }

  /// Clear invoice data
  void clearInvoiceData() {
    _invoiceData = null;
    notifyListeners();
  }

  /// Get dummy invoice data for export when no real data is available
  InvoiceDocument getDummyInvoiceData() {
    return InvoiceDocument(
      invoiceNumber: 'INV-001',
      invoiceDate: DateTime.now(),
      dueDate: DateTime.now().add(const Duration(days: 30)),
      grandTotal: 11900.50,
      subTotal: 10000.00,
      totalTax: 1800.00,
      inWords: 'Eleven Thousand Nine Hundred Rupees Only',
      notes: 'Thank you for your business',
      business: BusinessInfo(
        name: 'Test Business Ltd',
        address: '123 Business St, City',
        phone: '+91 9876543210',
        email: 'test@business.com',
        gstin: 'GST123456789',
        logo: null,
      ),
      customer: CustomerInfo(
        name: 'John Doe',
        address: '456 Customer Ave, Town',
        phone: '+91 9123456789',
        gstin: 'CUST123456',
      ),
      items: [
        InvoiceItem(
          description: 'Web Design Service',
          hsn: '998311',
          qty: 10,
          unit: 'Hrs',
          rate: 500.00,
          discount: 50.00,
          taxAmount: 90.00,
          taxPercent: 18,
          taxableValue: 4500.00,
          rowTotal: 5310.00,
        ),
      ],
    );
  }

  /// Ensure invoice data is available for export (load dummy if needed)
  void ensureInvoiceDataForExport() {
    if (_invoiceData == null) {
      _invoiceData = getDummyInvoiceData();
    }
  }

  /// Get placeholder value from invoice data
  String? getPlaceholderValue(String key) {
    if (_invoiceData == null) return null;

    final json = _invoiceData!.toJson();
    return _getNestedValue(json, key)?.toString();
  }

  dynamic _getNestedValue(Map<String, dynamic> json, String path) {
    final keys = path.split('.');
    dynamic current = json;

    for (final key in keys) {
      if (current is Map<String, dynamic> && current.containsKey(key)) {
        current = current[key];
      } else {
        return null;
      }
    }

    return current;
  }

  // ==================== MULTI-PAGE METHODS ====================
  
  /// Add a new blank page (or duplicate current page)
  void addPage({bool duplicate = false}) {
    _saveState();
    
    final newPage = duplicate 
        ? activePage.clone(newName: 'Page ${_pages.length + 1}')
        : PageModel.blank(name: 'Page ${_pages.length + 1}');
    
    _pages.add(newPage);
    _activePageIndex = _pages.length - 1; // Switch to new page
    clearSelection();
    
    notifyListeners();
  }
  
  /// Remove a page (prevent removing the last single page)
  void removePage(int index) {
    if (_pages.length <= 1) {
      debugPrint('Cannot remove the last page');
      return;
    }
    
    if (index < 0 || index >= _pages.length) {
      debugPrint('Invalid page index: $index');
      return;
    }
    
    _saveState();
    _pages.removeAt(index);
    
    // Adjust active page index if necessary
    if (_activePageIndex >= _pages.length) {
      _activePageIndex = _pages.length - 1;
    } else if (_activePageIndex > index) {
      _activePageIndex--;
    }
    
    clearSelection();
    notifyListeners();
  }
  
  /// Switch to a different page
  void switchPage(int index) {
    if (index < 0 || index >= _pages.length) {
      debugPrint('Invalid page index: $index');
      return;
    }
    
    if (_activePageIndex == index) return;
    
    _activePageIndex = index;
    clearSelection(); // Clear selection when switching pages
    notifyListeners();
  }
  
  /// Reorder pages (drag and drop)
  void reorderPages(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;
    if (oldIndex < 0 || oldIndex >= _pages.length) return;
    if (newIndex < 0 || newIndex >= _pages.length) return;
    
    _saveState();
    
    final page = _pages.removeAt(oldIndex);
    _pages.insert(newIndex, page);
    
    // Update active page index
    if (_activePageIndex == oldIndex) {
      _activePageIndex = newIndex;
    } else if (_activePageIndex > oldIndex && _activePageIndex <= newIndex) {
      _activePageIndex--;
    } else if (_activePageIndex < oldIndex && _activePageIndex >= newIndex) {
      _activePageIndex++;
    }
    
    notifyListeners();
  }
  
  /// Duplicate a specific page
  void duplicatePage(int index) {
    if (index < 0 || index >= _pages.length) return;
    
    _saveState();
    final clonedPage = _pages[index].clone(newName: '${_pages[index].name} Copy');
    _pages.insert(index + 1, clonedPage);
    _activePageIndex = index + 1; // Switch to duplicated page
    clearSelection();
    
    notifyListeners();
  }

  // ==================== EXPORT ====================

  /// Export template as JSON (with multi-page support)
  Map<String, dynamic> exportTemplate() {
    return {
      'templateVersion': '2.0', // Updated version for multi-page support
      'templateName': templateName,
      'document': _documentMetadata.toJson(),
      'pageSize': {
        'width': pageSize.width,
        'height': pageSize.height,
        'name': pageSize.name,
      },
      'pages': _pages.map((p) => p.toJson()).toList(), // New: pages array
      'viewSettings': {
        'showRulers': _showRulers,
        'showGrid': _showGrid,
        'snapToGrid': _snapToGrid,
        'zoom': _zoom,
      },
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  /// Import template from JSON (with backward compatibility)
  void importTemplate(Map<String, dynamic> json) {
    // Safety: Don't clear pages until we have new ones ready
    final tempPages = <PageModel>[];
    _selectedIds.clear();

    templateVersion = json['templateVersion'] ?? '1.0';
    templateName = json['templateName'] ?? 'Imported Template';

    // Import document metadata (for coordinate system)
    if (json['document'] != null) {
      _documentMetadata = DocumentMetadata.fromJson(json['document']);
    } else if (json['pageSize'] != null) {
      // Fallback: create metadata from pageSize for backward compatibility
      final ps = json['pageSize'];
      _documentMetadata = DocumentMetadata(
        width: (ps['width'] ?? 595).toDouble(),
        height: (ps['height'] ?? 842).toDouble(),
      );
    } else {
      _documentMetadata = const DocumentMetadata(
        width: 595,
        height: 842,
      );
    }

    if (json['pageSize'] != null) {
      final ps = json['pageSize'];
      pageSize = PageSize.values.firstWhere(
            (p) => p.name == ps['name'],
        orElse: () => PageSize.a4,
      );
    }

    // ==================== BACKWARD COMPATIBILITY ====================
    // Check if this is a new multi-page format or old single-page format
    if (json.containsKey('pages') && json['pages'] is List) {
      // New format: Load pages array
      final pagesList = json['pages'] as List;
      for (final pageJson in pagesList) {
        final page = PageModel.fromJson(pageJson as Map<String, dynamic>);
        tempPages.add(page);
      }
      
      // Ensure at least one page exists
      if (tempPages.isEmpty) {
        debugPrint('❌ No pages found in new format, adding blank page');
        tempPages.add(PageModel.blank(name: 'Page 1'));
      }
    } else {
      // Old format: Single page stored in 'elements' array
      debugPrint('🔄 Legacy format detected, converting to multi-page');
      final elementsJson = (json['elements'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      final elements = <TemplateElement>[];
      for (final elementJson in elementsJson) {
        try {
          final element = TemplateElement.fromJson(elementJson);
          elements.add(element);
        } catch (e) {
          debugPrint('⚠️ Skipping invalid element: $e');
        }
      }
      final page = PageModel(
        id: _uuid.v4(),
        name: 'Page 1', 
        elements: elements,
      );
      tempPages.add(page);
      
      // Ensure at least one page exists
      if (tempPages.isEmpty) {
        debugPrint('❌ No elements found in legacy format, adding blank page');
        tempPages.add(PageModel.blank(name: 'Page 1'));
      }
    }

    // CRITICAL: Now replace the pages atomically
    debugPrint('✅ Import success: ${tempPages.length} pages loaded');
    _pages.clear();
    _pages.addAll(tempPages);
    _activePageIndex = 0;
    
    // CRITICAL: DO NOT load view settings for export/preview - keep clean config
    // Load view settings if present (but ONLY for main editor, NOT for export/preview)
    if (json['viewSettings'] != null && configs.canvasConfig.showRulers) {
      final vs = json['viewSettings'] as Map<String, dynamic>;
      _showRulers = vs['showRulers'] ?? false;
      _showGrid = vs['showGrid'] ?? false;
      _snapToGrid = vs['snapToGrid'] ?? false;
      debugPrint('🔧 Loaded view settings: rulers=$_showRulers, grid=$_showGrid');
      // Don't load zoom - let user control it
    } else {
      debugPrint('🧹 Keeping clean config: rulers=$_showRulers, grid=$_showGrid (export/preview mode)');
    }
    
    debugPrint('📋 Template loaded: "${templateName}" with ${_pages.length} pages, ${_getTotalElementsCount()} total elements');
    notifyListeners();
  }

  // ==================== RESPONSIVE SIZING HELPERS ====================

  /// Get responsive element size based on document dimensions
  Size _getResponsiveElementSize({
    required double widthPercent,
    required double heightPercent,
    double? minWidth,
    double? maxWidth,
  }) {
    double width = _documentMetadata.width * widthPercent;
    double height = _documentMetadata.height * heightPercent;
    
    if (minWidth != null) width = width.clamp(minWidth, double.infinity);
    if (maxWidth != null) width = width.clamp(0, maxWidth);
    
    return Size(width, height);
  }

  /// Get responsive table size (special case for tables)
  Size _getResponsiveTableSize() {
    // Check if mobile size (roughly)
    final isMobileSize = _documentMetadata.width < 600;
    
    // FIX: Increased minWidth for mobile to avoid cramped columns
    // Mobile needs at least 90% width, desktop can be narrower
    final minWidth = isMobileSize 
        ? _documentMetadata.width * 0.9  // 90% minimum on mobile (up from 0.85)
        : _documentMetadata.width * 0.5;
    final maxWidth = _documentMetadata.width * 0.9;
    final targetWidth = isMobileSize
        ? _documentMetadata.width * 0.9  // 90% on mobile (up from 70%)
        : _documentMetadata.width * 0.7; // 70% on desktop

    final width = targetWidth.clamp(minWidth, maxWidth);
    
    // Height proportional to width (roughly 2.5:1 ratio)
    final height = width / 2.5;

    return Size(width, height);
  }

  /// Get default position for new element (centered in document)
  Offset _getDefaultElementPosition(Size elementSize) {
    return Offset(
      (_documentMetadata.width - elementSize.width) / 2,
      (_documentMetadata.height - elementSize.height) / 2,
    );
  }

  /// Get total elements count across all pages
  int _getTotalElementsCount() {
    return _pages.fold(0, (total, page) => total + page.elements.length);
  }

  // ==================== CLEANUP ====================

  @override
  void dispose() {
    _undoStack.clear();
    _redoStack.clear();
    _pages.clear();
    _selectedIds.clear();
    super.dispose();
  }
}

/// Editor State for History (updated for multi-page)
class EditorState {
  final List<Map<String, dynamic>> pages;
  final int activePageIndex;
  final List<String> selectedIds;

  EditorState({
    required this.pages,
    required this.activePageIndex,
    required this.selectedIds,
  });
}