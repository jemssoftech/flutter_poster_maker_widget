import 'package:flutter/material.dart';
import '../widgets/page_manager_bar.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../models/invoice_model.dart';
import 'editor_controller.dart';
import 'editor_configs.dart';
import '../models/template_element.dart';
import '../widgets/editor_canvas.dart';
import '../widgets/responsive_toolbar.dart';
// Old properties_panel.dart.dep.bin deprecated - use property_components/property_panel_scaffold.dart
import '../widgets/responsive_properties_panel.dart';
import '../widgets/responsive_layers_panel.dart';
import '../widgets/zoom_control_widget.dart';
import '../widgets/mobile_app_bar.dart';

/// Invoice Pro Editor - Like ProImageEditor
class InvoiceProEditor extends StatefulWidget {
  /// Editor configuration
  final InvoiceEditorConfigs configs;

  /// Editor callbacks
  final InvoiceEditorCallbacks callbacks;

  /// Initial template JSON to load
  final Map<String, dynamic>? initialTemplate;

  /// Initial invoice data for preview
  final Map<String, dynamic>? initialInvoiceData;

  const InvoiceProEditor({
    super.key,
    this.configs = const InvoiceEditorConfigs(),
    this.callbacks = const InvoiceEditorCallbacks(),
    this.initialTemplate,
    this.initialInvoiceData,
  });

  /// Create editor with network template
  factory InvoiceProEditor.network({
    required String templateUrl,
    InvoiceEditorConfigs configs = const InvoiceEditorConfigs(),
    InvoiceEditorCallbacks callbacks = const InvoiceEditorCallbacks(),
  }) {
    // Load template from network
    return InvoiceProEditor(
      configs: configs,
      callbacks: callbacks,
    );
  }

  /// Create editor with asset template
  factory InvoiceProEditor.asset({
    required String templateAsset,
    InvoiceEditorConfigs configs = const InvoiceEditorConfigs(),
    InvoiceEditorCallbacks callbacks = const InvoiceEditorCallbacks(),
  }) {
    // Load template from asset
    return InvoiceProEditor(
      configs: configs,
      callbacks: callbacks,
    );
  }

  @override
  State<InvoiceProEditor> createState() => _InvoiceProEditorState();
}

class _InvoiceProEditorState extends State<InvoiceProEditor> {
  late InvoiceEditorController _controller;
  bool _showLayersPanel = true;
  bool _showPropertiesPanel = true;
  bool _showPageManager = false; // Default closed
  bool _isMobile = false;

  @override
  void initState() {
    super.initState();

    // Check if mobile on init to set default panel state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final width = MediaQuery.of(context).size.width;
      setState(() {
        _isMobile = width < 600;
        // On mobile, start with panels closed by default
        if (_isMobile) {
          _showLayersPanel = false;
          _showPropertiesPanel = false;
        }
      });
    });
    _controller = InvoiceEditorController(
      configs: widget.configs,
      callbacks: widget.callbacks,
    );

    // Load initial template if provided
    if (widget.initialTemplate != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.importSmartJson(widget.initialTemplate!);
      });
    }

    // Load initial invoice data if provided
    if (widget.initialInvoiceData != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.loadInvoiceData(
          InvoiceDocument.fromJson(widget.initialInvoiceData!),
        );
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<InvoiceEditorController>(
        builder: (context, controller, _) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;
              final isTablet =
                  constraints.maxWidth >= 600 && constraints.maxWidth < 1024;
              final isDesktop = constraints.maxWidth >= 1024;
              final showMobileAppBar = isMobile || isTablet;

              // Auto-open properties panel on mobile when element is selected
              if (isMobile && controller.selectedElements.isNotEmpty && !_showPropertiesPanel) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      _showPropertiesPanel = true;
                    });
                  }
                });
              }

              return Scaffold(
                backgroundColor: widget.configs.canvasConfig.backgroundColor,
                // AppBar for mobile/tablet only
                appBar: showMobileAppBar
                    ? MobileAppBar(
                        onToggleLayers: () => setState(
                            () => _showLayersPanel = !_showLayersPanel),
                        showLayersPanel: _showLayersPanel,
                        canvasTitle: _controller.templateName,
                      )
                    : null,
                body: CallbackShortcuts(
                  bindings: _buildKeyboardShortcuts(),
                  child: Focus(
                    autofocus: true,
                    child: Column(
                      children: [
                        // Main Content with Responsive Toolbar
                        Expanded(
                          child: Stack(
                            children: [
                              // Main Row with Toolbar, Canvas and Panels
                              Row(
                                children: [
                                  // Vertical Toolbar (Desktop only)
                                  if (isDesktop &&
                                      widget.configs.toolbarConfig
                                          .showMainToolbar)
                                    ResponsiveToolbar(
                                      onToggleLayers: () => setState(() =>
                                          _showLayersPanel = !_showLayersPanel),
                                      onToggleProperties: () => setState(() =>
                                          _showPropertiesPanel =
                                              !_showPropertiesPanel),
                                      showLayersPanel: _showLayersPanel,
                                      showPropertiesPanel: _showPropertiesPanel,
                                    ),

                                  // Layers Panel (Desktop only - inline)
                                  if (isDesktop &&
                                      _showLayersPanel &&
                                      widget.configs.toolbarConfig
                                          .showLayersPanel)
                                    ResponsiveLayersPanel(
                                      isOpen: _showLayersPanel,
                                      onClose: () => setState(
                                          () => _showLayersPanel = false),
                                      showPageManager: _showPageManager,
                                      onTogglePageManager: () => setState(
                                          () => _showPageManager = !_showPageManager),
                                    ),

                                  // Canvas
                                  Expanded(
                                    child: AbsorbPointer(
                                      // Disable canvas interaction when mobile/tablet layers panel is open as overlay
                                      absorbing: (isMobile || isTablet) &&
                                          _showLayersPanel,
                                      child: EditorCanvas(
                                        configs: widget.configs,
                                      ),
                                    ),
                                  ),

                                  // Properties Panel (Desktop/Tablet only - inline)
                                  if (!isMobile &&
                                      _showPropertiesPanel &&
                                      widget.configs.toolbarConfig
                                          .showPropertiesPanel)
                                    ResponsivePropertiesPanel(
                                      isOpen: _showPropertiesPanel,
                                      onClose: () => setState(
                                          () => _showPropertiesPanel = false),
                                    ),
                                ],
                              ),

                              // Layers Panel (Mobile/Tablet only - overlay slide-in sidebar)
                              if ((isMobile || isTablet) &&
                                  widget.configs.toolbarConfig.showLayersPanel)
                                ResponsiveLayersPanel(
                                  isOpen: _showLayersPanel,
                                  onClose: () =>
                                      setState(() => _showLayersPanel = false),
                                  showPageManager: _showPageManager,
                                  onTogglePageManager: () => setState(
                                      () => _showPageManager = !_showPageManager),
                                ),

                              // Properties Panel (Mobile only - draggable bottom sheet overlay)
                              if (isMobile &&
                                  widget.configs.toolbarConfig.showPropertiesPanel)
                                Positioned.fill(
                                  child: ResponsivePropertiesPanel(
                                    isOpen: _showPropertiesPanel,
                                    onClose: () =>
                                        setState(() => _showPropertiesPanel = false),
                                  ),
                                ),

                              // Zoom Control (Bottom-Right)
                              const ZoomControlWidget(),

                            ],
                          ),
                        ),

                        // Page Manager Bar (toggleable, default closed)
                        if (_showPageManager)
                          PageManagerBar(
                            controller: controller,
                            height: isMobile 
                                ? MediaQuery.of(context).size.height * 0.15 
                                : 120,
                          ),

                        // Horizontal Toolbar (Mobile/Tablet only - bottom)
                        if (!isDesktop &&
                            widget.configs.toolbarConfig.showMainToolbar)
                          ResponsiveToolbar(
                            onToggleLayers: () => setState(
                                () => _showLayersPanel = !_showLayersPanel),
                            onToggleProperties: () => setState(() =>
                                _showPropertiesPanel = !_showPropertiesPanel),
                            showLayersPanel: _showLayersPanel,
                            showPropertiesPanel: _showPropertiesPanel,
                          ),

                        // Bottom Tool Options (context-sensitive)
                        if (isDesktop) _buildBottomToolOptions(),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Map<ShortcutActivator, VoidCallback> _buildKeyboardShortcuts() {
    return {
      // Undo/Redo
      const SingleActivator(LogicalKeyboardKey.keyZ, control: true): () =>
          _controller.undo(),
      const SingleActivator(LogicalKeyboardKey.keyZ,
          control: true, shift: true): () => _controller.redo(),
      const SingleActivator(LogicalKeyboardKey.keyY, control: true): () =>
          _controller.redo(),

      // Delete
      const SingleActivator(LogicalKeyboardKey.delete): () =>
          _controller.removeSelected(),
      const SingleActivator(LogicalKeyboardKey.backspace): () =>
          _controller.removeSelected(),

      // Select All
      const SingleActivator(LogicalKeyboardKey.keyA, control: true): () =>
          _controller.selectAll(),

      // Duplicate
      const SingleActivator(LogicalKeyboardKey.keyD, control: true): () =>
          _controller.duplicateSelected(),

      // Group/Ungroup
      const SingleActivator(LogicalKeyboardKey.keyG, control: true): () =>
          _controller.groupSelected(),
      const SingleActivator(LogicalKeyboardKey.keyG,
          control: true, shift: true): () => _controller.ungroupSelected(),

      // Zoom
      const SingleActivator(LogicalKeyboardKey.equal, control: true): () =>
          _controller.zoomIn(),
      const SingleActivator(LogicalKeyboardKey.minus, control: true): () =>
          _controller.zoomOut(),
      const SingleActivator(LogicalKeyboardKey.digit0, control: true): () =>
          _controller.setZoom(1.0),

      // Escape - Deselect
      const SingleActivator(LogicalKeyboardKey.escape): () =>
          _controller.clearSelection(),

      // Tools
      const SingleActivator(LogicalKeyboardKey.keyV): () =>
          _controller.setTool(EditorTool.select),
      const SingleActivator(LogicalKeyboardKey.keyT): () =>
          _controller.setTool(EditorTool.text),
      const SingleActivator(LogicalKeyboardKey.keyC, control: true): () =>
          _controller.copySelected(),
      const SingleActivator(LogicalKeyboardKey.keyX, control: true): () =>
          _controller.cutSelected(),
      const SingleActivator(LogicalKeyboardKey.keyV, control: true): () =>
          _controller.paste(),

      // View toggles (R for Rulers, G for Grid)
      const SingleActivator(LogicalKeyboardKey.keyR): () =>
          _controller.toggleRulers(),
      const SingleActivator(LogicalKeyboardKey.keyG): () =>
          _controller.toggleGrid(),
    };
  }

  Widget _buildBottomToolOptions() {
    return Consumer<InvoiceEditorController>(
      builder: (context, controller, _) {
        switch (controller.currentTool) {
          case EditorTool.text:
            return _buildTextToolOptions();
          case EditorTool.shape:
            return _buildShapeToolOptions();
          case EditorTool.table:
            return _buildTableToolOptions();
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildTextToolOptions() {
    return Container(
      height: 48,
      color: Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Text('Font:'),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: 'Roboto',
            items: ['Roboto', 'Arial', 'Times New Roman', 'Courier']
                .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                .toList(),
            onChanged: (v) {},
          ),
          const SizedBox(width: 16),
          const Text('Size:'),
          const SizedBox(width: 8),
          SizedBox(
            width: 60,
            child: TextField(
              decoration: const InputDecoration(
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(width: 16),
          IconButton(icon: const Icon(Icons.format_bold), onPressed: () {}),
          IconButton(icon: const Icon(Icons.format_italic), onPressed: () {}),
          IconButton(
              icon: const Icon(Icons.format_underline), onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildShapeToolOptions() {
    return Container(
      height: 48,
      color: Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Text('Shape:'),
          const SizedBox(width: 8),
          ...ShapeType.values.map((shape) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Consumer<InvoiceEditorController>(
                  builder: (context, controller, _) {
                    return IconButton(
                      icon: Icon(shape.icon),
                      tooltip: shape.name,
                      onPressed: () {
                        controller.addShape(shapeType: shape);
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                    );
                  },
                ),
              )),
          const VerticalDivider(),
          const Text('Fill:'),
          const SizedBox(width: 8),
          _ColorPickerButton(
            color: Colors.transparent,
            onColorChanged: (color) {
              // Update selected shape fill color
            },
          ),
          const SizedBox(width: 16),
          const Text('Stroke:'),
          const SizedBox(width: 8),
          _ColorPickerButton(
            color: Colors.black,
            onColorChanged: (color) {
              // Update selected shape stroke color
            },
          ),
          const SizedBox(width: 16),
          const Text('Width:'),
          const SizedBox(width: 8),
          SizedBox(
            width: 60,
            child: DropdownButton<double>(
              value: 1.0,
              items: [0.5, 1.0, 2.0, 3.0, 5.0]
                  .map((w) => DropdownMenuItem(
                        value: w,
                        child: Text('${w}px'),
                      ))
                  .toList(),
              onChanged: (v) {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableToolOptions() {
    return Container(
      height: 48,
      color: Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Consumer<InvoiceEditorController>(
        builder: (context, controller, _) {
          return Row(
            children: [
              const Text('Rows:'),
              const SizedBox(width: 8),
              SizedBox(
                width: 60,
                child: TextField(
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: '4'),
                ),
              ),
              const SizedBox(width: 16),
              const Text('Columns:'),
              const SizedBox(width: 8),
              SizedBox(
                width: 60,
                child: TextField(
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: '5'),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.table_chart),
                label: const Text('Insert Table'),
                onPressed: () {
                  controller.addTable(rows: 4, columns: 5);
                },
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.table_rows),
                label: const Text('Items Table'),
                onPressed: () {
                  controller.addTable(
                    rows: 5,
                    columns: 7,
                    dataSourceKey: 'invoice.items',
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Color Picker Button Widget
class _ColorPickerButton extends StatelessWidget {
  final Color color;
  final Function(Color) onColorChanged;

  const _ColorPickerButton({
    required this.color,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showColorPicker(context),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(4),
        ),
        child: color == Colors.transparent
            ? CustomPaint(painter: _TransparentPainter())
            : null,
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    Color pickerColor = color;
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pick Color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: (color) {
              pickerColor = color;
            },
            enableAlpha: true,
            displayThumbColor: true,
            paletteType: PaletteType.hsvWithHue,
            labelTypes: const [], // Optional: Hide complex labels to save space
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              onColorChanged(pickerColor);
              Navigator.pop(ctx);
            },
            child: const Text('Select'),
          ),
        ],
      ),
    );
  }
}

class _TransparentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    const cellSize = 8.0;

    for (int i = 0; i < size.width / cellSize; i++) {
      for (int j = 0; j < size.height / cellSize; j++) {
        paint.color = (i + j) % 2 == 0 ? Colors.white : Colors.grey.shade300;
        canvas.drawRect(
          Rect.fromLTWH(i * cellSize, j * cellSize, cellSize, cellSize),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

