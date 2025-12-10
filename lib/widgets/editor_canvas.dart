// ============================================================================
// 📁 FILE: editor_canvas.dart (COMPLETE FIXED VERSION)
// 📍 PATH: /lib/widgets/canvas/editor_canvas.dart
// ============================================================================

import 'package:flutter/material.dart' hide TableCell;
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
// Old properties_panel.dart.dep.bin deprecated - use property_components/property_panel_scaffold.dart
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:image_picker/image_picker.dart';

import '../editor/editor_configs.dart';
import '../models/background.elements.model.dart';
import '../models/invoice_model.dart';
import '../models/svg_element.dart';
import 'layer_renderer.dart';
import '../editor/editor_controller.dart';
import '../editor/editor_configs.dart';
import '../models/template_element.dart';
import 'resizable_widget.dart';
import 'signature_layer.dart';

/// Main Editor Canvas - COMPLETE FIXED VERSION
class EditorCanvas extends StatefulWidget {
  final InvoiceEditorConfigs configs;

  const EditorCanvas({
    super.key,
    required this.configs,
  });

  @override
  State<EditorCanvas> createState() => _EditorCanvasState();
}

class _EditorCanvasState extends State<EditorCanvas> {
  Offset? _lastFocalPoint;
  bool _isPanning = false;
  double _initialZoom = 1.0;
  int _pointerCount = 0;

  // For constrained zoom
  double _currentZoom = 1.0;
  Offset _currentPan = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Consumer<InvoiceEditorController>(
      builder: (context, controller, _) {
        // Sync zoom with controller
        if ((_currentZoom - controller.zoom).abs() > 0.01) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _currentZoom = controller.zoom;
            });
          });
        }
        
        return Column(
          children: [
            // Top Ruler - controlled by controller state
            if (controller.showRulers)
              RepaintBoundary(
                child: Container(
                  height: 24,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Row(
                    children: [
                      // Corner space
                      Container(
                        width: 24,
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: Center(
                          child: Icon(Icons.straighten, size: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      ),
                      // Horizontal Ruler
                      Expanded(
                        child: HorizontalRuler(
                          zoom: _currentZoom,
                          offset: _currentPan.dx,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            Expanded(
              child: Row(
                children: [
                  // Left Ruler - controlled by controller state
                  if (controller.showRulers)
                    RepaintBoundary(
                      child: Container(
                        width: 24,
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: VerticalRuler(
                          zoom: _currentZoom,
                          offset: _currentPan.dy,
                        ),
                      ),
                    ),

                  // Canvas Area with Responsive Sizing
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final pageSize = widget.configs.canvasConfig.pageSize.size;
                        final screenWidth = MediaQuery.of(context).size.width;
                        final isMobile = screenWidth < 600;
                        
                        return ClipRect(
                          child: Listener(
                            onPointerSignal: (event) {
                              if (event is PointerScrollEvent) {
                                _handleMouseScroll(event, controller);
                              }
                            },
                            child: GestureDetector(
                              onScaleStart: _onScaleStart,
                              onScaleUpdate: (details) => _onScaleUpdate(details, controller),
                              onScaleEnd: _onScaleEnd,
                              onTapUp: (details) => _onTapUp(details, controller, constraints), // <--- USE THIS
                              child: Container(
                                color: _getCanvasBackgroundColor(context),
                                width: constraints.maxWidth,
                                height: constraints.maxHeight,
                                child: isMobile
                                    ? _buildMobileCanvas(controller, constraints, pageSize)
                                    : _buildDesktopCanvas(controller, constraints, pageSize),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
  void _onTapUp(TapUpDetails details, InvoiceEditorController controller, BoxConstraints constraints) {
    _handleCanvasTap(details.localPosition, controller, constraints);
  }
  
  /// Get canvas background color based on theme
  Color _getCanvasBackgroundColor(BuildContext context) {
    // If explicitly set in config and not default, use it
    final configColor = widget.configs.canvasConfig.backgroundColor;
    const defaultColor = Color(0xFFE0E0E0);
    
    // If user has set a custom color (not default), respect it
    if (configColor != defaultColor) {
      return configColor;
    }
    
    // Otherwise, adapt to theme
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF121212) // Dark grey for dark mode
        : const Color(0xFFE0E0E0); // Light grey for light mode
  }
  void _handleMouseScroll(
      PointerScrollEvent event, InvoiceEditorController controller) {
    setState(() {
      // Slower zoom - 5% per scroll
      if (event.scrollDelta.dy < 0) {
        _currentZoom = (_currentZoom * 1.02).clamp(0.25, 3.0);
      } else {
        _currentZoom = (_currentZoom / 1.02).clamp(0.25, 3.0);
      }
      controller.setZoom(_currentZoom);
    });
  }

  /// Build canvas for mobile - SCALE-TO-FIT VIEWPORT
  /// Uses FittedBox to scale the ENTIRE document to fit screen
  /// Document is rendered at full logical size (595×842), then scaled down
  Widget _buildMobileCanvas(
      InvoiceEditorController controller, BoxConstraints constraints, Size pageSize) {
    
    debugPrint('📱 Mobile Canvas: viewport=${constraints.maxWidth}×${constraints.maxHeight}, doc=${pageSize.width}×${pageSize.height}');
    
    return Center(
      child: Transform(
        transform: Matrix4.identity()
          ..translate(_currentPan.dx, _currentPan.dy)
          ..scale(_currentZoom),
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(0), // No padding for export compatibility
          child: FittedBox(
            fit: BoxFit.contain, // 🔑 KEY: Scale entire document to fit screen
            child: SizedBox(
              // 🔑 CRITICAL: Render at FULL document size
              width: pageSize.width,
              height: pageSize.height,
              child: _buildPage(controller, constraints, pageSize),
            ),
          ),
        ),
      ),
    );
  }

  /// Build canvas for desktop/tablet - SCALE-TO-FIT VIEWPORT
  /// Uses FittedBox to scale the ENTIRE document to fit screen
  /// Document is rendered at full logical size (595×842), then scaled to fit
  Widget _buildDesktopCanvas(
      InvoiceEditorController controller, BoxConstraints constraints, Size pageSize) {
    
    debugPrint('🖥️ Desktop Canvas: viewport=${constraints.maxWidth}×${constraints.maxHeight}, doc=${pageSize.width}×${pageSize.height}');
    
    return Center(
      child: Transform(
        transform: Matrix4.identity()
          ..translate(_currentPan.dx, _currentPan.dy)
          ..scale(_currentZoom),
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(0), // No padding for export compatibility
          child: FittedBox(
            fit: BoxFit.contain, // 🔑 KEY: Scale entire document to fit screen
            child: SizedBox(
              // 🔑 CRITICAL: Render at FULL document size
              width: pageSize.width,
              height: pageSize.height,
              child: _buildPage(controller, constraints, pageSize),
            ),
          ),
        ),
      ),
    );
  }

  /// Build the page content at FULL document size
  /// Elements are positioned using document coordinates (e.g., 0-595 for A4 width)
  /// FittedBox in parent handles scaling to fit screen
  Widget _buildPage(
      InvoiceEditorController controller, BoxConstraints constraints, Size pageSize) {
    
    // NO AspectRatio needed - parent SizedBox already defines exact size
    // Elements render at FULL document coordinates
    return RepaintBoundary(
      key: controller.canvasKey,
      child: Container(
        // Container inherits size from parent SizedBox (pageSize.width × pageSize.height)
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // Grid Overlay - Controlled by controller state
            if (controller.showGrid)
              Positioned.fill(
                child: RepaintBoundary(
                  child: GridOverlay(
                    gridSize: widget.configs.gridConfig.gridSize,
                    color: widget.configs.gridConfig.gridColor
                        .withOpacity(widget.configs.gridConfig.gridOpacity),
                  ),
                ),
              ),

            // Page Border
            if (widget.configs.canvasConfig.showPageBorder)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                  ),
                ),
              ),

            // LAYER 1: Visual Elements (Z-order, lightweight)
            // Render all elements sorted by zIndex (ascending: -1000, -999, 0, 1, 2, ...)
            ...(controller.elements.where((e) => e.isVisible).toList()
              ..sort((a, b) => a.zIndex.compareTo(b.zIndex))) // <--- Parentheses end here
                .map((element) => _buildVisualElement(element, controller)),


            // LAYER 2: Interaction Controls (Always on top)
            // Render ResizableWidget for selected elements ABOVE everything
            // This ensures handles are always clickable even if element is behind others
            ...controller.selectedElements
                .where((e) => e.isVisible)
                .map((element) => _buildControlElement(element, controller)),
          ],
        ),
      ),
    );
  }

  /// LAYER 1: Build Visual Element (Lightweight, no handles)
  /// Renders the element's visual content with tap-to-select functionality
  Widget _buildVisualElement(TemplateElement element, InvoiceEditorController controller) {
    final isSelected = controller.selectedIds.contains(element.id);
    
    // Elements are positioned in document coordinates
    return Positioned(
      left: element.position.dx,
      top: element.position.dy,
      child: GestureDetector(
        onTap: () {
          // Tap to select (unless already selected, then control layer handles it)
          if (!isSelected) {
            if (HardwareKeyboard.instance.isShiftPressed) {
              controller.selectElement(element.id); // Add to selection
            } else {
              controller.selectElement(element.id); // Replace selection
            }
          }
        },
        child: Transform.rotate(
          angle: element.rotation * (math.pi / 180),
          alignment: Alignment.center,
          child: SizedBox(
            width: element.size.width,
            height: element.size.height,
            child: Opacity(
              opacity: element.opacity,
              child: LayerRenderer(
                element: element,
                invoiceData: controller.invoiceData,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// LAYER 2: Build Control Element (Handles and interaction)
  /// Renders ResizableWidget with IgnorePointer child for selected elements
  /// This layer is always on top, ensuring handles are always accessible
  /// The child uses IgnorePointer to allow taps to pass through to Layer 1
  Widget _buildControlElement(TemplateElement element, InvoiceEditorController controller) {
    final isSelected = controller.selectedIds.contains(element.id);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    // Adjust position to compensate for the always-present handle padding
    // Mobile uses larger handles (48px), desktop uses 30px
    final double handleOffset = (isMobile ? 48 : 30) / 2;
    
    return Positioned(
      left: element.position.dx - handleOffset,
      top: element.position.dy - handleOffset,
      child: ResizableWidget(
        key: ValueKey('control-${element.id}'),
        element: element,
        isSelected: isSelected,
        isLocked: element.isLocked,
        onSelect: () => controller.selectElement(element.id),
        onMove: (delta) {
          if (!element.isLocked) {
            element.position += delta / _currentZoom;
            controller.notifyListeners();
          }
        },
        onResize: (newSize, scaleX, scaleY) {
          if (!element.isLocked) {
            // Update element size
            element.size = newSize;

            // FIX: Scale text elements - font size scales with HEIGHT only
            if (element is TextElement) {
              if (scaleY != 1.0) {
                element.fontSize = (element.fontSize * scaleY).clamp(6.0, 200.0);
              }
            }

            // Scale table elements
            if (element is TableElement) {
              final avgScale = (scaleX + scaleY) / 2;
              element.tableStyle = TableStyle(
                borderColor: element.tableStyle.borderColor,
                borderWidth: (element.tableStyle.borderWidth * avgScale).clamp(0.5, 3.0),
                headerBackgroundColor: element.tableStyle.headerBackgroundColor,
                headerTextStyle: element.tableStyle.headerTextStyle.copyWith(
                  fontSize: ((element.tableStyle.headerTextStyle.fontSize ?? 12) * avgScale).clamp(6.0, 48.0),
                ),
                cellPadding: (element.tableStyle.cellPadding * avgScale).clamp(2.0, 20.0),
                showHeader: element.tableStyle.showHeader,
              );
            }

            // Scale shape elements
            if (element is ShapeElement) {
              final avgScale = (scaleX + scaleY) / 2;
              element.cornerRadius = (element.cornerRadius * avgScale).clamp(0.0, 100.0);
            }

            controller.notifyListeners();
          }
        },
        onRotate: (newRotation) {
          if (!element.isLocked) {
            element.rotation = newRotation;
            controller.notifyListeners();
          }
        },
        onEdit: () => _editElement(context, element, controller),
        onDelete: () => controller.removeElement(element.id),
        onDuplicate: () => controller.duplicateElement(element.id),
        onArrange: (action) {
          switch (action) {
            case 'front':
              controller.bringToFront(element.id);
              break;
            case 'back':
              controller.sendToBack(element.id);
              break;
            case 'forward':
              controller.bringForward(element.id);
              break;
            case 'backward':
              controller.sendBackward(element.id);
              break;
          }
        },
        onTextChanged: element is TextElement ? (newText) {
          element.text = newText;
          controller.updateElement(element);
        } : null,
        // CRITICAL FIX: IgnorePointer allows taps to pass through to Layer 1
        // This ensures the visual elements below can still be selected
        // Only the handles (in ResizableWidget) will capture touch events
        child: IgnorePointer(
          child: SizedBox(
            width: element.size.width,
            height: element.size.height,
          ),
        ),
      ),
    );
  }
  void _editElement(BuildContext context, TemplateElement element,
      InvoiceEditorController controller) {
    // REMOVED POPUP DIALOGS - All editing now happens in Property Panel
    // Just select the element to show its properties in the panel
    controller.selectElement(element.id);
    
    // Special case: For signature elements, still show signature pad as it's a drawing tool
    if (element is SignatureElement) {
      _showSignatureEditDialog(context, element, controller);
    }
  }

  // ==================== EDIT DIALOGS (REMOVED - Now using Property Panel) ====================
  
  // Text editing is now handled inline via double-click in ResizableWidget
  // All other editing is done through the Property Panel

  // Table editing removed - use Property Panel
  // QR editing removed - use Property Panel  
  // Image editing removed - use Property Panel
  // Shape editing removed - use Property Panel
  // Background editing removed - use Property Panel
  // SVG editing removed - use Property Panel
  
  // Only signature pad remains as it's a drawing tool
  void _showSignatureEditDialog(BuildContext context, SignatureElement element,
      InvoiceEditorController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.draw, color: Colors.indigo),
            SizedBox(width: 8),
            Text('Draw Signature'),
          ],
        ),
        content: SizedBox(
          width: 450,
          height: 280,
          child: Column(
            children: [
              // Info
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 18, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'Draw your signature in the box below',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Signature Pad
              Expanded(
                child: SignaturePadWidget(
                  strokeColor: element.strokeColor,
                  strokeWidth: element.strokeWidth,
                  onSignatureComplete: (bytes) {
                    element.signatureImage = bytes;
                    controller.updateElement(element);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }


  // ==================== CANVAS GESTURE HANDLERS ====================
  
  void _onScaleStart(ScaleStartDetails details) {
    _lastFocalPoint = details.focalPoint;
    _initialZoom = _currentZoom;
    _pointerCount = details.pointerCount;
    
    // Only start panning if using 2+ fingers (pinch zoom) or middle mouse button
    if (_pointerCount > 1) {
      _isPanning = true;
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails details, InvoiceEditorController controller) {
    // Multi-touch: zoom and pan
    if (_pointerCount > 1) {
      setState(() {
        // Pinch zoom (mobile/trackpad)
        _currentZoom = (_initialZoom * details.scale).clamp(0.25, 3.0);
        controller.setZoom(_currentZoom);
        
        // Pan while zooming
        if (_lastFocalPoint != null) {
          final delta = details.focalPoint - _lastFocalPoint!;
          _currentPan += delta;
        }
        _lastFocalPoint = details.focalPoint;
      });
    } else if (_isPanning && _lastFocalPoint != null) {
      // Single-finger/mouse pan (if enabled)
      setState(() {
        final delta = details.focalPoint - _lastFocalPoint!;
        _currentPan += delta;
        _lastFocalPoint = details.focalPoint;
      });
    }
  }

  void _onScaleEnd(ScaleEndDetails details) {
    _isPanning = false;
    _lastFocalPoint = null;
    _pointerCount = 0;
  }

  void _onTapDown(TapDownDetails details, InvoiceEditorController controller, BoxConstraints constraints) {
    _handleCanvasTap(details.localPosition, controller, constraints);
  }

  void _handleCanvasTap(Offset globalPosition, InvoiceEditorController controller, BoxConstraints constraints) {
    final tool = controller.currentTool;
    
    // DEBUG: Log click event
    debugPrint('🖱️ Canvas Click: global=$globalPosition, tool=$tool');
    
    // Convert global position to canvas-local position FIRST
    final canvasPosition = _globalToCanvasPosition(globalPosition, constraints);
    debugPrint('📍 Canvas Position: $canvasPosition (zoom=${_currentZoom.toStringAsFixed(2)}, pan=$_currentPan)');
    
    // Check if clicked on any element
    final clickedElement = controller.getElementAtPoint(canvasPosition);
    debugPrint('🎯 Hit Test: ${clickedElement != null ? "Element ${clickedElement.name}" : "Empty space"}');
    
    // ISSUE 1 FIX: Handle selection for select tool
    if (tool == EditorTool.select) {
      if (clickedElement == null) {
        // Clicked on empty space - clear selection (unless Shift is held)
        if (!HardwareKeyboard.instance.isShiftPressed) {
          debugPrint('✅ Clearing selection (clicked empty space)');
          controller.clearSelection();
        }
      }
      // If clicked on element, ResizableWidget will handle selection
      return;
    }
    
    // Now handle tool-based element creation with correct position
    // (canvasPosition already calculated above)
    switch (tool) {
      case EditorTool.text:
        controller.addText(position: canvasPosition);
        controller.setTool(EditorTool.select); // Auto-switch back to select
        break;
      case EditorTool.image:
        _pickAndAddImage(canvasPosition, controller);
        controller.setTool(EditorTool.select); // Auto-switch back to select
        break;
      case EditorTool.shape:
        controller.addShape(position: canvasPosition, shapeType: ShapeType.rectangle);
        controller.setTool(EditorTool.select); // Auto-switch back to select
        break;
      case EditorTool.qrCode:
        controller.addQrCode(position: canvasPosition);
        controller.setTool(EditorTool.select); // Auto-switch back to select
        break;
      case EditorTool.table:
        controller.addTable(position: canvasPosition);
        controller.setTool(EditorTool.select); // Auto-switch back to select
        break;
      case EditorTool.placeholder:
        _showPlaceholderTypeDialog(canvasPosition, controller);
        controller.setTool(EditorTool.select); // Auto-switch back to select
        break;
      case EditorTool.signature:
        controller.addSignature(position: canvasPosition);
        controller.setTool(EditorTool.select); // Auto-switch back to select
        break;
      case EditorTool.productGrid:
        controller.addProductGrid(position: canvasPosition);
        controller.setTool(EditorTool.select); // Auto-switch back to select
        break;
      default:
        break;
    }
  }
  
  /// Convert global viewport position to canvas-local position
  /// Accounts for FittedBox scaling, zoom, pan, and canvas centering
  Offset _globalToCanvasPosition(Offset globalPosition, BoxConstraints constraints) {
    final pageSize = widget.configs.canvasConfig.pageSize.size;
    
    // Step 1: Calculate FittedBox scale factor
    // FittedBox scales the document to fit within (constraints - padding)
    final availableWidth = constraints.maxWidth - 0; // No padding
    final availableHeight = constraints.maxHeight - 0;
    
    // FittedBox with BoxFit.contain calculates scale as:
    // min(availableWidth/docWidth, availableHeight/docHeight)
    final scaleX = availableWidth / pageSize.width;
    final scaleY = availableHeight / pageSize.height;
    final fittedBoxScale = scaleX < scaleY ? scaleX : scaleY;
    
    // Actual displayed size after FittedBox scaling
    final displayWidth = pageSize.width * fittedBoxScale;
    final displayHeight = pageSize.height * fittedBoxScale;
    
    debugPrint('🔍 Coordinate Conversion:');
    debugPrint('   Document: ${pageSize.width}×${pageSize.height}');
    debugPrint('   FittedBox scale: ${fittedBoxScale.toStringAsFixed(3)}');
    debugPrint('   Display size: ${displayWidth.toStringAsFixed(1)}×${displayHeight.toStringAsFixed(1)}');
    debugPrint('   User zoom: ${_currentZoom.toStringAsFixed(2)}');
    
    // Step 2: Calculate where the canvas center is in the viewport
    final viewportCenter = Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);
    
    // Step 3: Calculate total scale (FittedBox × user zoom)
    final totalScale = fittedBoxScale * _currentZoom;
    
    // Step 4: Calculate the canvas top-left position after centering, scaling, and pan
    final scaledWidth = pageSize.width * totalScale;
    final scaledHeight = pageSize.height * totalScale;
    
    final canvasTopLeft = Offset(
      viewportCenter.dx - (scaledWidth / 2) + _currentPan.dx,
      viewportCenter.dy - (scaledHeight / 2) + _currentPan.dy,
    );
    
    debugPrint('   Canvas top-left: ${canvasTopLeft.dx.toStringAsFixed(1)}, ${canvasTopLeft.dy.toStringAsFixed(1)}');
    
    // Step 5: Convert global position to canvas-relative position
    final relativePosition = globalPosition - canvasTopLeft;
    
    // Step 6: Divide by total scale to get document coordinates
    // This reverses BOTH the FittedBox scale AND the user zoom
    final documentPosition = Offset(
      relativePosition.dx / totalScale,
      relativePosition.dy / totalScale,
    );
    
    debugPrint('   Global tap: ${globalPosition.dx.toStringAsFixed(1)}, ${globalPosition.dy.toStringAsFixed(1)}');
    debugPrint('   Document pos: ${documentPosition.dx.toStringAsFixed(1)}, ${documentPosition.dy.toStringAsFixed(1)}');
    
    // Step 7: Clamp to canvas bounds (prevents elements outside canvas)
    final clampedX = documentPosition.dx.clamp(0.0, pageSize.width);
    final clampedY = documentPosition.dy.clamp(0.0, pageSize.height);
    
    return Offset(clampedX, clampedY);
  }

  // Placeholder type dialog for adding new placeholders
  // REMOVED: _showTableEditDialog - use Property Panel instead


  // ==================== HELPER METHODS ====================

  Future<void> _pickAndAddImage(
      Offset point, InvoiceEditorController controller) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        final bytes = await image.readAsBytes();
        controller.addImage(bytes: bytes, position: point);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  IconData _getQrPlaceholderIcon(QrPlaceholderType type) {
    switch (type) {
      case QrPlaceholderType.paymentQr:
        return Icons.payment;
      case QrPlaceholderType.websiteQr:
        return Icons.language;
      case QrPlaceholderType.invoiceQr:
        return Icons.receipt_long;
      case QrPlaceholderType.contactQr:
        return Icons.contact_phone;
      case QrPlaceholderType.customPlaceholder:
        return Icons.code;
    }
  }
  void _showPlaceholderTypeDialog(Offset point, InvoiceEditorController controller) {
    showDialog(
      context: context,
      builder: (context) => _PlaceholderTypeDialog(
        onSelectField: (key, name) {
          controller.addPlaceholder(
            placeholderKey: key,
            displayName: name,
            position: point,
          );
        },
        onSelectItemTable: (ItemTablePreset preset) {
          controller.addItemTable(
            position: point,
            preset: preset,
          );
        },
      ),
    );
  }
}

// ============================================================================
// HELPER WIDGETS
// ============================================================================

class _QuickFillChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickFillChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _QuickKeyChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickKeyChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 10)),
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

class _PlaceholderTypeDialog extends StatefulWidget {
  final Function(String key, String name) onSelectField;
  final Function(ItemTablePreset preset) onSelectItemTable;

  const _PlaceholderTypeDialog({
    required this.onSelectField,
    required this.onSelectItemTable,
  });

  @override
  State<_PlaceholderTypeDialog> createState() => _PlaceholderTypeDialogState();
}

class _PlaceholderTypeDialogState extends State<_PlaceholderTypeDialog> {
  ItemTablePreset _selectedPreset = ItemTablePreset.classic;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.code, color: Colors.orange),
          SizedBox(width: 8),
          Text('Add Element'),
        ],
      ),
      content: SizedBox(
        width: 500,
        height: 550,
        child: DefaultTabController(
          length: 4,
          child: Column(
            children: [
              const TabBar(
                isScrollable: true,
                tabs: [
                  Tab(icon: Icon(Icons.receipt, size: 18), text: 'Invoice'),
                  Tab(icon: Icon(Icons.business, size: 18), text: 'Business'),
                  Tab(icon: Icon(Icons.person, size: 18), text: 'Customer'),
                  // Tab(icon: Icon(Icons.table_chart, size: 18), text: 'Items Table'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildInvoicePlaceholders(context),
                    _buildBusinessPlaceholders(context),
                    _buildCustomerPlaceholders(context),
                    // _buildItemTableSelection(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Widget _buildInvoicePlaceholders(BuildContext context) {
    final placeholders = [
      ('invoice.invoice_no', 'Invoice Number', Icons.tag),
      ('invoice.date', 'Invoice Date', Icons.calendar_today),
      ('invoice.due_date', 'Due Date', Icons.event),
      ('invoice.grand_total', 'Grand Total', Icons.attach_money),
      ('invoice.sub_total', 'Sub Total', Icons.calculate),
      ('invoice.total_tax', 'Total Tax', Icons.percent),
      ('invoice.in_words', 'Amount in Words', Icons.text_fields),
      ('invoice.notes', 'Notes', Icons.note),
    ];

    return ListView.builder(
      itemCount: placeholders.length,
      itemBuilder: (context, index) {
        final (key, name, icon) = placeholders[index];
        return ListTile(
          leading: Icon(icon, size: 20, color: Colors.orange),
          title: Text(name),
          subtitle: Text('{{$key}}', style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
          trailing: const Icon(Icons.add_circle_outline, color: Colors.orange),
          onTap: () {
            Navigator.pop(context);
            widget.onSelectField(key, name);
          },
        );
      },
    );
  }

  Widget _buildBusinessPlaceholders(BuildContext context) {
    final placeholders = [
      ('business.name', 'Business Name', Icons.store),
      ('business.address', 'Address', Icons.location_on),
      ('business.phone', 'Phone', Icons.phone),
      ('business.email', 'Email', Icons.email),
      ('business.gstin', 'GSTIN', Icons.verified),
      ('business.logo', 'Logo URL', Icons.image),
    ];

    return ListView.builder(
      itemCount: placeholders.length,
      itemBuilder: (context, index) {
        final (key, name, icon) = placeholders[index];
        return ListTile(
          leading: Icon(icon, size: 20, color: Colors.blue),
          title: Text(name),
          subtitle: Text('{{$key}}', style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
          trailing: const Icon(Icons.add_circle_outline, color: Colors.blue),
          onTap: () {
            Navigator.pop(context);
            widget.onSelectField(key, name);
          },
        );
      },
    );
  }

  Widget _buildCustomerPlaceholders(BuildContext context) {
    final placeholders = [
      ('customer.name', 'Customer Name', Icons.person),
      ('customer.address', 'Address', Icons.location_on),
      ('customer.phone', 'Phone', Icons.phone),
      ('customer.gstin', 'GSTIN', Icons.verified),
    ];

    return ListView.builder(
      itemCount: placeholders.length,
      itemBuilder: (context, index) {
        final (key, name, icon) = placeholders[index];
        return ListTile(
          leading: Icon(icon, size: 20, color: Colors.green),
          title: Text(name),
          subtitle: Text('{{$key}}', style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
          trailing: const Icon(Icons.add_circle_outline, color: Colors.green),
          onTap: () {
            Navigator.pop(context);
            widget.onSelectField(key, name);
          },
        );
      },
    );
  }


}

/// Signature Pad Widget (inline version)
class SignaturePadWidget extends StatefulWidget {
  final Function(Uint8List) onSignatureComplete;
  final Color strokeColor;
  final double strokeWidth;

  const SignaturePadWidget({
    super.key,
    required this.onSignatureComplete,
    this.strokeColor = Colors.black,
    this.strokeWidth = 2.0,
  });

  @override
  State<SignaturePadWidget> createState() => _SignaturePadWidgetState();
}

class _SignaturePadWidgetState extends State<SignaturePadWidget> {
  final List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];
  final GlobalKey _canvasKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Canvas
        Expanded(
          child: GestureDetector(
            onPanStart: (details) {
              setState(() {
                _currentStroke = [details.localPosition];
              });
            },
            onPanUpdate: (details) {
              setState(() {
                _currentStroke.add(details.localPosition);
              });
            },
            onPanEnd: (details) {
              setState(() {
                if (_currentStroke.isNotEmpty) {
                  _strokes.add(List.from(_currentStroke));
                }
                _currentStroke = [];
              });
            },
            child: Container(
              key: _canvasKey,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CustomPaint(
                  painter: _SignaturePainter(
                    strokes: _strokes,
                    currentStroke: _currentStroke,
                    strokeColor: widget.strokeColor,
                    strokeWidth: widget.strokeWidth,
                  ),
                  size: Size.infinite,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Actions
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            OutlinedButton.icon(
              icon: const Icon(Icons.clear),
              label: const Text('Clear'),
              onPressed: () {
                setState(() {
                  _strokes.clear();
                  _currentStroke.clear();
                });
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text('Done'),
              onPressed: _strokes.isNotEmpty ? _saveSignature : null,
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _saveSignature() async {
    try {
      // Get canvas size
      final RenderBox? renderBox =
      _canvasKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) return;

      final size = renderBox.size;

      // Create picture recorder
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Draw white background
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = Colors.white,
      );

      // Draw signature
      final painter = _SignaturePainter(
        strokes: _strokes,
        currentStroke: [],
        strokeColor: widget.strokeColor,
        strokeWidth: widget.strokeWidth,
      );
      painter.paint(canvas, size);

      // Convert to image
      final picture = recorder.endRecording();
      final image =
      await picture.toImage(size.width.toInt(), size.height.toInt());
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        widget.onSignatureComplete(byteData.buffer.asUint8List());
      }
    } catch (e) {
      debugPrint('Error saving signature: $e');
    }
  }
}
class _SignaturePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;
  final Color strokeColor;
  final double strokeWidth;

  _SignaturePainter({
    required this.strokes,
    required this.currentStroke,
    required this.strokeColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Draw completed strokes
    for (final stroke in strokes) {
      _drawStroke(canvas, stroke, paint);
    }

    // Draw current stroke
    if (currentStroke.isNotEmpty) {
      _drawStroke(canvas, currentStroke, paint);
    }
  }

  void _drawStroke(Canvas canvas, List<Offset> points, Paint paint) {
    if (points.isEmpty) return;

    if (points.length == 1) {
      canvas.drawCircle(
          points.first, strokeWidth / 2, paint..style = PaintingStyle.fill);
      return;
    }

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final midPoint = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
      path.quadraticBezierTo(p0.dx, p0.dy, midPoint.dx, midPoint.dy);
    }

    if (points.length > 1) {
      path.lineTo(points.last.dx, points.last.dy);
    }

    canvas.drawPath(path, paint..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) {
    return strokes != oldDelegate.strokes ||
        currentStroke != oldDelegate.currentStroke;
  }
}